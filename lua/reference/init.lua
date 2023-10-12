local M = {}

local function write_to_file(text)
  local file = io.open("output.txt", "w")

  print(vim.inspect(text))
  if file then
    -- Write data to the file
    local lua_code = tostring(vim.inspect(text))
    file:write(lua_code)

    -- Close the file when you're done
    file:close()
    print("Data has been written to the file.")
  else
    print("Failed to open the file for writing.")
  end
end

M.get_lines = function()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  -- or use api.nvim_buf_get_lines
  local lines = vim.fn.getline(line_start, line_end)

  write_to_file(lines)
end

M.set_lines = function()
  local file = io.open("output.txt", "r")

  if file then
    -- Read the entire file content into a string
    local file_content = file:read("*a")

    -- Close the file
    file:close()

    -- Print or use the content
    print("File content:")
    print(file_content)
  else
    print("Failed to open the file for reading.")
  end
end

M.set_lines()
print(vim.inspect(table.concat({ 'console', 'console' }, '@'))) -- todo read from file
return M
