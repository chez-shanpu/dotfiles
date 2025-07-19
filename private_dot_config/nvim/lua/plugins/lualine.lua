-- Lualine設定
return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    {
        "nvim-tree/nvim-web-devicons",
        opts = {}
    },
}
