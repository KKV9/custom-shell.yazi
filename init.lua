local selected_or_hovered = ya.sync(function()
	local tab, paths, first_path = cx.active, "", ""
	for _, u in pairs(tab.selected) do
		if paths == "" then
			paths = ya.quote(tostring(u))
			first_path = paths
		else
			paths = paths .. " " .. ya.quote(tostring(u))
		end
	end
	if paths == "" and tab.current.hovered then
		paths = ya.quote(tostring(tab.current.hovered.url))
		first_path = paths
	end
	return paths, first_path
end)

return {
	entry = function(_, args)
		-- Define vars
		local shell_value, value_string, is_block, is_confirm, is_orphan, is_drop, is_windows =
			"", "", false, false, false, false, ya.target_os() == "windows"

		if is_windows then
			shell_value = "powershell"
		else
			shell_value = os.getenv("SHELL"):match(".*/(.*)") or "sh"
		end

		-- Parse command flags
		for idx, item in ipairs(args) do
			if item == "--block" then
				is_block = true
			elseif item == "--confirm" then
				is_confirm = true
			elseif item == "--orphan" then
				is_orphan = true
			-- Drop to shell - supports fish only for now
			elseif item == "--drop" and shell_value == "fish" then
				is_drop = true
				is_block = true
				is_confirm = true
			end
			if idx ~= 1 and not item:match("^%-%-") then
				value_string = value_string .. " " .. item
			end
		end

		local selected_files, first_selected_file = selected_or_hovered()

		-- If custom shell is chosen, use it
		if args[1] and not args[1]:match("auto") and not args[1]:match("^%-%-") then
			shell_value = args[1]
		end

		-- Change prompt title if block is selected
		local prompt_title = is_block and shell_value:gsub("^%l", string.upper) .. " Shell (block):"
			or shell_value:gsub("^%l", string.upper) .. " Shell:"

		-- Display prompt if confirm is not selected
		local value, event
		if not is_confirm then
			value, event = ya.input({
				title = prompt_title,
				value = value_string,
				position = { "top-center", y = 3, w = 80 },
			})
		else
			value = value_string
			event = 1
		end

		-- Execute
		local exec_string
		if is_drop and shell_value == "fish" then
			exec_string = shell_value .. " -C "
		else
			exec_string = shell_value .. " -i -c "
		end
		if shell_value == "fish" then
			exec_string = exec_string
				.. string.format(
					'"set -g 0 %s;set -g argv %s; %s"',
					first_selected_file,
					selected_files,
					value:gsub("%$", "\\$"):gsub('"', '\\"')
				)
		elseif
			shell_value == "zsh"
			or shell_value == "bash"
			or shell_value == "ksh"
			or shell_value == "nsh"
			or shell_value == "osh"
			or shell_value == "mksh"
			or shell_value == "pdksh"
			or shell_value == "yash"
			or shell_value == "dash"
			or shell_value == "sh"
		then
			exec_string = exec_string
				.. string.format(
					'"%s; exit" %s %s',
					value:gsub("%$", "\\$"):gsub('"', '\\"'),
					first_selected_file,
					selected_files
				)
		elseif shell_value == "powershell" or shell_value == "pwsh" then
			exec_string = shell_value .. " -Command " .. ya.quote(value)
		else
			exec_string = exec_string .. ya.quote(value)
		end

		if is_drop and shell_value == "fish" then
			exec_string = exec_string .. ";exit 0"
		end

		if event == 1 then
			ya.manager_emit("shell", {
				exec_string,
				block = is_block,
				orphan = is_orphan,
				confirm = true,
			})
		end
	end,
}
