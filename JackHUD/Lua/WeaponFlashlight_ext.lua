
local flash_cbk = WeaponFlashLight.init

function WeaponFlashLight:init(unit)
	flash_cbk(self, unit)
	if JackHUD and JackHUD._data.enable_flashlight_extender then
		self._light:set_spot_angle_end(math.clamp(JackHUD._data.flashlight_angle, 0, 160))
		self._light:set_far_range(JackHUD._data.flashlight_range)
	end
end