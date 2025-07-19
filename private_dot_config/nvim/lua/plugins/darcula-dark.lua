-- https://github.com/xiantang/darcula-dark.nvim
return {
    {
        "xiantang/darcula-dark.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "darcula-dark",
        },
    }
}