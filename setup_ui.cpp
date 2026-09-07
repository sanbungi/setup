#include <ncursesw/ncurses.h>
#include <locale.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

struct MenuItem {
    std::string id;
    std::string label;
    std::string script;
    bool selected;
};

bool run_command(const std::string& cmd) {
    int ret = std::system(cmd.c_str());
    return ret != -1 && WIFEXITED(ret) && WEXITSTATUS(ret) == 0;
}

std::string shell_quote(const std::string& value) {
    std::string quoted = "'";
    for (char c : value) {
        if (c == '\'') quoted += "'\\''";
        else quoted += c;
    }
    return quoted + "'";
}

void print_usage(const char* program) {
    std::cout
        << "Usage: " << program << " [--all | --task ID ...] [--check] [--source-dir PATH]\n"
        << "       " << program << " --list\n"
        << "Without selection arguments, the interactive menu is opened.\n";
}

void draw_menu(const std::vector<MenuItem>& items, int highlight) {
    clear();
    int h, w;
    getmaxyx(stdscr, h, w);
    std::string title = "=== Environment Setup Wizard ===";
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, (w - 40) / 2, "%s", title.c_str());
    attroff(COLOR_PAIR(1) | A_BOLD);
    mvprintw(3, 2, "Space: Toggle | Enter: Run | q: Quit");

    for (size_t i = 0; i < items.size(); ++i) {
        int y = 5 + static_cast<int>(i);
        if (static_cast<int>(i) == highlight) attron(A_REVERSE);
        mvprintw(y, 4, "[%c] %s", items[i].selected ? 'x' : ' ', items[i].label.c_str());
        if (static_cast<int>(i) == highlight) attroff(A_REVERSE);
    }
    attron(COLOR_PAIR(2));
    mvprintw(h - 2, 2, "Target: Debian/Ubuntu/Fedora (apt or dnf)");
    attroff(COLOR_PAIR(2));
    refresh();
}

int find_task(const std::vector<MenuItem>& items, const std::string& id) {
    for (size_t i = 0; i < items.size(); ++i) {
        if (items[i].id == id) return static_cast<int>(i);
    }
    return -1;
}

