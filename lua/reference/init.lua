local M = {}

-- local table = { one = 'test2 text3 texst 4' }


local function write_to_file(key, text)
  local file_read = io.open("output.txt", "r+")
  local table = {}

  if file_read then
    local file_content = file_read:read("*a")
    file_read:close()

    local file_write = io.open("output.txt", "w")

    if file_content and file_content[key] == nil then
      local current_content = vim.fn.json_decode(file_content)
      current_content[key] = text
      table = current_content
    else
      if table[key] == nil then
        print('setva', key, text)
        table[key] = text
      end
    end

    local json = vim.fn.json_encode(table)
    print(vim.inspect(json), 'json')

    file_write:write(json);
    file_write:close();

    -- Close the file when you're done
    print("Data has been written to the file.")
  else
    print("Failed does not exist.")
  end
end

M.get_lines = function(key)
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  -- or use api.nvim_buf_get_lines
  local lines = vim.fn.getline(line_start, line_end)

  write_to_file(key, lines)
end

M.set_lines = function(key)
  local file = io.open("output.txt", "r")

  if file then
    -- Read the entire file content into a string
    local file_content = file:read("*a")
    local table = vim.fn.json_decode(file_content)

    -- Close the file
    file:close()

    if table[key] then
      local cursor_pos = vim.api.nvim_win_get_cursor(0)[1]
      print(cursor_pos, 'cursor_pos')
      vim.api.nvim_buf_set_text(0, cursor_pos, 0, 0, 0, table[key])
    end
    -- Print or use the content
    print("File content:")
    print(file_content)
  else
    print("Failed to open the file for reading.")
  end
end

-- M.set_lines({ 'console', 'console', 'console' })
-- print(vim.inspect(table.concat({ 'console', 'console' }, '@'))) -- todo read from file
return M
