return {
	entry = function(_, args)
		-- Define vars
		local shell_value, value_string, block, confirm, orphan =
			os.getenv("SHELL"):match(".*/(.*)") or "sh", "", false, false, false

		-- Parse command flags
		for idx, item in ipairs(args) do
			block = item == "--block" and true
			confirm = item == "--confirm" and true
			orphan = item == "--orphan" and true
			if idx ~= 1 and not item:match("^%-%-") then
				value_string = value_string .. " " .. item
			end
		end

		-- If custom shell is chosen, use it
		if args[1] and not args[1]:match("auto") and not args[1]:match("^%-%-") then
			shell_value = args[1]
		end

		-- Change prompt title if block is selected
		local prompt_title = block and shell_value:gsub("^%l", string.upper) .. " Shell (block):"
			or shell_value:gsub("^%l", string.upper) .. " Shell:"

		-- Display prompt if confirm is not selected
		local value, event
		if not confirm then
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
		if shell_value == "fish" then
			exec_string = "args=$@;"
				.. "fish"
				.. " -ic "
				.. string.format(
					'"set -l argv $args ; set -l ARGS $args ; set -l HOV $0 ; set -l 0 $0 ; %s"',
					value:gsub("%$", "\\$")
				)
		elseif shell_value == "zsh" or shell_value == "bash" then
			exec_string = "args=$@;"
				.. shell_value
				.. " -ic "
				.. string.format('"set $args; ARGS=$args; HOV=$0; %s"', value:gsub("%$", "\\$"))
		else
			exec_string = shell_value .. " -i -c " .. ya.quote(value)
		end

		if event == 1 then
			ya.manager_emit("shell", {
				exec_string,
				block = block,
				orphan = orphan,
				confirm = true,
			})
		end
	end,
}
