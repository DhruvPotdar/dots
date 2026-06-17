-- screenshots.lua — Screenshot utilities (pure Lua, grim/slurp backends)

local home = os.getenv("HOME")

local screenshots = {}

local function exec(cmd)
	hl.exec_cmd(cmd)
end

local function pictures_dir()
	local handle = io.popen("xdg-user-dir PICTURES 2>/dev/null")
	if handle then
		local dir = handle:read("*l")
		handle:close()
		if dir and dir ~= "" then
			return dir
		end
	end
	return home .. "/Pictures"
end

local function screenshots_dir()
	return pictures_dir() .. "/Screenshots"
end

local function timestamp()
	return os.date("%Y-%m-%d_%H.%M.%S")
end


function screenshots.full_to_swappy()
	exec("grim - | swappy -f -")
end

function screenshots.region_to_clipboard()
	exec("bash -c 'geom=$(slurp -w 0 2>/dev/null) && [ -n \"$geom\" ] && grim -g \"$geom\" - | wl-copy'")
end

function screenshots.region_to_swappy()
	exec("bash -c 'geom=$(slurp -w 0 2>/dev/null) && [ -n \"$geom\" ] && grim -g \"$geom\" - | swappy -f -'")
end

function screenshots.full_save()
	local dir = screenshots_dir()
	exec(string.format('mkdir -p "%s" && grim "%s/Screenshot_%s.png"', dir, dir, timestamp()))
end

function screenshots.full_to_clipboard()
	exec("grim - | wl-copy")
end

function screenshots.snip_to_search()
	exec(
		[[bash -c 'geom=$(slurp 2>/dev/null) && [ -n "$geom" ] && grim -g "$geom" /tmp/image.png && imageLink=$(curl -sF files[]=@/tmp/image.png '"'"'https://uguu.se/upload'"'"' | jq -r '"'"'.files[0].url'"'"') && xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}" && rm /tmp/image.png']]
	)
end

function screenshots.ocr()
	exec(
		[[bash -c 'geom=$(slurp 2>/dev/null) && [ -n "$geom" ] && grim -g "$geom" /tmp/ocr_image.png && tesseract /tmp/ocr_image.png stdout -l $(tesseract --list-langs | awk '"'"'NR>1{print $1}'"'"' | tr '"'"'\n'"'"' '"'"'+'"'"' | sed '"'"'s/\+$//'"'"') | wl-copy && rm /tmp/ocr_image.png']]
	)
end

function screenshots.bind()
	hl.bind("Print", function()
		screenshots.full_to_swappy()
	end, { locked = true })

	hl.bind("SUPER + SHIFT + S", function()
		screenshots.region_to_clipboard()
	end, { description = "Screenshot region to clipboard" })

	hl.bind("SUPER + SHIFT + E", function()
		screenshots.region_to_swappy()
	end, { description = "Screenshot region to editor" })

	hl.bind("CTRL + Print", function()
		screenshots.full_save()
	end, { locked = true, non_consuming = true })

	hl.bind("CTRL + Print", function()
		screenshots.full_to_clipboard()
	end, { locked = true, non_consuming = true })

	hl.bind("SUPER + SHIFT + A", function()
		screenshots.snip_to_search()
	end)

	hl.bind("SUPER + SHIFT + X", function()
		screenshots.ocr()
	end)
end

return screenshots
