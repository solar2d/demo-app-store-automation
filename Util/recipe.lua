
local root = os.getenv('GITHUB_WORKSPACE') or os.getenv('WORKSPACE')

return {
	appName = "Solar2Demo",
	platform = "ios",
	appVersion = os.getenv('APP_VERSION') or "1.0",
	projectPath = root .. "/Project",
	dstPath = root .. '/Util',
	certificatePath = root .. "/Util/distribution.mobileprovision",
	customTemplate = "-angle",
}
