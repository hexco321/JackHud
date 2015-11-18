if not JackHUD then
	return
end

local init_original = HUDAssaultCorner.init
function HUDAssaultCorner:init(...)
	init_original(self, ...)
	if self._hud_panel:child("hostages_panel") then
		self:_hide_hostages()
	end
end

function HUDAssaultCorner:_show_hostages()
end

local _start_assault_original = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)

	-- Hack for Enhanced Assault Banner
	-- this allows the LocationManager to reroute the call for the assault banner text.
	if Network:is_server() then
		for i = 1, 1000 do
			if text_list[i] == "hud_assault_assault" then
				text_list[i] = "hud_assault_enhanced"
			end
		end
	end

	return _start_assault_original(self, text_list)
end