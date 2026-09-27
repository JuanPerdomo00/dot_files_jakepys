local socket_path = "/tmp/guile-repl.sock"

vim.g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
vim.g["conjure#client#guile#socket#pipename"] = socket_path
vim.g["conjure#log#hud#enabled"] = false
vim.g["conjure#log#botright"] = true

local guile_started = false

local function connect_in_buffer(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_call(bufnr, function ()
            vim.cmd("ConjureConnect")
        end)
        vim.api.nvim_echo({ { "Guile connect: connected to " .. socket_path, "None" } }, false, {})
    end
end

local function wait_for_socket_then_connect(bufnr, attempts_left)
    attempts_left = attempts_left or 30

    if vim.uv.fs_stat(socket_path) then
        connect_in_buffer(bufnr)
    elseif attempts_left > 0 then
        vim.defer_fn(function ()
            wait_for_socket_then_connect(bufnr, attempts_left - 1)
        end, 100)
    else
        vim.notify("Guile didn't open the socket in time. (" .. socket_path .. ")", vim.log.levels.WARN)
        guile_started = false
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "scheme",
    callback = function (args)
        if guile_started then
            return
        end

        guile_started = true

        local bufnr = args.buf

        vim.fn.delete(socket_path)
        vim.fn.jobstart({ "guile", "--listen=" .. socket_path }, { detach = true })

        wait_for_socket_then_connect(bufnr)
    end
})
