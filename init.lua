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
opt.cursorline = true -- カーソル行をハイライト
opt.termguicolors = true -- True Colorを使用

if vim.fn.has("persistent_undo") == 1 then
	vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undo")
	vim.opt.undofile = true
end

opt.tabstop = 4 -- タブ文字の表示幅
opt.shiftwidth = 4 -- インデントの幅
opt.expandtab = true -- タブをスペースに変換
opt.autoindent = true -- 改行時に前の行のインデントを継続
opt.smartindent = true -- C言語のようなスマートなインデント

-- 検索設定

opt.ignorecase = true -- 大文字小文字を区別しない
opt.smartcase = true -- 大文字が含まれる場合のみ区別する
opt.wrapscan = true -- 最後まで検索したら先頭に戻る
opt.hlsearch = true -- 検索結果をハイライト
opt.incsearch = true -- 入力中に逐次検索を行う

opt.helplang = "ja,en"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ウィンドウ移動 (Ctrl + h/j/k/l)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- カーソル下のシンボルの定義場所へ移動
keymap("n", "<leader>df", "<Plug>(coc-definition)", { silent = true })
-- カーソル下のシンボルが使われている箇所を一覧表示
keymap("n", "<leader>rf", "<Plug>(coc-references)", { silent = true })

-- カーソル下のシンボルを一括リネーム
keymap("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
-- コード整形を実行
keymap("n", "<leader>fmt", "<Plug>(coc-format)", { silent = true })

-- ファイル構造（関数・クラス一覧）を表示
keymap("n", "<leader>o", ":CocList outline<CR>", { silent = true })
-- プロジェクト内のシンボル（関数・変数名など）を検索
keymap("n", "<leader>s", ":CocList -I symbols<CR>", { silent = true })

-- 利用可能なコードアクション（クイックフィックス等）を表示
keymap("n", "<leader>a", "<cmd>CocAction<cr>", { silent = true })
-- カーソル位置のシンボルの型情報やドキュメントを表示
keymap("n", "<leader>h", "<cmd>call CocAction('doHover')<cr>", { silent = true })

local opts2 = { silent = true, expr = true, noremap = true }
keymap("i", "<Tab>", 'pumvisible() ? coc#_select_confirm() : "<Tab>"', opts2) -- Tabで補間を受け入れる
keymap("i", "<CR>", 'coc#pum#visible() ? coc#pum#confirm() : "<CR>"', opts2) -- Enterで補完確定

local opts3 = { silent = true }
keymap("i", "<C-n>", "<Plug>(coc-next)", opts3) -- 下候補へ
keymap("i", "<C-p>", "<Plug>(coc-prev)", opts3) -- 上候補へ

-- screenとの干渉対策
if vim.env.TERM:match("^screen") then
	vim.opt.laststatus = 0
end

require("lazy").setup({
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

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"python",
					"javascript",
					"asm",
					"csv",
					"bash",
					"css",
					"go",
					"java",
					"json",
					"objdump",
					"php",
					"ruby",
					"rust",
					"sql",
					"ssh_config",
					"strace",
					"typescript",
					"xml",
					"yaml",
				},
				highlight = { enable = true },
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				-- shift + alt + f (alt + F)
				"<M-F>",
				function()
					require("conform").format({ lsp_fallback = true })
				end,
				desc = "Format with conform.nvim",
			},
		},
		opts = {
			format_on_save = {
				lsp_fallback = true,
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
				xml = { "xmlformat" },
				dockerfile = { "hadolint" },
			},
		},
	},
	{ "vim-jp/vimdoc-ja" },
	{ "neoclide/coc.nvim", branch = "release" },
})

vim.g.coc_global_extensions = {
	"coc-tsserver",
	"coc-pyright",
	"coc-json",
	"coc-html",
	"coc-css",
	"coc-go",
	"coc-rust-analyzer",
	"coc-lua",
	"coc-solargraph",
	"coc-go",
}
