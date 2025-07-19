local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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

require("lazy").setup({
  spec = {
    -- LazyVimを追加してそのプラグインをインポート
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- カスタムプラグインでインポート/オーバーライド
    { import = "plugins" },
  },

  defaults = {
    -- デフォルトでは、LazyVimプラグインのみがlazy-loadされる。カスタムプラグインは起動時に読み込まれる。
    -- 何をしているか理解している場合は、これを`true`に設定してすべてのカスタムプラグインをデフォルトでlazy-loadできる。
    lazy = false,
    -- バージョン管理をサポートする多くのプラグインが古いリリースを持っているため、
    -- Neovimのインストールを壊す可能性があるため、今のところversion=falseのままにすることを推奨。
    version = false, -- 常に最新のgitコミットを使用
    -- version = "*", -- semverをサポートするプラグインの最新安定版をインストール
  },

  install = { colorscheme = { "darcula-dark" } },

  checker = {
    enabled = true, -- プラグインの更新を定期的にチェック
    notify = false, -- 更新時に通知
  }, -- プラグインの更新を自動的にチェック

  performance = {
    rtp = {
      -- 一部のrtpプラグインを無効化
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
