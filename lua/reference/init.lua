local M = {}

local errors = {
  FILE_NOT_FOUND = "File does not exist!",
  KEY_EXIST = "Key exist!",
  NO_DATA = "No data to write.",
  KEY_NOT_FOUND = "Key does not exist!",
  FAILED_TO_CREATE = "Failed to create file!"
}

local function _parse_text(key, text)
  local file = io.open("output.txt", "r")
  local data = {}

  if file then
    local file_content = file:read("*a")
    file:close()

    if file_content and file_content ~= '' then
      if file_content[key] == nil then
        local current_content = vim.fn.json_decode(file_content)
        current_content[key] = text
        data = current_content
      else
        print(errors.KEY_EXIST)
      end
    else
      data[key] = text
    end
  end

  return data;
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

M.get_reference = function(key)
  local file = io.open("output.txt", "r")

  if file then
    local file_content = file:read("*a")
    local table = vim.fn.json_decode(file_content)

    file:close()
    -- TODO use telescope for this
    if table[key] then
      local cursor_pos = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_text(0, cursor_pos - 1, 0, cursor_pos - 1, 0, table[key])
    else
      print(errors.KEY_NOT_FOUND)
    end
  else
    print(errors.FILE_NOT_FOUND)
  end
end

return M
