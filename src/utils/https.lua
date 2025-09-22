local success, httpsOrError = xpcall(
	function() return require("https") end,
	function(err)
		return err
	end)
if success then
	return httpsOrError
else
	return {
		request = function(url, options)
			return 418, "ERROR: Chaoshead failed to load its own HTTPS library, and is now pretending to be a teapot "
			.."instead because I couldn't find a fitting status code.\n\n"
			.."If you're a user, report this as a bug.\n\n"
			.."If you're a developer:\n"
			.." - If you're on Windows x32: rename https32.dll to https.dll (you'll have to dispose the old https.dll)\n"
			.." - If you're on Windows x64 or Linux: wut. Something broke, the HTTPS libraries are included in the Git repository.\n"
			.." - If you're on another system (MacOS): "
			.."grab a https dynamic library for your system from https://github.com/love2d/lua-https/actions/workflows/build.yml "
			.."and put in the Chaoshead root directory.\n\n"
			..tostring(httpsOrError), ""
		end,
		error = httpsOrError,
	}
end