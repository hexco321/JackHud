
local _start_tape_loop_original = SecurityCamera._start_tape_loop
local _deactivate_tape_loop_restart_original = SecurityCamera._deactivate_tape_loop_restart
local _deactivate_tape_loop_original = SecurityCamera._deactivate_tape_loop

local on_unit_set_enabled_original = SecurityCamera.on_unit_set_enabled
local generate_cooldown_original = SecurityCamera.generate_cooldown

function SecurityCamera:_start_tape_loop(...)
	_start_tape_loop_original(self, ...)
	managers.gameinfo:event("tape_loop", "start", tostring(self._unit:key()), { unit = self._unit, expire_t = self._tape_loop_end_t + 6 })
end

function SecurityCamera:_deactivate_tape_loop_restart(...)
	managers.gameinfo:event("tape_loop", "stop", tostring(self._unit:key()))
	return _deactivate_tape_loop_restart_original(self, ...)
end

function SecurityCamera:_deactivate_tape_loop(...)
	managers.gameinfo:event("tape_loop", "stop", tostring(self._unit:key()))
	return _deactivate_tape_loop_original(self, ...)
end