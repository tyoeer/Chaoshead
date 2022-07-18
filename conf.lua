function love.conf(t)
	t.identity = "chaoshead"
	t.console = os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1"
	t.window.resizable = true
	t.window.title = "Chaoshead"
	t.window.width = 1024
	t.window.height = 768
end
