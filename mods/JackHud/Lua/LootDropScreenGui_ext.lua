if JackHUD and JackHUD._data.enable_speed_up then
	local SKIP_LOOT_SCREEN_DELAY = JackHUD._data.loot_screen_skip

	local update_original = LootDropScreenGui.update

	function LootDropScreenGui:update(t, ...)
		update_original(self, t, ...)

		if not self._card_chosen then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end

		if not self._button_not_clickable and SKIP_LOOT_SCREEN_DELAY >= 0 then
			self._auto_continue_t = self._auto_continue_t or (t + SKIP_LOOT_SCREEN_DELAY)
			if t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end
end