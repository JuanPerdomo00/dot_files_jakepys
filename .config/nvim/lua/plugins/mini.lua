-- mini files
local MiniFiles = require("mini.files")
MiniFiles.setup({
    mappings = {
        go_in = "<CR>",
        go_in_plus = "L",
        go_out = "_",
        go_out_plus = "H"
    }
})

vim.keymap.set("n", "<Leader>e", function ()
    MiniFiles.open()
end, { desc = "Toggle mini file explorer" }
)

vim.keymap.set("n", "<leader>-", function ()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" }
)

---- mini notify ----
require("mini.notify").setup({
    -- only show messages
    content = {
        format = function (notif)
            return notif.msg
        end
    }
})

--- mini cmdline completion ---
require("mini.cmdline").setup({
    autocorrect = { enable = false }
})

--- mini surround ---
require("mini.surround").setup()
-- Default Keymaps
-- | `sa` | Add surrounding or Direct with 'saiw' |
-- | `sd` | Delete surrounding |
-- | `sr` | Replace surrounding |

--- mini picker ---
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup()
MiniExtra.setup()

-- keymaps
vim.keymap.set("n", "<leader>pf", function () MiniPick.builtin.files() end, { desc = "Mini File Picker" })
vim.keymap.set(
    "n", "<leader>ps", function () MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
    { desc = "Grep word/Search word" }
)
vim.keymap.set("n", "<leader>vh", function () MiniPick.builtin.help() end, { desc = "Mini Help" })

vim.keymap.set("n", "<leader>xx", function () MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>pk", function () MiniExtra.pickers.keymaps() end, { desc = 'Search keymaps' })

--- mini completions ---
require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true
    }
})

--- mini snippets ---
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
    snippets = {
        MiniSnippets.gen_loader.from_lang() -- loads friendly-snippets
    }
})

MiniSnippets.start_lsp_server({ match = false })

--- mini statusline ---
local MiniStatusline = require("mini.statusline")
MiniStatusline.setup({
    use_icons = true
})

MiniStatusline.section_location = function ()
    return "%2l:%-2v"
end

require("mini.indentscope").setup({
    symbol = "│",
    options = {
        try_as_border = true
    },
    draw = {
        delay = 50,
        animation = require("mini.indentscope").gen_animation.none()
    }
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "dashboard", "help", "lazy", "mason", "notify", "toggleterm" },
    callback = function ()
        vim.b.miniindentscope_disable = true
    end
})

--- mini hipatterns ---
require("mini.hipatterns").setup({
    highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack  = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo  = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note  = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" }
    }
})

vim.keymap.set("n", "<leader>tw", function () require("mini.trailspace").trim() end, {
    desc = "Trim trailing whitespace"
})

-- Autopairs
require("mini.pairs").setup()
require("mini.ai").setup()
