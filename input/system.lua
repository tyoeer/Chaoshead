local input = {
	triggers = {}
}

-- KEYBOARD

input.triggers.keyboard = {}

function input.keypressed(key, scancode, isrepeat)
	if input.triggers.keyboard[key] then
		for _,v in ipairs(input.triggers.keyboard[key]) do
			input.activate(v)
		end
	end
end

function input.keyreleased(key, scancode)
	if input.triggers.keyboard[key] then
		for _,v in ipairs(input.triggers.keyboard[key]) do
			input.deactivate(v)
		end
	end
end

function input.isKey(keycode)
	-- this works because love.keyboard.isDown() errors when using an invalid keycode
	-- as of Löve2d 11.3, there's no better way
	local success = pcall(function() love.keyboard.isDown(keycode) end)
	return success
end

-- MAIN

function input.addTrigger(type,button, data)
	if not input.triggers[type][button] then
		input.triggers[type][button] = {}
	end
	table.insert(input.triggers[type][button], data)
end

function input.parseButton(selector)
	selector = selector:lower()
	local type, button
	if selector:find("%:") then
		type, button = string.match(selector,"^(%w+)%:%s?(%w-)$")
		if type=="key" or type=="keyboard" then
			type = "keyboard"
			if not input.isKey(button) then
				error(button.." is not a valid key!")
			end
		end
	else
		button = selector
		if input.isKey(button) then
			type = "keyboard"
		else
			error("Couldn't find valid input device for: "..button)
		end
	end
	return type, button
end

function input.addAction(action,name,group)
	local parsed = {
		name = name,
		group = group,
		active = false,
	}
	if action.trigger then
		local type, button = input.parseButton(action.trigger)
		parsed.trigger = {
			type = type,
			button = button,
		}
		input.addTrigger(type,button, parsed)
	end
	if action.isCursorBound==nil then
		parsed.isCursorBound = false
	else
		parsed.isCursorBound = action.isCursorBound
	end
end

function input.parseActions(actions)
	for group, entries in pairs(actions) do
		for name, action in pairs(entries) do
			input.addAction(action,name,group)
		end
	end
end

-- CALLBACKS

function input.actionActivated(name,isCursorBound,group) end
function input.actionDeactivated(name,isCursorBound,group) end

-- MISC

function input.activate(action)
	action.active = true
	input.actionActivated(action.name, action.group, action.isCursorBound)
end

function input.deactivate(action)
	action.active = false
	input.actionDeactivated(action.name, action.group, action.isCursorBound)
end


return input
