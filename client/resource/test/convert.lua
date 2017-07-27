require"lfs"

local convert = function(str)
	local f_s, f_e = string.find(str, " function[ (].*%(.*%)")

	if f_s then 
		if string.sub(str, f_s, f_s) ~= "f" then
			f_s = f_s + 1
		end
	else
		f_s, f_e = string.find(str, "function[ (].*%(.*%)")

		if not f_s then return false end
	end

	local function_str = string.sub(str, f_s, f_e)

	local _, mid_s, mid_e

	_, mid_s = string.find(function_str, "function")
	_, mid_e = string.find(function_str, "%(")

	local middle_str = string.sub(function_str, mid_s + 1, mid_e - 1)

	middle_str = string.gsub(middle_str, "^%s*(.-)%s*$", "%1")

	if middle_str == "" or string.find(middle_str, "[^%a%d_.:]+") then return false end

	local forward_str = string.sub(str, 1, f_s - 1)

	local colon_s, colon_e = string.find(middle_str, "%:")
	if colon_s then
		middle_str = string.gsub(middle_str, "%:", "%.", 1)

		local para_str = string.sub(str, mid_e + f_s, f_e - 1)
		para_str = string.gsub(para_str, "^%s*(.-)%s*$", "%1")

		local local_s, local_e = string.find(forward_str, "local")
		if local_s then
			forward_str = string.format("%s%s\n%s", forward_str, middle_str, string.sub(forward_str, 1, local_s - 1))
		end

		if para_str == "" then
			return true, string.format("%s%s = function(self)\n", forward_str, middle_str)
		end

		return true, string.format("%s%s = function(self, %s%s\n", forward_str, middle_str, para_str, string.sub(str, f_e))
	end

	local local_s, local_e = string.find(forward_str, "local")
	if local_s then
		forward_str = string.format("%s%s\n%s", forward_str, middle_str, string.sub(forward_str, 1, local_s - 1))
	end

	return true, string.format("%s%s = function%s\n", forward_str, middle_str, string.sub(str, mid_e + f_s - 1))
end

local findindir
findindir = function(path, wefind, intofolder)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." and file ~= ".svn" and file ~= "game_config" then
			local dir = path .."\\".. file
			if string.find(file, wefind) ~= nil then
				local tmp_file = io.open(dir, "r")

				local data = tmp_file:read("*a")

				tmp_file:close()

				local tmp_data = ""
				local index, st, ed = 1, 0, 0

				while(true) do
					st, ed = string.find(data, "\n", index)
					if st then
						local str = string.sub(data, index, ed - 1)

						local need_convert, replace_str = convert(str)

						tmp_data = need_convert and tmp_data .. replace_str or tmp_data .. str .. "\n"

						index = ed + 1
					else
						tmp_data = tmp_data .. string.sub(data, index)
						break
					end
				end

				tmp_file = io.open(dir, "w")
				tmp_file:write(tmp_data)
				tmp_file:close()
			end

			local attr = lfs.attributes(dir)
			if attr.mode == "directory" and intofolder then
				findindir(dir, wefind, intofolder)
			end
		end
	end
end

local tb = {}

tb.convert = function(dir, recursion)
	findindir(dir, ".lua", recursion)
	print("==========convert finished!!!")
end

return tb