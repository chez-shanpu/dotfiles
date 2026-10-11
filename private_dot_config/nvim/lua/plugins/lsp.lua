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

  -- Mason設定（言語サーバーとツールのインストール）
  {
    "mason-org/mason.nvim",
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
