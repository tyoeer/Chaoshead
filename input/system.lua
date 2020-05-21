local input = {
	modules = {},
}

-- CALLBACKS (all for public use)

function input.inputActivated(name,isCursorBound,group) end
function input.inputDeactivated(name,isCursorBound,group) end

-- ACTIONS

function input.parseButton(selector)
	selector = selector:lower()
	local moduleName, button
	if selector:find("%:") then
		moduleName, button = string.match(selector,"^(%w+)%:%s?(%w-)$")
		local module = input.modules[moduleName]
		b = module:verify(button)
		if b then
			return moduleName, b
		else
			error("Invalid button "..button.." for module "..moduleName.."!")
		end
	else
		for moduleName,module in pairs(input.modules) do
			button = module:verify(selector)
			if button then
				return moduleName,button
			end
		end
		error("Invalid button: "..selector)
	end
end

function input.addTrigger(moduleName, button, action)
	local t = input.modules[moduleName].triggers
	if not t[button] then
		t[button] = {}
	end
	table.insert(t[button], action)
end

--for public use
function input.addAction(action,name,group)
	local parsed = {
		name = name,
		group = group,
		active = false,
	}
	if action.trigger then
		local moduleName, button = input.parseButton(action.trigger)
		parsed.trigger = {
			moduleName = moduleName,
			button = button,
		}
		input.addTrigger(moduleName,button, parsed)
	end
	if action.isCursorBound==nil then
		parsed.isCursorBound = false
	else
		parsed.isCursorBound = action.isCursorBound
	end
end

--for public use
function input.parseActions(actions)
	for group, entries in pairs(actions) do
		for name, action in pairs(entries) do
			input.addAction(action,name,group)
		end
	end
end

-- MODULE

local Module
do
	Module = Class()
	function Module:initialize(buttonVerifier)
		self.aliases = {}
		self.triggers = {}
		self.is = buttonVerifier
	end
	
	function Module:verify(button)
		if self.aliases[button] then
			button = self.aliases[button]
		end
		if self:is(button) then
			return button
		else
			return false
		end
	end
end

-- MODULE WORK

function input.addModule(name,buttonVerifier,aliases)
	input.modules[name] = Module:new(buttonVerifier)
	if aliases then
		for _,alias in ipairs(aliases) do
			input.modules[alias] = input.modules[name]
		end
	end
end

function input.addButtonAlias(module,from,to)
	input.modules[module].aliases[from] = to
end

-- KEYBOARD

do
	input.addModule(
		"keyboard",
		function(b)
			-- this works because love.keyboard.isDown() errors when using an invalid keycode
			-- as of Löve2d 11.3, there's no better way
			return pcall(function() love.keyboard.isDown(b) end)
		end,
		{"key"}
	)

	function input.keypressed(key, scancode, isrepeat)
		input.triggerActivation("keyboard",key)
	end

	function input.keyreleased(key, scancode)
		input.triggerDeactivation("keyboard",key)
	end
end

-- MOUSE

do
	input.addModule(
		"mouse",
		function(b) return pcall(function() love.mouse.isDown(b) end) end,
		nil
	)

	function input.mousepressed(x, y, button, istouch, presses)
		input.triggerActivation("mouse",button)
	end

	function input.mousereleased(x, y, button, istouch, presses)
		input.triggerDeactivation("mouse",button)
	end
	
	input.addButtonAlias("mouse","left",1)
	input.addButtonAlias("mouse","right",2)
	input.addButtonAlias("mouse","middle",3)
end

-- TRIGGER HANDLING

function input.triggerActivation(moduleName,button)
	local t = input.modules[moduleName].triggers[button]
	if t then
		for _,action in ipairs(t) do
			action.active = true
			input.inputActivated(action.name, action.group, action.isCursorBound)
		end
	end
end

function input.triggerDeactivation(moduleName,button)
	local t = input.modules[moduleName].triggers[button]
	if t then
		for _,action in ipairs(t) do
			action.active = false
			input.inputDeactivated(action.name, action.group, action.isCursorBound)
		end
	end
end

return input
