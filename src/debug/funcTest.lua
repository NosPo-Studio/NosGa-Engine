local function t(...)
	local t = {...}
	local s = ""
	local lastIndex = 1
	
	for i, c in pairs(t) do
		print(i, lastIndex +1)
		
		if lastIndex +1 < i then
			for count = lastIndex +1, i -1 do
				s = s .. "|"
				print(count)
			end
		end
		
		s = s .. tostring(c)
		lastIndex = i
	end
	
	print(s)
end




t("t", nil, nil, nil,  "t")