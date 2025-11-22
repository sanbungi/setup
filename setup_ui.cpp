#include <ncursesw/ncurses.h>
#include <locale.h>
#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <cstring>
#include <sys/stat.h>

// メニュー項目の構造体
struct MenuItem {
    std::string label;
    bool selected;
};

// コマンド実行ヘルパー
// 戻り値: 成功(0)なら true, 失敗なら false
bool run_command(const std::string& cmd) {
    int ret = std::system(cmd.c_str());
    if (ret == -1) return false;
    return (WEXITSTATUS(ret) == 0);
}

// 画面描画関数
void draw_menu(const std::vector<MenuItem>& items, int highlight) {
    clear();
    int h, w;
    getmaxyx(stdscr, h, w);

    // タイトル
    std::string title = "=== 環境構築セットアップウィザード ===";
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, (w - 40) / 2, "%s", title.c_str()); 
    attroff(COLOR_PAIR(1) | A_BOLD);

    // 操作説明
    mvprintw(3, 2, "Space: 選択切り替え | Enter: 決定して実行 | q: 中止");

    // リスト描画
    for (size_t i = 0; i < items.size(); ++i) {
        int y = 5 + i;
        if (i == highlight) {
            attron(A_REVERSE);
        }
        
        // [x] or [ ]
        mvprintw(y, 4, "[%c] %s", items[i].selected ? 'x' : ' ', items[i].label.c_str());
        
        if (i == highlight) {
            attroff(A_REVERSE);
        }
    }

    // フッター
    attron(COLOR_PAIR(2));
    mvprintw(h - 2, 2, "Target: Debian/Ubuntu based systems");
    attroff(COLOR_PAIR(2));

    refresh();
}

