return {
  switch_on_command = false,
  buffer_opts = {
    show_buffer_id = false,
    show_buffer_state = false,
    show_buffer_full_name = false,
    show_buffer_path = false,
    show_buffer_mod = true,
  },
  min_width = 50,
  keymaps = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
}
