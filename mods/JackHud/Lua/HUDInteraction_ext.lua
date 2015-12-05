if not JackHUD then
	return
end

local init_original = HUDInteraction.init
local show_interaction_bar_original = HUDInteraction.show_interaction_bar
local set_interaction_bar_width_original = HUDInteraction.set_interaction_bar_width
local hide_interaction_bar_original = HUDInteraction.hide_interaction_bar
local destroy_original = HUDInteraction.destroy

function HUDInteraction:init(hud, child_name)
	init_original(self, hud, child_name)
	self._interact_timer_text = self._hud_panel:text({
		name = "interact_timer_text",
		visible = false,
		text = "",
		valign = "center",
		align = "center",
		layer = 2,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.hud_present.text_size + 8,
		h = 64
	})
	self._interact_timer_text:set_y(self._hud_panel:h() / 2)
--[[
	for i = 1, 4 do
		self["_bgtext" .. i] = self._hud_panel:text({
			name = "bgtext" .. i,
			visible = false,
			text = "",
			valign = "center",
			align = "center",
			layer = 1,
			color = Color.black,
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.hud_present.text_size + 8,
			h = 64
		})
	end
	self._bgtext1:set_y(self._hud_panel:h() / 2 - 1)
	self._bgtext1:set_x(self._bgtext1:x() - 1)
	self._bgtext2:set_y(self._hud_panel:h() / 2 + 1)
	self._bgtext2:set_x(self._bgtext2:x() + 1)
	self._bgtext3:set_y(self._hud_panel:h() / 2 + 1)
	self._bgtext3:set_x(self._bgtext3:x() - 1)
	self._bgtext4:set_y(self._hud_panel:h() / 2 - 1)
	self._bgtext4:set_x(self._bgtext4:x() + 1)
]]
	self._start_color = Color(1, 1, 1, 0)
end

function HUDInteraction:show_interaction_bar(current, total)
	show_interaction_bar_original(self, current, total)
	self._interact_circle:set_visible(true)
	self._interact_timer_text:set_visible(true)
--[[
	for i = 1, 4 do
		self["_bgtext" .. i]:set_visible(true)
	end
]]
end

function HUDInteraction:set_interaction_bar_width(current, total)
	set_interaction_bar_width_original(self, current, total)
	if not self._interact_timer_text then
		return
	end
	local text = string.format("%.1f", total - current >= 0 and total - current or 0) .. "s"
	self._interact_timer_text:set_text(text)
	self._interact_timer_text:set_color(Color(self._start_color.a + (current / total), self._start_color.r + (current / total), self._start_color.g + (current / total), self._start_color.b + (current / total)))
--[[
	for i = 1, 4 do
		self["_bgtext" .. i]:set_text(text)
	end
]]
end

function HUDInteraction:hide_interaction_bar(complete)
	hide_interaction_bar_original(self, complete)
	self._interact_timer_text:set_visible(false)
--[[
	for i = 1, 4 do
		self["_bgtext" .. i]:set_visible(false)
	end
]]
end

function HUDInteraction:destroy()
	self._hud_panel:remove(self._hud_panel:child("interact_timer_text"))
--[[
	self._hud_panel:remove(self._hud_panel:child("bgtext1"))
	self._hud_panel:remove(self._hud_panel:child("bgtext2"))
	self._hud_panel:remove(self._hud_panel:child("bgtext3"))
	self._hud_panel:remove(self._hud_panel:child("bgtext4"))
]]
	destroy_original(self)
end
