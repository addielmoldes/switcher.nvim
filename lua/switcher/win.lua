local Menu = require('nui.menu')
local NuiText = require('nui.text')
local NuiLine = require('nui.line')

local config = require('switcher.config')
local util = require('switcher.util')

local popup_options = {
  position = '50%',
  border = {
    style = 'rounded',
    text = {
      top = 'Windows',
      top_align = 'left'
    }
  },
  win_options = {
    winhighlight = 'Normal:Normal,Cursor:BHCursor'
  }
}

local M = {}

function M.switch()
  M.build_win_menu()
end

function M.get_active_windows()
  M.current_tabpage = vim.api.nvim_get_current_tabpage()
  local win_list = vim.api.nvim_tabpage_list_wins(M.current_tabpage)
  local valid_win_list = {}

  for _, win_id in pairs(win_list) do
    if vim.api.nvim_win_is_valid(win_id) then
      table.insert(valid_win_list, win_id)
    end
  end

  return valid_win_list
end

function M.build_menu_lines()
  local lines = {}

  for _, win_id in pairs(M.get_active_windows()) do
    local active_buffer_id = vim.api.nvim_win_get_buf(win_id)
    local active_buffer_name = vim.api.nvim_buf_get_name(active_buffer_id)
    local icon, hi_group, name = util.get_buffer_icon_and_name(active_buffer_name)

    local line = NuiLine({
      NuiText(' '),
      NuiText(string.format('%d ', win_id)),
      NuiText(icon ~= nil and icon .. ' ' or '', hi_group), -- buffer filetype icon
      NuiText(name and name .. ' ' or '[No Name] '), -- buffer file name
    })
    table.insert(lines, Menu.item(line, { id = win_id }))
  end

  return lines
end

function M.build_win_menu()
  local menu = Menu(popup_options, {
    lines = M.build_menu_lines(),
    keymap = config.keymaps,
    min_width = config.min_width,
    on_submit = function(item)
      vim.api.nvim_tabpage_set_win(M.current_tabpage, item.id)
    end,
    on_change = function (item, _menu)
      _menu:map('n', 'd', function (_) -- close window under cursor
        local ok, error = pcall(vim.api.nvim_win_close, item.id, {})

        if not ok then
          _, _, error = error:find('[.:]-(E[%d:]+.+)')
          vim.notify(error, vim.log.levels.ERROR)
        end
      end, { noremap = true })
    end
  })

  menu:mount()
end

return M
