-- ~/.config/yazi/plugins/test.yazi/init.lua
return {
	entry = function(self, args)
		ya.err(args[1]) -- "foo"
		ya.err(args[2]) -- "bar"
	end,
}
