-- ===================================================================
-- Neovim init.lua - Go Development Environment Configuration
-- ===================================================================

-- Leader key setting (must be set before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Prevent Space key from being input as a character
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { noremap = true, silent = true })

-- Basic settings
local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.updatetime = 50
opt.signcolumn = "yes"

-- Clipboard settings
opt.clipboard = "unnamedplus"  -- Use system clipboard

-- Display invisible characters
opt.list = true
opt.listchars = {
  tab = '→ ',      -- Display tabs as →
  space = '·',     -- Display spaces as ·
  eol = '¬',       -- Display line endings as ¬
  trail = '~',     -- Display trailing spaces as ~
  extends = '>',   -- Display characters beyond right edge as >
  precedes = '<',  -- Display characters beyond left edge as <
}

-- Force enable syntax highlighting
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Color scheme setting (explicitly set default)
vim.cmd('colorscheme default')

-- Basic keymaps
local keymap = vim.keymap.set
keymap("n", "<leader>pv", vim.cmd.Ex, { desc = "File explorer" })
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
keymap("n", "n", "nzzzv", { desc = "Next search" })
keymap("n", "N", "Nzzzv", { desc = "Previous search" })

-- ===================================================================
-- Plugin configuration (lazy.nvim)
-- ===================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- VSCode theme
  {
    "Mofiqul/vscode.nvim",
    config = function()
      require('vscode').setup({
        -- Disable theme transparency
        transparent = false,
        -- Enable italic comments
        italic_comments = true,
        -- Highlight current word
        disable_nvimtree_bg = true,
      })
      -- Apply theme
      vim.cmd.colorscheme 'vscode'
    end
  },

  -- Treesitter (syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "lua" },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        sync_install = false,
      })
    end
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Go LSP configuration
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
      
      -- LSP keymaps
      keymap('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
      keymap('n', 'gr', vim.lsp.buf.references, { desc = "Go to references" })
      keymap('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
      keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })
      keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename" })
      keymap('n', '<leader>f', vim.lsp.buf.format, { desc = "Format" })
    end
  },

  -- Auto-completion
  {
    "hrsh7th/nvim-cmp",
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
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      require("nvim-tree").setup({
        view = {
          width = 40,
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        -- Auto focus on open file
        update_focused_file = {
          enable = true,
          update_root = false,  -- Don't change root directory
          ignore_list = {},
        },
        -- Actions when opening files
        actions = {
          open_file = {
            quit_on_open = false,  -- Don't close tree when opening file
            resize_window = true,  -- Adjust window size
          },
        },
      })
      keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle file tree" })
    end
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      
      -- File search
      keymap('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
      keymap('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
      keymap('n', '<leader>fb', builtin.buffers, { desc = "Find buffers" })
      keymap('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
      
      -- LSP integration
      keymap('n', '<leader>fr', builtin.lsp_references, { desc = "Find references" })
      keymap('n', '<leader>fd', builtin.lsp_definitions, { desc = "Find definitions" })
      keymap('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find symbols" })
      keymap('n', '<leader>fw', builtin.lsp_workspace_symbols, { desc = "Find workspace symbols" })
      keymap('n', '<leader>fi', builtin.lsp_implementations, { desc = "Find implementations" })
    end
  },

  -- Go development tools
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        dap_debug = true,
        test_runner = 'go',
        goimport = 'gopls',
        gofmt = 'gofumpt',
        linter = 'golangci-lint',
      })
      
      -- Go keymaps
      keymap('n', '<leader>gt', ':GoTest<CR>', { desc = "Go test" })
      keymap('n', '<leader>gr', ':GoRun<CR>', { desc = "Go run" })
      keymap('n', '<leader>gb', ':GoBuild<CR>', { desc = "Go build" })
      keymap('n', '<leader>gi', ':GoImport<CR>', { desc = "Go import" })
      keymap('n', '<leader>gf', ':GoFmt<CR>', { desc = "Go format" })
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()'
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = 'auto',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {
            {
              'filename',
              file_status = true,      -- Display modification status
              newfile_status = false,  -- New file status
              path = 1,               -- 0 = filename only, 1 = relative path, 2 = absolute path, 3 = absolute path + shortened filename
              symbols = {
                modified = '[+]',      -- Modified file
                readonly = '[-]',      -- Read-only
                unnamed = '[No Name]', -- Unnamed file
                newfile = '[New]',     -- New file
              }
            }
          },
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 300,
        },
      })
      
      keymap('n', '<leader>gb', ':Gitsigns blame_line<CR>', { desc = "Git blame line" })
      keymap('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = "Preview hunk" })
    end
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },

  -- Auto pairs for brackets
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end
  },

  -- Claude Code integration
  {
    "coder/claudecode.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claudecode").setup()
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's changes" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude's changes" },
    },
  },
})

-- ===================================================================
-- Auto commands
-- ===================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Go file specific settings
autocmd("FileType", {
  group = augroup("GoSettings", { clear = true }),
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Auto format on save
autocmd("BufWritePre", {
  group = augroup("GoFormat", { clear = true }),
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ===================================================================
-- Diagnostics configuration
-- ===================================================================

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    }
  },
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

