if not JackHUD then
	return
end

local on_equip_original = NewRaycastWeaponBase.on_equip
local toggle_gadget_original = NewRaycastWeaponBase.toggle_gadget

function NewRaycastWeaponBase:on_equip()
	on_equip_original(self)
	self:set_gadget_on(JackHUD._data.remember_gadget_state and self._stored_gadget_on or 0, false)
end

function NewRaycastWeaponBase:toggle_gadget()
	if toggle_gadget_original(self) then
		self._stored_gadget_on = self._gadget_on
		return true
	end
end
