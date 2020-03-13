local ds={}

--[[grid

	This structure is for a 2d grid-like datastructure.
	It doesn't check if indexes are integers, so other values will probably work to if you use the right method.
	Positions are given as (x,y) in this commentation
	
----interaction methods
	
	table(x,y[,value]) {uses table:set/table:get}
		returns the value at (x,y) if value==nil,
		sets (x,y) to value otherwise
	
	table:set(x,y,value) {uses raw access}
		sets (x,y) to value
	table:get(x,y) {uses raw access}
		returns the value at (x,y)
	
	table[x][y] {redirects to raw access}
		raw access redirect
		WARNING: x will choose the values used for structure-functioning over data access, so be carefull
		the structure-functioning values are: call, set, get, data
	
----internal information
	
	First index is X(which column), second index is Y(which row).
	
]]--
function ds.grid()
	local t={}
	
	t.data={}
	
	
	--set the functions
	
	function t:set(x,y,value)
		self.data[x][y]=value
	end
	
	function t:get(x,y)
		return self.data[x][y]
	end
	
	--to be metatabled
	function t:call(x,y,value)
		if value==nil then
			return self:get(x,y)
		else
			self:set(x,y,value)
		end
	end
	
	
	--set the metatables
	
	--main metatable
	setmetatable(t,{
		__index=t.data,
		__call=t.call
	})
	
	--data metatable (with sub-metatable)
	setmetatable(t.data,{
		__index=function(table,key)
			--add an empty table with the column metatable
			rawset(table,key,setmetatable({},{
				--[[__index=function(table,key)
					--add an empty table
					rawset(table,key,{})
					return table[key]
				end]]--
			}))
			return rawget(table,key)
		end
	})
	
	return t
end

--[[stack

	Typical FILO Data structure.

----interaction methods

	:pull()
		returns the value at the top of the stack, nil if the stack is empty
	:pop()
		removes the value at the top of the stack, returns the same as pull()
	:push(value)
		pushes value to the top of the stack
	
	:new([t])
		makes a new stack, from t if given
	()/calling the table itself/__call
		same as :new()
]]--
do
	ds.stack = {
		new = function(self,o)
			o = o or {}
			o.top = 0
			setmetatable(o,ds.stack)
			return o
		end,
		
		top = 0,
		
		pull = function(self)
			return self.top ~= 0 and self.top.value or nil
		end,
		pop = function(self)
			out = self.top ~= 0 and self.top.value or nil
			self.top = self.top.next
			return out
		end,
		push = function(self,value)
			self.top = {
				next = self.top,
				value = value
			}
		end,
	}
	ds.stack.__call = ds.stack.new
	ds.stack.__index = ds.stack
	setmetatable(ds.stack,{
		__call = ds.stack.new
	})
	--table.print(ds.stack)
end


return ds
