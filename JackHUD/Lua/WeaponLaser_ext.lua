
local update_original = WeaponLaser.update

function WeaponLaser:update(unit, t, dt, ...)
	update_original(self, unit, t, dt, ...)
	if not self._default_theme_original then self._default_theme_original = self._themes.default end
	if self._theme_type == "default" then
		if JackHUD._data.enable_laser_options then
			local r, g, b = JackHUD._data.laser_color_r, JackHUD._data.laser_color_g, JackHUD._data.laser_color_b
			if JackHUD._data.laser_color_rainbow then
				r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
			end
			self._themes.default = {
				light = Color(r, g, b) * JackHUD._data.laser_light,
				glow = Color(r, g, b) * JackHUD._data.laser_glow,
				brush = Color(JackHUD._data.laser_color_a, r, g, b)
			}
		else
			self._themes.default = self._default_theme_original
		end
	elseif self._theme_type == "cop_sniper" then
		-- Sniper lasers could be handled here
	elseif self._theme_type == "turret_module_active" then
		-- Turret lasers could be handled here
	elseif self._theme_type == "turret_module_rearming" then
		-- Turret lasers could be handled here
	elseif self._theme_type == "turret_module_mad" then
		-- Turret lasers could be handled here
	else
		log("JackHUD - Ignoring unknown laser theme: \"" .. self._theme_type .. "\".")
	end
	self:set_color_by_theme(self._theme_type)
end
