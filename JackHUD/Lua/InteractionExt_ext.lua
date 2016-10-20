	
local set_tweak_data_original = BaseInteractionExt.set_tweak_data

function BaseInteractionExt:set_tweak_data(...)
	local old_tweak = self.tweak_data
	local was_active = self:active()
	
	set_tweak_data_original(self, ...)
	
	if was_active and self:active() and self.tweak_data ~= old_tweak then
		managers.interaction:remove_unit_clbk(self._unit, old_tweak)
		managers.interaction:add_unit_clbk(self._unit)
	end

--[[
	if self:active() then
		managers.interaction:remove_unit_clbk(self._unit)
	end
	
	set_tweak_data_original(self, ...)
	
	if self:active() then
		managers.interaction:add_unit_clbk(self._unit)
	end
]]
end