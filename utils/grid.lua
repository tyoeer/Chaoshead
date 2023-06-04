---Call this function to get a new grid
return function()
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