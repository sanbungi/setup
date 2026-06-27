local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.termguicolors = true

if vim.fn.has("persistent_undo") == 1 then
    local undodir = vim.fn.expand("~/.cache/nvim/undo")
    vim.fn.mkdir(undodir, "p")
    opt.undodir = undodir
    opt.undofile = true
end

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true
opt.hlsearch = true
opt.incsearch = true

opt.helplang = "ja,en"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- バッファ移動（次 / 前）
keymap("n", "<leader>n", "<cmd>bnext<CR>", opts)
keymap("n", "<leader>p", "<cmd>bprevious<CR>", opts)

for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, ":buffer " .. i .. "<CR>")
end

-- screenとの干渉対策
if vim.env.TERM:match("^screen") then
    vim.opt.laststatus = 0
end

-- :q で現在のバッファだけ閉じる
-- 最後の listed buffer なら通常の :q
local function smart_close()
    local cur = vim.api.nvim_get_current_buf()
    local cur_win = vim.api.nvim_get_current_win()

    -- help / quickfix / nofile などは普通にウィンドウを閉じる
    local buftype = vim.bo[cur].buftype
    if buftype ~= "" and not vim.bo[cur].buflisted then
        vim.cmd("close")
        return
    end

    -- :q と同じく、未保存変更は勝手に捨てない
    if vim.bo[cur].modified then
        vim.notify(
            "No write since last change. Use :w to save, or :q! to quit without saving.",
            vim.log.levels.WARN
        )
        return
    end

    local listed = vim.tbl_filter(function(buf)
        return buf ~= cur
            and vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    -- 他に listed buffer がなければ普通に終了
    if #listed == 0 then
        vim.cmd("quit")
        return
    end

    local function usable(buf)
        return buf
            and buf > 0
            and buf ~= cur
            and vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
    end

    -- まず alternate buffer を候補にする
    local replacement = nil
    local alt = vim.fn.bufnr("#")

    if usable(alt) then
        replacement = alt
    else
        -- alternate が使えない時は、最近使った listed buffer を選ぶ
        table.sort(listed, function(a, b)
            local ia = vim.fn.getbufinfo(a)[1]
            local ib = vim.fn.getbufinfo(b)[1]
            return (ia and ia.lastused or 0) > (ib and ib.lastused or 0)
        end)

        replacement = listed[1]
    end

    if not replacement or not usable(replacement) then
        vim.cmd("quit")
        return
    end

    -- unloaded buffer の場合に備えてロードしておく
    if not vim.api.nvim_buf_is_loaded(replacement) then
        vim.fn.bufload(replacement)
    end

    -- 現在のバッファを表示している全ウィンドウを退避先に差し替える
    -- これをしてから削除すると、split 構成が壊れにくい
    for _, win in ipairs(vim.fn.win_findbuf(cur)) do
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_set_buf, win, replacement)
        end
    end

    -- 元のウィンドウに戻す
    if vim.api.nvim_win_is_valid(cur_win) then
        pcall(vim.api.nvim_set_current_win, cur_win)
    end

    local ok, err = pcall(vim.api.nvim_buf_delete, cur, {
        force = false,
        unload = false,
    })

    if not ok then
        vim.notify(err, vim.log.levels.WARN)
    end
end

vim.api.nvim_create_user_command("SmartClose", smart_close, {})

-- cabbrev ではなく、Enter 時にコマンド全体を見る
-- これなら :q! や :qa! に誤爆しない
vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() == ":" then
        local cmd = vim.fn.getcmdline()

        if cmd:match("^%s*q%s*$") then
            return vim.api.nvim_replace_termcodes("<C-u>SmartClose<CR>", true, false, true)
        end
    end

    return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
end, { expr = true, noremap = true })

-- serve_dの依存関係を自動で取得
vim.lsp.config("serve_d", {
    settings = {
        d = {
            aggressiveUpdate = true,
        },
    },
})

