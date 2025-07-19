-- Telescope設定
return {
  -- Telescopeのオプションとプラグインファイルを閲覧するキーマップを変更
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- プラグインファイルを閲覧するキーマップを追加
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- オプションを変更
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },
}