-- Treesitter設定
return {
  -- Treesitterパーサーを追加
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- tsxとtypescriptを追加
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "c",
        "git_config",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
  },
}