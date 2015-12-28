
local SKIP_BLACKSCREEN = JackHUD._data.skip_black_screen

local update_original = IngameWaitingForPlayersState.update
function IngameWaitingForPlayersState:update(...)
	update_original(self, ...)
	if self._skip_promt_shown and SKIP_BLACKSCREEN then
		self:_skip()
	end
end
