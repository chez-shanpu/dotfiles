-- nvim-cmp設定（emojiサポート付き）
return {
  -- nvim-cmpをオーバーライドしてcmp-emojiを追加
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
}