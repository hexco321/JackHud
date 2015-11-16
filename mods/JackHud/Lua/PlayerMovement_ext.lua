if not JackHUD then
	return
end

local SHOW_BUFFS = JackHUD._data.show_buffs

if SHOW_BUFFS then
	local PlayerMovement_on_morale_boost_original = PlayerMovement.on_morale_boost

	function PlayerMovement:on_morale_boost(...)
		PlayerMovement_on_morale_boost_original(self, ...)
		managers.hud:update_buff_item(HUDList.BuffItemBase.BUFFS.special.inspire, { set_duration = tweak_data.upgrades.morale_boost_time })
	end
end
