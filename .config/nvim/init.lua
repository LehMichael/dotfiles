-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- set cmdline to 0
-- vim.o.cmdheight = 0

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
-- vim.opt.laststatus = 3
-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.opt.clipboard = 'unnamedplus'

vim.opt.wrap = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 0

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", space = "·", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- allow to move selected block in visual mode with J and K
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==", { desc = "Move current Line Down" })
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==", { desc = "Move current Line Up" })
vim.keymap.set("i", "<M-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move current Line Up" })
vim.keymap.set("i", "<M-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move current Line Down" })

-- keep search term in the middlde
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- allow to paste without without changing the clipboard
vim.keymap.set("x", "<Leader>p", '"_dP')
-- use leader d to delete without changing the clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- use leader p to paste from yank buffer
vim.keymap.set("n", "<leader>p", [["0p]])
vim.keymap.set("n", "<leader>P", [["0P]])

-- use leader y to yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("v", "<leader>y", [["+y]])

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local function closeBuffers(pos)
    local current_buf = vim.api.nvim_get_current_buf()
    local buffer_component = require("lualine.components.buffers")
    local buf_list = buffer_component.bufpos2nr or {}

    local current_index
    for i, buf in ipairs(buf_list) do
        if buf == current_buf then
            current_index = i
            break
        end
    end

    if not current_index then
        vim.notify("Current buffer not found in Lualine buffer list", vim.log.levels.WARN)
        return
    end

    if pos == "l" then
        for i = 1, current_index - 1 do
            vim.api.nvim_buf_delete(buf_list[i], { force = false })
        end
    elseif pos == "r" then
        for i = #buf_list, current_index + 1, -1 do
            vim.api.nvim_buf_delete(buf_list[i], { force = false })
        end
    else
        for i = 1, #buf_list do
            if i ~= current_index then
                vim.api.nvim_buf_delete(buf_list[i], { force = false })
            end
        end
    end
end

vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bD", function()
    closeBuffers()
end, { desc = "Close all other buffers" })

vim.keymap.set("n", "<leader>bh", function()
    closeBuffers("l")
end, { desc = "close buffers to the left" })
vim.keymap.set("n", "<leader>bl", function()
    closeBuffers("r")
end, { desc = "close buffers to the right" })

---- Auto indent on empty line.
local function indent_empty_line(key)
    vim.keymap.set("n", key, function()
        return string.match(vim.api.nvim_get_current_line(), "%g") == nil and "cc" or key
    end, { expr = true, noremap = true })
end
indent_empty_line("i")
indent_empty_line("I")
indent_empty_line("a")
indent_empty_line("A")

-- Diagnostic keymaps
vim.keymap.set(
    "n",
    "<leader>q",
    vim.diagnostic.setqflist,
    { desc = "Open diagnostic [Q]uickfix list" }
)

vim.diagnostic.config({
    underline = true,
    virtual_lines = true,
    update_in_insert = false,
    -- virtual_text = {
    --     spacing = 4,
    --     source = "if_many",
    --     prefix = "●",
    --     -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
    --     -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
    --     -- prefix = "icons",
    -- },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
        },
    },
})

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
    ---@diagnostic disable-next-line: assign-type-mismatch
    dev = {
        ---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
        path = "~/src",
        ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
        patterns = {}, -- For example {"folke"}
        fallback = false, -- Fallback to git when local plugin doesn't exist
    },
    install = { colorscheme = { "catpuccin" } },
    spec = {
        { import = "custom.plugins" },
    },
})
