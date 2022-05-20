local global = ...

return function(image, color) --Probably only working with OCIF6 optimized dithering only using images.
	for i = 1, #image[3] do
		if image[3][i] == color and image[4][i] == color then
			image[5][i] = 2
		elseif image[3][i] == color then
			image[5][i] = 1
		elseif image[4][i] == color then
			local bc, fc = image[3][i], image[4][i]
			image[3][i], image[4][i] = fc, bc
			image[6][i] = "▀"
			image[5][i] = 1
		end
	end
end