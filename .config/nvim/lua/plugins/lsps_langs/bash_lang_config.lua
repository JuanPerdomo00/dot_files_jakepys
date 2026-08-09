return {
    cmd = { "bash-language-server", "start" },
    cmd_env = {
        GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)",
    },
    filetypes = { "sh", "bash" },
    root_markers = { ".git" },
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)",
        },
    },
}