int main(int argc, char* argv[]) {
    // 1. 日本語ロケール設定 (必須)
    setlocale(LC_ALL, "");

    // 2. ホームディレクトリの取得
    const char* home_env = std::getenv("HOME");
    if (!home_env) {
        std::cerr << "Error: HOME環境変数が設定されていません。" << std::endl;
        return 1;
    }
    std::string home_dir = std::string(home_env);

    // 3. メニュー項目の定義
    std::vector<MenuItem> items = {
        {"Neovim (LTS) をソースからビルド", false},
        {"Screen をソースからビルド", false},
        {"Node.js & npm をインストール (nを使用)", false},
        {"設定ファイルを上書きコピー (nvim, screen, bash)", false}
    };

    bool auto_mode = false;
    bool execute = false;

    // --- 引数チェック (--all で自動実行モード) ---
    if (argc > 1 && std::strcmp(argv[1], "--all") == 0) {
        auto_mode = true;
        execute = true;
        for (auto &item : items) {
            item.selected = true;
        }
        std::cout << "=== 自動実行モード(--all)を検出: 全項目を実行します ===" << std::endl;
    }

    // --- UIモード (自動モードでない場合) ---
    if (!auto_mode) {
        initscr();
        cbreak();
        noecho();
        keypad(stdscr, TRUE);
        curs_set(0); 

        if (has_colors()) {
            start_color();
            init_pair(1, COLOR_CYAN, COLOR_BLACK);
            init_pair(2, COLOR_YELLOW, COLOR_BLACK);
        }

        int highlight = 0;

        while (true) {
            draw_menu(items, highlight);
            int c = getch();

            switch (c) {
                case KEY_UP:
                    if (highlight > 0) highlight--;
                    break;
                case KEY_DOWN:
                    if (highlight < items.size() - 1) highlight++;
                    break;
                case ' ': 
                    items[highlight].selected = !items[highlight].selected;
                    break;
                case 10: 
                    execute = true;
                    goto end_ui;
                case 'q': 
                    execute = false;
                    goto end_ui;
            }
        }
        end_ui:
        endwin(); 
    }

    if (!execute) {
        std::cout << "操作がキャンセルされました。" << std::endl;
        return 0;
    }

    std::cout << "\n=== セットアップ処理を開始します ===\n" << std::endl;

    // 1. システム要件チェック (apt)
    if (!run_command("command -v apt > /dev/null")) {
        std::cerr << "[Error] Debian系以外は対応していません (aptが見つかりません)。" << std::endl;
        return 1;
    }

    // 2. Gitの確認とインストール
    std::cout << "[System] Git環境を確認中..." << std::endl;
    if (!run_command("command -v git > /dev/null")) {
        std::cout << "[System] Gitをインストールします..." << std::endl;
        if (!run_command("sudo apt update && sudo apt install -y git")) {
            std::cerr << "[Error] Gitのインストールに失敗しました。" << std::endl;
            return 1;
        }
    }
    std::cout << "[OK] Git is ready." << std::endl;

    // 3. リポジトリのクローン
    std::string setup_dir = home_dir + "/setup";
    
    // 既存ディレクトリの削除
    if (run_command("[ -d \"" + setup_dir + "\" ]")) {
        std::cout << "[Git] 既存の 'setup' ディレクトリを削除して再クローンします..." << std::endl;
        run_command("rm -rf " + setup_dir);
    }

    std::cout << "[Git] GitHubからクローン中..." << std::endl;
    if (!run_command("git clone https://github.com/Pikka2048/setup " + setup_dir)) {
        std::cerr << "[Error] git clone に失敗しました。" << std::endl;
        return 1;
    }

    // ディレクトリ移動
    if (chdir(setup_dir.c_str()) != 0) {
        std::cerr << "[Error] setupディレクトリへの移動に失敗しました。" << std::endl;
        return 1;
    }
    std::cout << "[OK] クローン完了。選択されたタスクを実行します。\n" << std::endl;

    // 4. 選択タスクの実行

    // --- Task 1: Neovim ---
    if (items[0].selected) {
        std::cout << "\n>>> [Task] Neovim (LTS) のビルドを実行中..." << std::endl;
        if (run_command("bash build_nvim_lts.sh")) {
            std::cout << ">>> [Success] Neovim build finished." << std::endl;
        } else {
            std::cerr << ">>> [Error] Neovim build failed." << std::endl;
        }
    } else {
        std::cout << "--- [Skip] Neovim" << std::endl;
    }

    // --- Task 2: Screen ---
    if (items[1].selected) {
        std::cout << "\n>>> [Task] Screen のビルドを実行中..." << std::endl;
        if (run_command("bash build_screen.sh")) {
            std::cout << ">>> [Success] Screen build finished." << std::endl;
        } else {
            std::cerr << ">>> [Error] Screen build failed." << std::endl;
        }
    } else {
        std::cout << "--- [Skip] Screen" << std::endl;
    }

    // --- Task 3: Node.js ---
    if (items[2].selected) {
        std::cout << "\n>>> [Task] Node.js のインストールを実行中..." << std::endl;
        if (run_command("bash install_nodejs.sh")) {
            std::cout << ">>> [Success] Node.js installation finished." << std::endl;
        } else {
            std::cerr << ">>> [Error] Node.js installation failed." << std::endl;
        }
    } else {
        std::cout << "--- [Skip] Node.js" << std::endl;
    }

    // --- Task 4: Config Files ---
    if (items[3].selected) {
        std::cout << "\n>>> [Task] 設定ファイルをコピー中..." << std::endl;
        if (run_command("bash copy_setting.sh")){
            std::cout << ">>> [Success] Setting files copy finished." << std::endl;
        } else{
            std::cerr << ">>> [Error] Setting files copy failed." << std::endl;
        }
    } else {
        std::cout << "--- [Skip] Config Files" << std::endl;
    }

    // 5. クリーンアップ
    std::cout << "\n[Cleanup] 作業用ディレクトリを削除します..." << std::endl;
    chdir(home_dir.c_str()); // ホームに戻る
    run_command("rm -rf " + setup_dir);

    std::cout << "\n=== すべての処理が終了しました ===" << std::endl;

    return 0;
}
