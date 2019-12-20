local term = require("term")


local read_handler = {hint = function(line, index)
  line = (line or "")
  local tail = line:sub(index)
  line = line:sub(1, index - 1)
  local path = string.match(line, "[a-zA-Z_][a-zA-Z0-9_.]*$")
  if not path then return nil end
  local suffix = string.match(path, "[^.]+$") or ""
  local prefix = string.sub(path, 1, #path - #suffix)
  local tbl = findTable(env, prefix)
  if not tbl then return nil end
  local keys = {}
  local hints = {}
  findKeys(tbl, keys, string.sub(line, 1, #line - #suffix), suffix)
  for key in pairs(keys) do
    table.insert(hints, key .. tail)
  end
  return hints
end}