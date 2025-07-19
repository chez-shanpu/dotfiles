-- LSP設定
return {
  -- lspconfigにpyrightを追加
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyrightはmasonで自動インストールされ、lspconfigで読み込まれる
        pyright = {},
      },
    },
  },

  -- tsserverを追加し、lspconfigの代わりにtypescript.nvimでセットアップ
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserverはmasonで自動インストールされ、lspconfigで読み込まれる
        tsserver = {},
      },
      -- ここで追加のLSPサーバーセットアップが可能
      -- lspconfigでセットアップしたくない場合はtrueを返す
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- typescript.nvimでセットアップする例
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- *を指定すると、すべてのサーバーのフォールバックとしてこの関数を使用
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  -- Mason設定（言語サーバーとツールのインストール）
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },
}