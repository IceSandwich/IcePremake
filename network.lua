local exports = {}

function progress(total, current)
	local ratio = current / total;
	ratio = math.min(math.max(ratio, 0), 1);
	local percent = math.floor(ratio * 100);

	local displayWidth = 50
	-- 计算进度的百分比
	local displayIndex = math.floor(ratio * displayWidth);
	-- 计算进度条中已完成的部分
	local bar = string.rep("=", displayIndex) .. string.rep(" ", displayWidth - displayIndex)

	-- 使用 \r 重复输出进度条
	io.write(string.format("\r[%s] %.2f%%", bar, percent))
	io.flush()  -- 确保即时刷新输出
	-- print("Download progress (" .. percent .. "%/100%)")
end

function exports.Download(url, filename)
	print("Download " .. url .. " to " .. filename)

	local result_str, response_code = http.download(url, filename, {
		progress = progress,
	})
	-- local result_str = ""
	-- local response_code = 200
	-- for i = 1, 30 do
	-- 	progress(30, i)
	-- 	os.execute("timeout /t 1 >nul")
	-- end

	print("")
	if response_code ~= 200 then
		print("Failed to download.")
		print("\tResponse code: " .. response_code)
		print("\tResponse: " .. result_str)
		error("Failed to download file.")
	end
end

return exports