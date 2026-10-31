local colors = {
    bg      = '#1a1236',
    fg      = '#e8d8ff',
    blue    = '#8a97ff',
    green   = '#a8f0a0',
    magenta = '#c04df0',
    red     = '#e5384f',
    yellow  = '#ffc857',
    cyan    = '#8ff0d8'
}

local vaporwave = {
    normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg }
    },
    insert = {
        a = { bg = colors.green, fg = colors.bg, gui = 'bold' }
    },
    visual = {
        a = { bg = colors.magenta, fg = colors.bg, gui = 'bold' }
    },
    replace = {
        a = { bg = colors.red, fg = colors.bg, gui = 'bold' }
    },
    command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = 'bold' }
    },
    terminal = {
        a = { bg = colors.cyan, fg = colors.bg, gui = 'bold' }
    },
    inactive = {
        a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg }
    }
}

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = vaporwave,
        component_separators = { left = '', right = ' ' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {}
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16,
            events = {
                'WinEnter',
                'BufEnter',
                'BufWritePost',
                'SessionLoadPost',
                'FileChangedShellPost',
                'VimResized',
                'Filetype',
                'CursorMoved',
                'CursorMovedI',
                'ModeChanged'
            }
        }
    },
    sections = {
        lualine_a = {
            function ()
                return "󰣇  " .. os.getenv("USER")
            end,
            'mode'
        },
        lualine_b = {
            'branch',
            'diff',
            {
                'diagnostics',
                symbols = { error = '  ', warn = '  ', info = '  ', hint = '  ' }
            }
        },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = {
            'location',
            function ()
                return os.date("%I:%M %p")
            end
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = { lualine_a = { 'buffers' } },
    winbar = {
        lualine_c = {
            {
                function ()
                    return require('nvim-navic').get_location()
                end,
                cond = function ()
                    return require('nvim-navic').is_available()
                end
            }
        }
    },
    inactive_winbar = {},
    extensions = { "mason" }
}
