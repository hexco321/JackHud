if not JackHUD then
	return
end

local update_original = WeaponLaser.update

function WeaponLaser:update(unit, t, dt, ...)
	update_original(self, unit, t, dt, ...)
	if self._theme_type == "default" then
		local r, g, b = JackHUD._data.laser_color_r, JackHUD._data.laser_color_g, JackHUD._data.laser_color_b
		if JackHUD._data.laser_color_rainbow then
			r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
		end
		self._themes.default = {
			light = Color(r, g, b) * JackHUD._data.laser_light,
			glow = Color(r, g, b) * JackHUD._data.laser_glow,
			brush = Color(JackHUD._data.laser_color_a, r, g, b)
		}
	elseif self._theme_type == "cop_sniper" then
		-- Sniper lasers can be handles here
	elseif self._theme_type == "turret_module_active" then
		-- Turret lasers can be handles here
	elseif self._theme_type == "turret_module_rearming" then
		-- Turret lasers can be handles here
	elseif self._theme_type == "turret_module_mad" then
		-- Turret lasers can be handles here
	else
		log("JackHUD - Ignoring unknown laser theme: \"" .. self._theme_type .. "\".")
	end
	self:set_color_by_theme(self._theme_type)
end
