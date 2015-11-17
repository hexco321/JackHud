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