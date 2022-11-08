local success, httpsOrError = xpcall(
	function() require("https") end,
	function(err)
		return err
	end)
if success then
	---@type { request: fun(url: string, options: table): number, string, string }
	---@cast httpsOrError -nil
	return httpsOrError
else
	return {
		request = function(url, options)
			return 418, "ERROR: Chaoshead failed to load its own HTTPS library, and is now pretending to be a teapot "
			.."instead because I couldn't find a fitting status code.\n\n"
			.."If you're a developer, grab a https dynamic library from https://github.com/love2d/lua-https/actions/workflows/build.yml "
			.."and put in the Chaoshead root directory (if you're not a developer, report this as a bug).\n\n"
			..tostring(httpsOrError), ""
		end,
		error = httpsOrError,
	}
end
return {request=function() end}