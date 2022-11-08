local Version = require("utils.version")
local Json = require("libs.json")
local Https = require("utils.https")

local G = {}

---@alias Headers table<string, string>

---@class User
---@field name ?string|nil
---@field email ?string|nil
---@field login string
---@field id integer
---@field node_id string
---@field avatar_url string
---@field gravatar_id string|nil
---@field url string
---@field html_url string
---@field followers_url string
---@field following_url string
---@field gists_url string
---@field starred_url string
---@field subscriptions_url string
---@field organizations_url string
---@field repos_url string
---@field events_url string
---@field received_events_url string
---@field type string
---@field site_admin boolean
---@field starred_at ?string

---@class ReleaseAsset
---@field url string
---@field browser_download_url string
---@field id integer
---@field node_id string
---@field name string The file name of the asset.
---@field label string|nil
---@field state "uploaded"|"open" State of the release asset.
---@field content_type string
---@field size integer
---@field download_count integer
---@field created_at string
---@field updated_at string
---@field uploader User

---@class Reactions
---@field url string
---@field total_count integer
-- ---@field +1 integer
-- ---@field -1 integer
---@field laugh integer
---@field confused integer
---@field heart integer
---@field hooray integer
---@field eyes integer
---@field rocket integer

---@class Release
---@field url string
---@field html_url string
---@field assets_url string
---@field upload_url string
---@field tarball_url string|nil
---@field zipball_url string|nil
---@field id integer
---@field node_id string
---@field tag_name string The name of the tag.
---@field target_commitish string Specifies the commitish value that determines where the Git tag is created from.
---@field name string|nil
---@field body ?string|nil
---@field draft boolean true to create a draft (unpublished) release, false to create a published one.
---@field prerelease boolean Whether to identify the release as a prerelease or a full release.
---@field created_at string
---@field published_at string|nil
---@field author User
---@field assets ReleaseAsset[]
---@field body_html ?string
---@field body_text ?string
---@field mentions_count ?integer
---@field discussion_url ?string The URL of the release discussion.
---@field reactions Reactions

function G.getHeaders()
	return {
		["User-Agent"] = "Chaoshead v"..Version.current.." (github.com/tyoeer/Chaoshead/)",
		["accept"] = "application/vnd.github+json",
	}
end

function G.getURL(repo,apiPath,queryParams)
	repo = repo or "tyoeer/chaoshead"
	local out = "https://api.github.com/repos/"..repo.."/"..apiPath
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
function G.apiCall(url)
	return Https.request(url, {
		method = "GET",
		headers = G.getHeaders()
	})
end

function G.api(repo, apiPath, queryParams)
	G.error = nil
	local code, body, headers = G.apiCall(G.getURL(repo, apiPath, queryParams))
	if code==200 then
		local data = Json.decode(body)
		return data
	else
		G.error = {
			code = code,
			body = body,
			headers = headers
		}
		error("NetworkError: check getError() for more info since Lua only lets us pass string errors :(", 2)
	end
end

function G.getError()
	return G.error
end
--https://docs.github.com/en/rest/releases/releases#list-releases
---@return Release? release The release, nil if there wasn't one (no releases)
function G.latestRelease(repo)
	local data = G.api(repo, "releases", {per_page=1})
	return data[1]
end

return G