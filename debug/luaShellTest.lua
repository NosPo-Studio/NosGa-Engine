--[[
	This is a fork of the OpenOS LUA shell included in OpenComputers.
	There are made some changes to fit into the NosGa Engine.
	
	Original source code repo: <https://github.com/MightyPirates/OpenComputers/tree/master-MC1.12>.
	NosGa Engine: <https://github.com/NosPo-Studio/NosGa-Engine>.
	
	OpenComputers Copyright (c) 2013-2015 Florian "Sangar" Nücke
	LUA shell (NosGa version) (c) 2019 NosPo Studio

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.	
]]

local package = require("package")
local term = require("term")

local function optrequire(...)
  local success, module = pcall(require, ...)
  if success then
    return module
  end
end

local env -- forward declare for binding in metamethod
env = setmetatable({}, {
  __index = function(_, k)
    _ENV[k] = _ENV[k] or optrequire(k)
    return _ENV[k]
  end,
  __pairs = function(t)
    return function(_, key)
      local k, v = next(t, key)
      if not k and t == env then
        t = _ENV
        k, v = next(t)
      end
      if not k and t == _ENV then
        t = package.loaded
        k, v = next(t)
      end
      return k, v
    end
  end,
})
env._PROMPT = tostring(env._PROMPT or "\27[32mlua> \27[37m")

local function findTable(t, path)
  if type(t) ~= "table" then return nil end
  if not path or #path == 0 then return t end
  local name = string.match(path, "[^.]+")
  for k, v in pairs(t) do
    if k == name then
      return findTable(v, string.sub(path, #name + 2))
    end
  end
  local mt = getmetatable(t)
  if t == env then mt = {__index=_ENV} end
  if mt then
    return findTable(mt.__index, path)
  end
  return nil
end

local function findKeys(t, r, prefix, name)
  if type(t) ~= "table" then return end
  for k, v in pairs(t) do
    if type(k) == "string" and string.match(k, "^"..name) then
      local postfix = ""
      if type(v) == "function" then postfix = "()"
      elseif type(v) == "table" and getmetatable(v) and getmetatable(v).__call then postfix = "()"
      elseif type(v) == "table" then postfix = "."
      end
      r[prefix..k..postfix] = true
    end
  end
  local mt = getmetatable(t)
  if t == env then mt = {__index=_ENV} end
  if mt then
    return findKeys(mt.__index, r, prefix, name)
  end
end

local read_handler = {hint = function(line, index)
  
  io.write("\n" .. line .. "\n")
  io.write("\n" .. index .. "\n")
  
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
  
  io.write("\n" .. require("serialization").serialize(hints) .. "\n")
  
  return hints
end}

io.write("\27[37m".._VERSION .. " Copyright (C) 1994-2017 Lua.org, PUC-Rio\n")
io.write("\27[33mEnter a statement and hit enter to evaluate it.\n")
io.write("Prefix an expression with '=' to show its value.\n")
io.write("Press Ctrl+D to exit the interpreter.\n\27[37m")

while term.isAvailable() do
  io.write(env._PROMPT)
  local command = term.read(read_handler)
  io.write("\n" .. command .. "\n")
  if not command then -- eof
    return
  end
  local code, reason
  if string.sub(command, 1, 1) == "=" then
    code, reason = load("return " .. string.sub(command, 2), "=stdin", "t", env)
  else
    code, reason = load("return " .. command, "=stdin", "t", env)
    if not code then
      code, reason = load(command, "=stdin", "t", env)
    end
  end
  if code then
    local result = table.pack(xpcall(code, debug.traceback))
    if not result[1] then
      if type(result[2]) == "table" and result[2].reason == "terminated" then
        os.exit(result[2].code)
      end
      io.stderr:write(tostring(result[2]) .. "\n")
    else
      local ok, why = pcall(function()
        for i = 2, result.n do
          io.write(require("serialization").serialize(result[i], true) .. "\t")
        end
      end)
      if not ok then
        io.stderr:write("crashed serializing result: ", tostring(why))
      end
      if term.getCursor() > 1 then
        io.write("\n")
      end
    end
  else
    io.stderr:write(tostring(reason) .. "\n")
  end
end
