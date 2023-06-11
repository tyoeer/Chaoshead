--[[
	made by tyoeer

	----constructor:
		Pool(), Pool:new()
	----functions
		:size()
			returns how many values/items there are in this set
		:has(v)
			returns wether or not v is in the pool
		
		:addAtTop(v)
			adds v at the top of the pool
			returns true upon succes, false if v already exists
		:addAtBottom(v)
			adds v at the top of the pool
			returns true upon succes, false if v already exists
		:add(v)
			alias for :addAtTop(v)
		
		:getTop()
			returns the value at the top of the pool, nil if there is no value there
		:getBottom()
			returns the value at the bottom of the pool, nil if there is no value there
		
		:remove(v)
			removes v from the pool
			returns true upon succes, false if v wasn't in the pool in the first place
		:removeTop()
			removes and returns the value at the top of the pool, returns nil if there's no value there
		:removeBottom()
			removes and returns the value at the bottom of the pool, returns nil if there's no value there
		
		:iterateDownwards()
			iterates over all values in the pool, from top to bottom
			for use in a generic for (for v in pool:iterate do ... end),
		:iterateUpwards()
			iterates over all values in the pool, from bottom to top
			for use in a generic for (for v in pool:iterate do ... end),
		:iterate()
			alias for :iterateUpwards()
]]--

-- Generics don't work yet
-- https://github.com/LuaLS/lua-language-server/issues/734
-- https://github.com/LuaLS/lua-language-server/issues/1861
---@class OrderedSet<T> : Object
local Pool = Class("OrderedSet")

function Pool:initialize()
	self.containerMap = {}
	self.count = 0
	--self.top = nil
	--self.bottom = nil
end

--misc

function Pool:size()
	return self.count
end

function Pool:has(value)
	if self.containerMap[value] then
		return true
	else
		return false
	end
end

--adding elements

---@private
function Pool:addContainer(container)
	self.containerMap[container.value] = container
	self.count = self.count + 1
end

function Pool:addAtTop(value)
	if self.containerMap[value] then
		return false
	else
		local container = {
			value = value,
			--up = nil,
			down = self.top,--the previous top
		}
		if self.top then
			self.top.up = container
		end
		self.top = container
		if not self.bottom then
			self.bottom = container
		end
		self:addContainer(container)
		return true
	end
end

function Pool:addAtBottom(value)
	if self.containerMap[value] then
		return false
	else
		local container = {
			value = value,
			--down = nil,
			up = self.bottom,--the previous bottom
		}
		if self.bottom then
			self.bottom.down = container
		end
		self.bottom = container
		if not self.top then
			self.top = container
		end
		self:addContainer(container)
		return true
	end
end

Pool.add = Pool.addAtTop

--retrieving elements

function Pool:getTop()
	if self.top then
		return self.top.value
	end
end

function Pool:getBottom()
	if self.bottom then
		return self.bottom.value
	end
end

--removing elements

function Pool:remove(value)
	local container = self.containerMap[value]
	if container then
		self:removeContainer(container)
		return true
	else
		return false
	end
end

function Pool:removeContainer(container)
	--removing it from the chain
	local up = container.up
	local down = container.down
	--only check the one we're indexing, if the other is nil the value to be set has to become nil anyway
	if up then up.down = down end
	if down then down.up = up end
	--fix the list ends
	if self.top==container then
		self.top = down
	end
	if self.bottom==container then
		self.bottom = up
	end
	self.containerMap[container.value] = nil
	self.count = self.count - 1
	return container
end

function Pool:removeTop()
	if self.top then
		return self:removeContainer(self.top).value
	end
end

function Pool:removeBottom()
	if self.bottom then
		return self:removeContainer(self.bottom).value
	end
end

--iterators

function Pool:iterateDownwards()
	return self.downwardsIterator, {container = self.top}--, nil
end
function Pool.downwardsIterator(state, _)
	if state.container then
		local old = state.container
		state.container = state.container.down
		return old.value
	end
	--returning no value means returning nil
end

function Pool:iterateUpwards()
	return self.upwardsIterator, {container = self.bottom}--, nil
end
function Pool.upwardsIterator(state, _)
	if state.container then
		local old = state.container
		state.container = state.container.up
		return old.value
	end
	--returning no value means returning nil
end

Pool.iterate = Pool.iterateUpwards

return Pool
