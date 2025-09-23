local Version = require("utils.version")
local Json = require("libs.json")
local Https = require("utils.https")

local CodebergApi = {}

---@class CodebergRelease
---@field assets table
---@field author table
---@field body string
---@field created_at string
---@field draft boolean
---@field hide_archive_links boolean
---@field html_url string Graphical user-facing page for this release
---@field id integer
---@field name string
---@field prerelease boolean
---@field published_at string
---@field tag_name string
---@field tarball_url string
---@field target_commitish string
---@field upload_url string
---@field url string
---@field zipball_url string

function CodebergApi.getHeaders()
	return {
		--["User-Agent"] = "Chaoshead v"..Version.current.." (codeberg.com/tyoeer/Chaoshead/)",
		["accept"] = "application/json",
	}
end

function CodebergApi.getURL(repo,apiPath,queryParams)
	repo = repo or "tyoeer/chaoshead"
	local out = "https://codeberg.org/api/v1/repos/"..repo.."/"..apiPath
	if queryParams then
		out = out.."?"
		local first = true
		for k,v in pairs(queryParams) do
			if not first then
				out = out.."&"
			end
			out=out..k.."="..v
			first = false
		end
	end
	return out
end


---@return number, string, string
function CodebergApi.apiCall(url)
	return Https.request(url, {
		method = "GET",
		headers = CodebergApi.getHeaders()
	})
end

function CodebergApi.api(repo, apiPath, queryParams)
	CodebergApi.error = nil
	local code, body, headers = CodebergApi.apiCall(CodebergApi.getURL(repo, apiPath, queryParams))
	if code==200 then
		local success, data = pcall(Json.decode, body)
		if not success then
			CodebergApi.error = {
				code = code,
				body = body,
				headers = headers
			}
			error("Error parsing return data (check getError() for more info): "..tostring(data))
		end
		return data
	else
		CodebergApi.error = {
			code = code,
			body = body,
			headers = headers
		}
		error("NetworkError: check getError() for more info since Lua only lets us pass string errors :(", 2)
	end
end

function CodebergApi.getError()
	return CodebergApi.error
end
--https://codeberg.org/api/swagger#/repository/repoGetLatestRelease
---@return CodebergRelease? release The release, nil if there wasn't one (no releases)
function CodebergApi.latestRelease(repo)
	local data = CodebergApi.api(repo, "releases/latest")
	return data
end

return CodebergApi