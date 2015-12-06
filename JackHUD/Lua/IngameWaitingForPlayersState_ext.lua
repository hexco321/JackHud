if JackHUD and JackHUD._data and JackHUD._data.enable_speed_up then
	local SKIP_BLACKSCREEN = JackHUD._data.black_screen_skip

	local update_original = IngameWaitingForPlayersState.update

	function IngameWaitingForPlayersState:update(...)
		update_original(self, ...)

		if self._skip_promt_shown and SKIP_BLACKSCREEN then
			self:_skip()
		end
	end
end