require("lazy").setup({
    -- カラースキーム
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "darker",
            })
            require("onedark").load()
        end,
    },

    -- Mason: LSPサーバー管理
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = function()
            require("mason").setup()
        end,
    },

    -- Mason-lspconfig: MasonとLSPの橋渡し
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ts_ls",         -- TypeScript/JavaScript
                    "pyright",       -- Python
                    "jsonls",        -- JSON
                    "html",          -- HTML
                    "cssls",         -- CSS
                    "gopls",         -- Go
                    "rust_analyzer", -- Rust
                    "lua_ls",        -- Lua
                    "ruby_lsp",      -- Ruby
                    "clangd",        -- C/C++
                    "serve_d",       -- D
                },
                automatic_enable = false,
            })
        end,
    },

    -- Mason Tool Installer: formatter / linter 管理
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        cmd = {
            "MasonToolsInstall",
            "MasonToolsInstallSync",
            "MasonToolsUpdate",
            "MasonToolsUpdateSync",
        },
        opts = {
            ensure_installed = {
                "stylua",
                "ruff",
                "goimports",
                "prettierd",
                "prettier",
                "jq",
                "yamlfmt",
                "taplo",
                "shfmt",
                "sqlfluff",
                "xmlformatter",
            },
            auto_update = false,
            run_on_start = false,
        },
        config = function(_, opts)
            require("mason-tool-installer").setup(opts)
        end,
    },

    {
        "hrsh7th/cmp-nvim-lsp",
        lazy = true,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.config("*", {
                capabilities = capabilities,
            })
        end,
    },

    -- nvim-lspconfig: デフォルト設定を提供
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- Lua専用設定
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                    },
                },
            })

            -- サーバーを有効化
            local servers = {
                "ts_ls",
                "pyright",
                "jsonls",
                "html",
                "cssls",
                "gopls",
                "rust_analyzer",
                "lua_ls",
                "ruby_lsp",
                "clangd",
                "serve_d",
            }

            vim.lsp.enable(servers)

            -- LSPアタッチ時のキーマッピング
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf

                    -- 定義ジャンプ
                    keymap("n", "<leader>df", vim.lsp.buf.definition, { buffer = bufnr, silent = true })

                    -- 参照表示（Telescopeで）
                    keymap("n", "<leader>rf", function()
                        require("telescope.builtin").lsp_references()
                    end, { buffer = bufnr, silent = true })

                    -- リネーム
                    keymap("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, silent = true })

                    -- フォーマット（conform.nvimに委譲）
                    keymap("n", "<leader>fmt", function()
                        require("conform").format({ lsp_format = "fallback" })
                    end, { buffer = bufnr, silent = true })

                    -- アウトライン表示（Telescopeで）
                    keymap("n", "<leader>o", function()
                        require("telescope.builtin").lsp_document_symbols()
                    end, { buffer = bufnr, silent = true })

                    -- シンボル検索（Telescopeで）
                    keymap("n", "<leader>s", function()
                        require("telescope.builtin").lsp_dynamic_workspace_symbols()
                    end, { buffer = bufnr, silent = true })

                    -- コードアクション
                    keymap("n", "<leader>a", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })

                    -- ホバー情報
                    keymap("n", "<leader>h", vim.lsp.buf.hover, { buffer = bufnr, silent = true })

                    -- 診断メッセージ表示
                    keymap("n", "<leader>d", vim.diagnostic.open_float, { buffer = bufnr, silent = true })

                    -- 標準的なキーマッピングも追加
                    keymap("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
                    keymap("n", "gr", vim.lsp.buf.references, { buffer = bufnr, silent = true })
                    keymap("n", "K", vim.lsp.buf.hover, { buffer = bufnr, silent = true })

                    -- 診断の移動（次/前）
                    keymap(
                        "n",
                        "[d",
                        vim.diagnostic.goto_prev,
                        { buffer = bufnr, silent = true, desc = "Prev diagnostic" }
                    )
                    keymap(
                        "n",
                        "]d",
                        vim.diagnostic.goto_next,
                        { buffer = bufnr, silent = true, desc = "Next diagnostic" }
                    )

                    -- 宣言へ（definitionの1段上、言語によっては有用）
                    keymap(
                        "n",
                        "gD",
                        vim.lsp.buf.declaration,
                        { buffer = bufnr, silent = true, desc = "Go to declaration" }
                    )

                    -- 実装へ
                    keymap(
                        "n",
                        "gi",
                        vim.lsp.buf.implementation,
                        { buffer = bufnr, silent = true, desc = "Go to implementation" }
                    )

                    -- 型定義へ（Neovim APIは type_definition）
                    keymap(
                        "n",
                        "gt",
                        vim.lsp.buf.type_definition,
                        { buffer = bufnr, silent = true, desc = "Go to type definition" }
                    )

                    -- シグネチャヘルプ（引数ヒント）
                    keymap(
                        "n",
                        "<leader>k",
                        vim.lsp.buf.signature_help,
                        { buffer = bufnr, silent = true, desc = "Signature help" }
                    )
                end,
            })

            -- 診断表示の設定
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
            })
        end,
    },

    -- nvim-cmp: 補完エンジン
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    -- Tabで補完確定
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Enterでも補完確定
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),

                    -- Ctrl-nで次の候補、Ctrl-pで前の候補
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),

                    -- Ctrl-Spaceで補完メニュー表示
                    ["<C-Space>"] = cmp.mapping.complete(),

                    -- Ctrl-eでキャンセル
                    ["<C-e>"] = cmp.mapping.abort(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                performance = {
                    fetching_timeout = 2000,
                    max_view_entries = 50,
                },
                experimental = {
                    ghost_text = false,
                },
            })
        end,
    },

    -- LuaSnip: スニペットエンジン
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        lazy = true,
    },

    -- Conform: フォーマッター
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            {
                "<M-F>",
                function()
                    require("conform").format({ lsp_format = "fallback" })
                end,
                desc = "Format with conform.nvim",
            },
        },
        opts = {
            format_on_save = {
                lsp_format = "fallback",
                timeout_ms = 1000,
            },
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                go = { "goimports" },
                rust = { "rustfmt" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                json = { "jq" },
                yaml = { "yamlfmt" },
                toml = { "taplo" },
                html = { "prettierd", "prettier" },
                css = { "prettierd", "prettier" },
                markdown = { "prettierd", "prettier" },
                sh = { "shfmt" },
                sql = { "sqlfluff" },
                xml = { "xmlformatter" },
            },
        },
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        cmd = "Telescope",
        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files()
                end,
                desc = "Telescope find files",
            },
            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "Telescope live grep",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "Telescope buffers",
            },
            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "Telescope help tags",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({})
            pcall(require("telescope").load_extension, "fzf")
        end,
    },
    -- Git diff viewer
    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewClose",
            "DiffviewFileHistory",
            "DiffviewFocusFiles",
            "DiffviewLog",
            "DiffviewOpen",
            "DiffviewRefresh",
            "DiffviewToggleFiles",
        },
    },

    -- 日本語ヘルプ
    { "vim-jp/vimdoc-ja" },
})
