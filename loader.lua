-- loader.lua
-- Entry point. Fetches UILoader from raw GitHub and executes it.

local RAW_BASE = "https://raw.githubusercontent.com/o6Scripts/main/"

local function fetch(path)
	local ok, result = pcall(function()
		return game:HttpGet(RAW_BASE .. path, true)
	end)
	if not ok or not result then
		error("[Loader] Failed to fetch: " .. path)
	end
	return result
end

local uiloader = fetch("uiloader.lua")
local fn, err = loadstring(uiloader)

if not fn then
	error("[Loader] Parse error in UILoader: " .. tostring(err))
end

fn()
