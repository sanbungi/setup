function remoteurl() {
    # originのURLを取得
    local url=$(git remote get-url origin 2>/dev/null)

    if [ -z "$url" ]; then
        echo "Error: Not a git repository or no remote 'origin' found."
        return 1
    fi

    # SSH形式 (git@github.com:user/repo) を HTTPS形式 (https://github.com/user/repo) に変換
    # 1. git@github.com:user/repo.git -> https://github.com/user/repo.git
    # 2. https://github.com/user/repo.git -> https://github.com/user/repo
    local clean_url=$(echo "$url" | \
        sed -e 's/^git@\(.*\):/https:\/\/\1\//' \
            -e 's/\.git$//')

    echo "$clean_url"
}
