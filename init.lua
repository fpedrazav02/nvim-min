-- VIM SETTINGS
vim.g.mapleader = " " -- Set leader to space
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative Numbers
vim.opt.wrap = false -- Wrap lines
vim.opt.tabstop = 4 -- Set tab at 4
vim.opt.swapfile = false -- NO! Swapfiles
vim.opt.signcolumn = "yes" -- Add sign column to avoid moving lsp signals
vim.opt.winborder = "rounded" -- Set rounded border for better lookup
vim.opt.termguicolors = true -- Habilita colores true color en terminal
vim.opt.background = "dark" -- Set background dark
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Incremental search
vim.opt.scrolloff = 8 -- Always show 8 lines
vim.opt.updatetime = 50 -- Faster update time
vim.opt.clipboard = "unnamedplus" --Set clipboard

-- VIM KEYBINDS
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>jk", ":write<CR>")
vim.keymap.set("n", "<leader>jq", ":quit<CR>")
vim.keymap.set("n", "<leader>nh", ":noh<CR>")
vim.keymap.set("n", "<leader>lsp", vim.cmd.LspInfo)
vim.keymap.set("n", "<leader>lg", function()
	vim.cmd("silent !tmux new-window lazygit")
end)

-- Deactivate macros with q
vim.keymap.set("n", "q", "<Nop>", { noremap = true })

-- PACKAGE MANAGER
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" }, --Scheme package
	{ src = "https://github.com/stevearc/oil.nvim" }, -- File explorer
	{ src = "https://github.com/junegunn/fzf" }, -- Core fzf
	{ src = "https://github.com/junegunn/fzf.vim" }, -- Fzf vim integration
	{ src = "https://github.com/neovim/nvim-lspconfig" }, --Lsps
	{ src = "https://github.com/hrsh7th/nvim-cmp" }, --Autocomplete
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" }, --Autocomplete
	{ src = "https://github.com/niqodea/lasso.nvim" }, --Autocomplete
})

-- CMP SETUP
local cmp = require("cmp") -- Set cmp for autocomplete

cmp.setup({
	mapping = {
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
		["<S-Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end,
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
	}),
})

-- LSP SETUPS
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.enable({
	"lua_ls",
	"basedpyright",
	"ts_ls",
}, {
	capabilities = capabilities,
})
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- LSP KEYBINDS
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gD", vim.lsp.buf.type_definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>KP", function()
	vim.diagnostic.open_float(nil, { focus = false })
end)

-- LSP SIGNATURE
-- Trigger cmd
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
	focusable = false,
	relative = "cursor",
})
-- Keybinding to trigger
vim.keymap.set("i", "<C-k>", function()
	vim.lsp.buf.signature_help()
end)

-- Picker + FileExplorer Setup and Keybinds
require("oil").setup({
	keymaps = {
		["q"] = "actions.close",
	},
})
vim.keymap.set("n", "<leader>cd", ":Oil<CR>")
vim.keymap.set("n", "<leader>ff", ":Files<CR>") -- File search
vim.keymap.set("n", "<leader>fg", ":Rg<CR>") -- Grep for all files
vim.keymap.set("n", "<leader>fb", ":Buffers<CR>") -- Buffers
vim.keymap.set("n", "<leader>fh", ":Help<CR>") -- Help

vim.g.fzf_action = {
	["ctrl-t"] = "tab split",
	["ctrl-s"] = "split",
	["ctrl-v"] = "vsplit",
}
vim.g.fzf_preview_window = { "right:50%:hidden", "p" }
vim.g.fzf_layout = { window = { width = 0.7, height = 0.7 } }
vim.env.FZF_DEFAULT_OPTS = "--bind tab:down,shift-tab:up"

--FORMAT
local function format()
	local filetype = vim.bo.filetype
	if filetype == "python" then
		vim.cmd("silent !isort % && black %")
	elseif filetype == "typescript" or filetype == "javascript" then
		vim.cmd("silent !prettier --write %")
	elseif filetype == "lua" then
		vim.cmd("silent !stylua %")
	else
		vim.lsp.buf.format({ timeout_ms = 2000 })
	end
end
vim.keymap.set("n", "<leader>F", format, { noremap = true, silent = true })

-- COLORSCHEME
vim.cmd("colorscheme vague")
vim.cmd([[ highlight Normal guibg=none ctermbg=none ]]) --Transparent bg
vim.cmd(":hi statusline guibg=NONE") -- No status line

-- lASSO
local lasso = require("lasso")
lasso.setup({
	marks_tracker_path = vim.fn.stdpath("data") .. "/lasso-marks-tracker",
})

-- ADD LASSO files
vim.keymap.set("n", "<leader>a", function()
	require("lasso").mark_file()
end, { desc = "Mark file with Lasso" })

-- OPEN LASSO REFERENCES
vim.keymap.set("n", "<C-e>", function()
	require("lasso").open_marks_tracker()
end, { desc = "Open Lasso marks tracker" })

-- LASSO CMD
local tracker_path = vim.fn.stdpath("data") .. "/lasso-marks-tracker"
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "BufNewFile" }, {
	pattern = tracker_path,
	callback = function(args)
		vim.keymap.set("n", "<CR>", function()
			local line = vim.fn.line(".")
			local lasso_local = require("lasso")
			local ok, err = pcall(function()
				lasso_local.open_marked_file(line)
			end)
			if not ok then
				print("Error opening file:", err)
			end
		end, { buffer = args.buf })

		vim.keymap.set("n", "q", function()
			vim.cmd("b#")
		end, { buffer = buf, silent = true })
	end,
})
