local M = {}

local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"
local telescope_pickers = require "telescope.pickers"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


local errors = {
  FILE_NOT_FOUND = "File does not exist!",
  KEY_EXIST = "Key exist!",
  NO_DATA = "No data to write.",
  KEY_NOT_FOUND = "Key does not exist!",
  FAILED_TO_CREATE = "Failed to create file!"
}

local function isempty(s)
  return s == nil or s == ''
end

local _read_file = function(name, modifier)
  modifier = modifier or "r"

  local file = io.open(name, modifier)
  local result = {}

  if file then
    local file_content = file:read("*a")

    result = isempty(file_content) and {} or vim.fn.json_decode(file_content)

    file:close()
  end

  return result
end


local function _parse_text(key, text)
  local file_content = _read_file("output.txt")

  if file_content and file_content ~= '' then
    if file_content[key] == nil then
      file_content[key] = text
    else
      print(errors.KEY_EXIST)
    end
  else
    file_content[key] = text
  end

  return file_content;
end

local function _write_to_file(key, text)
  local data = _parse_text(key, text)

  local file = io.open("output.txt", "w")

  if file then
    if next(data) ~= nil then
      local json = vim.fn.json_encode(data)
      file:write(json)
    else
      print(errors.NO_DATA)
    end

    file:close();
  else
    print(errors.FAILED_TO_CREATE)
  end
end


local _parse_data = function(data)
  local result = {}

  for key, value in pairs(data) do
    table.insert(result, { [key] = value })
  end

  return result
end

local _init_telescope_picker = function(data)
  local parsedData = _parse_data(data)

  return telescope_pickers.new({
    layout_config = {
      height = 0.6,
      width = 0.75,
      prompt_position = "bottom",
    },
    results_title = false,
    sorting_strategy = "descending",
  }, {
    prompt_title = "Get reference",
    finder = finders.new_table {
      results = parsedData,
      entry_maker = function(item)
        local firstKey, firstValue = next(item)

        return {
          value = firstValue,
          ordinal = firstKey,
          display = firstKey
        }
      end
    },
    previewer = previewers.new_buffer_previewer {
      title = "Preview",
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value)
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)

        local selection = action_state.get_selected_entry()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)[1]

        vim.api.nvim_buf_set_text(0, cursor_pos - 1, 0, cursor_pos - 1, 0, selection.value)
      end)
      return true
    end,

  })
end

M.save_reference = function()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  local lines = vim.fn.getline(line_start, line_end)

  vim.ui.input({ prompt = 'Enter reference key: ' }, function(input)
    if input then
      _write_to_file(input, lines)
    end
  end)
end

M.get_reference = function()
  local file = io.open("output.txt", "r")

  if file then
    local file_content = file:read("*a")
    local table = vim.fn.json_decode(file_content)

    local picker = _init_telescope_picker(table)

    picker:find()
    file:close()
  else
    print(errors.FILE_NOT_FOUND)
  end
end

--TODO
M.remove_reference = function()
  local file_content = _read_file("output.txt")

  if file_content then
    vim.ui.input({ prompt = 'Enter reference key: ' }, function(input)
      if file_content[input] then
        file_content[input] = nil

        local file = io.open("output.txt", "w")

        if file then
          local json = vim.fn.json_encode(file_content)
          file:write(json)
          file:close();
        end
      else
        print(errors.KEY_NOT_FOUND)
      end
    end)
  end
end

return M
