#!/usr/bin/lua
local options = {
    [" Lock"] = "swaylock --color '#1a1b26'",
    [" Shut down"] = "systemctl poweroff",
    [" Reboot"] = "systemctl reboot",
    ["﫼 Log out"] = "swaymsg exit",
    ["鈴 Suspend"] = "systemctl suspend",
    [" Hibernate"] = "systemctl hibernate",
}

local options_string = ""
local length = 0
for key, _ in pairs(options) do
    options_string = options_string .. key .. "\n"
    length = length + 1
end
options_string = options_string:sub(1, -2)

local f = assert(
    io.popen(
        "echo -e '"
        .. options_string
        ..
        "' | wofi --dmenu --location 6 --yoffset -30 --insensitive --prompt 'Power menu' --width 300 --style $HOME/.config/wofi/style.css --lines "
        .. length,
        "r"
    )
)
local s = assert(f:read("*a"))
s = string.gsub(s, "^%s+", "")
s = string.gsub(s, "%s+$", "")
s = string.gsub(s, "[\n]+", " ")
f:close()

os.execute(options[s])
