--[[This function is third party content and just slightly modified.
	Source: <http://lua-users.org/wiki/TableSerialization>
]]
local function tString(tt, indent, done) 
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "[" .. key .. "] = {\n");
        table.insert(sb, tString (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", "[" .. tostring (key) .. "]", tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

return tString