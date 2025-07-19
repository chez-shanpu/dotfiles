-- Trouble.nvim設定
return {
  -- troubleの設定を変更
  {
    "folke/trouble.nvim",
    -- optsは親のspecとマージされる
    opts = { use_diagnostic_signs = true },
  },

  -- troubleを無効化（デフォルトではコメントアウト）
  -- { "folke/trouble.nvim", enabled = false },
}