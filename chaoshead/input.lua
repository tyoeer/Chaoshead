local input = {
	modules = {},
	actions = {},
}

-- CALLBACKS (all for public use)

function input.inputActivated(name,group,isCursorBound) end
function input.inputDeactivated(name,group,isCursorBound) end

-- ACTIONS

function input.parseButton(selector)
	selector = selector:lower()
	local moduleName, button
	if selector:find("%:") then
		moduleName, button = string.match(selector,"^(%w+)%:%s?(%w-)$")
		local module = input.modules[moduleName]
		local b = module:verify(button)
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

function input.parseAction(action)
	local parsed = {
		active = false,
		children = {},
	}
	if type(action)=="table" then
		if action.type=="and" or action.type=="or" or action.type=="nand" or action.type=="nor" then
			parsed.type = action.type
			parsed.count = 0
			parsed.total = #action.triggers
			if action.type=="nand" or action.type=="nor" then
				parsed.active = true
			end
			for _, subAction in ipairs(action.triggers) do
				local sub = input.parseAction(subAction)
				table.insert(parsed.children,sub)
				if sub.active then
					parsed.count = parsed.count + 1
				end
				-- tables are pass-by-reference, so this also updates the same table that the triggers use
				sub.parent = parsed
			end
		elseif action.type=="not" then
			if not action.trigger then
				error(string.format("A not-type action lacks a trigger (without -s)!"))
			end
			parsed.type = action.type
			--if it has a child, it is expected to count
			parsed.count = 1
			parsed.active = true
			local sub = input.parseAction(action.trigger)
			-- tables are pass-by-reference, so this also updates the same table that the triggers use
			sub.parent = parsed
			table.insert(parsed.children,sub)
		elseif action.trigger then
			if action.type then
				error(string.format("An action has both a trigger (without -s) and a non-not type!"))
			end
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
	else
		local moduleName, button = input.parseButton(action)
		parsed.trigger = {
			moduleName = moduleName,
			button = button,
		}
		parsed.isCursorBound = false
		input.addTrigger(moduleName,button, parsed)
	end
	return parsed
end

--for public use
function input.addAction(action,name,group)
	local parsed = input.parseAction(action)
	parsed.group = group
	parsed.name = name
	if not input.actions[group] then
		input.actions[group] = {}
	end
	input.actions[group][name] = parsed
end

--for public use
function input.parseActions(actions)
	for group, entries in pairs(actions) do
		for name, action in pairs(entries) do
			input.addAction(action,name,group)
		end
	end
end

--for public use
function input.isActive(name,group)
	if input.actions[group] then
		if input.actions[group][name] then
			return input.actions[group][name].active
		else
			error(string.format("Invalid name %q in group %q!",name,group))
		end
	else
		error(string.format("Invalid group %q!",group))
	end
end

-- MODULE

local Module
do
	Module = Class("InputModule")
	function Module:initialize(buttonVerifier)
		self.aliases = {}
		self.triggers = {}
		self.is = buttonVerifier
	end
	
	function Module:verify(button)
		if self.aliases[button] then
			button = self.aliases[button]
		end
		if self.is(button) then
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

function input.actionActivated(action)
	action.active = true
	if action.parent then
		local p = action.parent
		p.count = p.count + 1
		if p.type=="or" then
			--this activation stopped it being 0
			if p.count==1 then
				input.actionActivated(p)
			end
		elseif p.type=="and" then
			if p.count == p.total then
				input.actionActivated(p)
			end
		elseif p.type=="nor" then
			--this activation stopped it being 0
			if p.count==1 then
				input.actionDeactivated(p)
			end
		elseif p.type=="nand" then
			if p.count == p.total then
				input.actionDeactivated(p)
			end
		elseif p.type=="not" then
			input.actionDeactivated(p)
		end
	else
		input.inputActivated(action.name, action.group, action.isCursorBound)
	end
end

function input.actionDeactivated(action)
	action.active = false
	if action.parent then
		local p = action.parent
		p.count = p.count - 1
		if p.type=="or" then
			if p.count == 0 then
				input.actionDeactivated(p)
			end
		elseif p.type=="and" then
			--this activation stopped it being the total
			if p.count == p.total-1 then
				input.actionDeactivated(p)
			end
		elseif p.type=="nor" then
			if p.count == 0 then
				input.actionActivated(p)
			end
		elseif p.type=="nand" then
			--this activation stopped it being the total
			if p.count == p.total-1 then
				input.actionActivated(p)
			end
		elseif p.type=="not" then
			input.actionActivated(p)
		end
	else
		input.inputDeactivated(action.name, action.group, action.isCursorBound)
	end
end

function input.triggerActivation(moduleName,button)
	local t = input.modules[moduleName].triggers[button]
	if t then
		for _,action in ipairs(t) do
			input.actionActivated(action)
		end
	end
end

function input.triggerDeactivation(moduleName,button)
	local t = input.modules[moduleName].triggers[button]
	if t then
		for _,action in ipairs(t) do
			input.actionDeactivated(action)
		end
	end
end

return input