int main(int argc, char* argv[]) {
    setlocale(LC_ALL, "");
    const char* home_env = std::getenv("HOME");
    if (!home_env) {
        std::cerr << "Error: HOME environment variable is not set.\n";
        return 1;
    }
    std::string home_dir(home_env);

    std::vector<MenuItem> items = {
        {"neovim", "Build Neovim (LTS) from source", "build_nvim_lts.sh", false},
        {"screen", "Build Screen from source", "build_screen.sh", false},
        {"nodejs", "Install Node.js & npm (via n)", "install_nodejs.sh", false},
        {"ruby", "Install Ruby & gem (via rbenv)", "install_ruby.sh", false},
        {"golang", "Install Golang (from package repo) & LSP", "install_golang.sh", false},
        {"dlang", "Install D language (DMD/DUB)", "install_dlang.sh", false},
        {"rust", "Install Rust (via rustup)", "install_rust.sh", false},
        {"docker", "Install Docker (via get.docker.com)", "install_docker.sh", false},
        {"tmux", "Install tmux (terminal multiplexer)", "install_tmux.sh", false},
        {"atcoder", "Install AtCoder tools (acc + oj; requires Node.js)", "install_atcoder_tools.sh", false},
        {"config", "Overwrite config files (nvim, screen, tmux, bash)", "copy_setting.sh", false},
    };

    bool check_mode = false;
    bool explicit_selection = false;
    bool list_only = false;
    std::string source_dir;

    for (int i = 1; i < argc; ++i) {
        std::string arg(argv[i]);
        if (arg == "--all") {
            explicit_selection = true;
            for (auto& item : items) item.selected = true;
        } else if (arg == "--task") {
            if (++i >= argc) {
                std::cerr << "Error: --task requires an ID.\n";
                return 2;
            }
            int index = find_task(items, argv[i]);
            if (index < 0) {
                std::cerr << "Error: unknown task ID: " << argv[i] << '\n';
                return 2;
            }
            items[index].selected = true;
            explicit_selection = true;
        } else if (arg == "--check") {
            check_mode = true;
        } else if (arg == "--source-dir") {
            if (++i >= argc) {
                std::cerr << "Error: --source-dir requires a path.\n";
                return 2;
            }
            source_dir = argv[i];
        } else if (arg == "--list") {
            list_only = true;
        } else if (arg == "--help" || arg == "-h") {
            print_usage(argv[0]);
            return 0;
        } else {
            std::cerr << "Error: unknown argument: " << arg << '\n';
            print_usage(argv[0]);
            return 2;
        }
    }

    if (list_only) {
        for (const auto& item : items) std::cout << item.id << '\t' << item.label << '\n';
        return 0;
    }
    if (check_mode && !explicit_selection) {
        std::cerr << "Error: --check requires --all or at least one --task.\n";
        return 2;
    }

    bool execute = explicit_selection;
    if (!explicit_selection) {
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
            if (c == KEY_UP && highlight > 0) --highlight;
            else if (c == KEY_DOWN && highlight < static_cast<int>(items.size()) - 1) ++highlight;
            else if (c == ' ') items[highlight].selected = !items[highlight].selected;
            else if (c == 10) { execute = true; break; }
            else if (c == 'q') { execute = false; break; }
        }
        endwin();
    }

    if (!execute) {
        std::cout << "Operation cancelled.\n";
        return 0;
    }

    int node_index = find_task(items, "nodejs");
    int atcoder_index = find_task(items, "atcoder");
    if (items[atcoder_index].selected &&
        (check_mode || !run_command("command -v node >/dev/null && command -v npm >/dev/null"))) {
        items[node_index].selected = true;
    }

    std::string cleanup_dir;
    if (check_mode) {
        if (source_dir.empty()) source_dir = ".";
    } else if (source_dir.empty()) {
        char temp_template[] = "/tmp/setup-tool.XXXXXX";
        char* temp_root = mkdtemp(temp_template);
        if (!temp_root) {
            std::cerr << "[Error] Failed to create a temporary directory.\n";
            return 1;
        }
        cleanup_dir = temp_root;
        source_dir = cleanup_dir + "/setup";
        const char* repository_env = std::getenv("SETUP_REPOSITORY_URL");
        std::string repository_url = repository_env
            ? repository_env
            : "https://github.com/Pikka2048/setup";
        std::cout << "[Git] Cloning from GitHub...\n";
        if (!run_command("git clone " + shell_quote(repository_url) + " " + shell_quote(source_dir))) {
            std::cerr << "[Error] git clone failed.\n";
            run_command("rm -rf -- " + shell_quote(cleanup_dir));
            return 1;
        }
    }

    struct stat source_stat {};
    if (stat(source_dir.c_str(), &source_stat) != 0 || !S_ISDIR(source_stat.st_mode) ||
        chdir(source_dir.c_str()) != 0) {
        std::cerr << "[Error] Invalid source directory: " << source_dir << '\n';
        return 2;
    }

    std::cout << (check_mode ? "=== Starting Preflight Checks ===" : "=== Starting Setup Process ===")
              << std::endl;
    bool failed = false;
    for (const auto& item : items) {
        if (!item.selected) {
            std::cout << "--- [Skip] " << item.id << '\n';
            continue;
        }
        std::cout << ">>> [" << (check_mode ? "Check" : "Task") << "] " << item.id << std::endl;
        std::string command = "bash " + shell_quote(item.script);
        if (check_mode) command += " --check";
        if (run_command(command)) {
            std::cout << ">>> [Success] " << item.id << '\n';
        } else {
            std::cerr << ">>> [Error] " << item.id << " failed.\n";
            failed = true;
        }
    }

    if (!cleanup_dir.empty()) {
        if (chdir(home_dir.c_str()) != 0 || !run_command("rm -rf -- " + shell_quote(source_dir))) {
            std::cerr << "[Error] Failed to clean up temporary setup directory.\n";
            failed = true;
        }
        if (!run_command("rmdir -- " + shell_quote(cleanup_dir))) {
            std::cerr << "[Error] Failed to remove temporary parent directory.\n";
            failed = true;
        }
    }
    std::cout << (check_mode ? "=== Preflight Checks Finished ===\n" : "=== All Processes Finished ===\n");
    return failed ? 1 : 0;
}
