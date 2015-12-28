
local _setup_mission_assets_original = MissionAssetsManager._setup_mission_assets
local sync_unlock_asset_original = MissionAssetsManager.sync_unlock_asset
local unlock_asset_original = MissionAssetsManager.unlock_asset
local sync_load_original = MissionAssetsManager.sync_load
local sync_save_original = MissionAssetsManager.sync_save

function MissionAssetsManager:mission_has_preplanning()
	return tweak_data.preplanning.locations[Global.game_settings and Global.game_settings.level_id] ~= nil
end

function MissionAssetsManager:asset_is_buyable(asset)
	return asset.id ~= "buy_all_assets" and asset.show and not asset.unlocked and ((Network:is_server() and asset.can_unlock) or (Network:is_client() and self:get_asset_can_unlock_by_id(asset.id)))
end

function MissionAssetsManager:_setup_mission_assets()
	_setup_mission_assets_original(self)
	if not self:mission_has_preplanning() then
		self:insert_buy_all_assets_asset()
	end
end

function MissionAssetsManager:update_buy_all_assets_asset_cost()
	self._tweak_data.buy_all_assets.money_lock = 0
	for _, asset in ipairs(self._global.assets) do
		if self:asset_is_buyable(asset) then
			self._tweak_data.buy_all_assets.money_lock = self._tweak_data.buy_all_assets.money_lock + (self._tweak_data[asset.id].money_lock or 0)
		end
	end
end

function MissionAssetsManager:insert_buy_all_assets_asset()
	if self._tweak_data.gage_assignment then
		self._tweak_data.buy_all_assets = clone(self._tweak_data.gage_assignment)
		self._tweak_data.buy_all_assets.name_id = "buy_all_assets"
		self._tweak_data.buy_all_assets.unlock_desc_id = "buy_all_assets_desc"
		self._tweak_data.buy_all_assets.visible_if_locked = true
		self._tweak_data.buy_all_assets.no_mystery = true
		self:update_buy_all_assets_asset_cost()
		for _, asset in ipairs(self._global.assets) do
			if asset.id == "gage_assignment" then
				self._gage_saved = deep_clone(asset)
				asset.id = "buy_all_assets"
				asset.unlocked = false
				asset.can_unlock = true
				asset.no_mystery = true
				break
			end
		end
	end
end

function MissionAssetsManager:sync_unlock_asset(asset_id, peer)
	sync_unlock_asset_original(self, asset_id, peer)
	self:update_buy_all_assets_asset_cost()
	for _, asset in ipairs(self._global.assets) do
		if self:asset_is_buyable(asset) then
			return
		end
	end
	if not self._all_assets_bought then
		self._tweak_data.buy_all_assets.money_lock = 0
		self._all_assets_bought = true
		unlock_asset_original(self, "buy_all_assets")
	end
end

function MissionAssetsManager:unlock_asset(asset_id)
	if asset_id ~= "buy_all_assets" or not game_state_machine or not self:is_unlock_asset_allowed() then
		return unlock_asset_original(self, asset_id)
	end
	for _, asset in ipairs(self._global.assets) do
		if self:asset_is_buyable(asset) then
			unlock_asset_original(self, asset.id)
		end
	end
end

function MissionAssetsManager:sync_save(data)
	if self:mission_has_preplanning() then
		return sync_save_original(self, data)
	end
	clone(self._global).assets = clone(clone(self._global).assets)
	for id, asset in ipairs(clone(self._global).assets) do
		if asset.id == "buy_all_assets" then
			clone(self._global).assets[id] = self._gage_saved
			break
		end
	end
	data.MissionAssetsManager = clone(self._global)
end

function MissionAssetsManager:sync_load(data)
	if not self:mission_has_preplanning() then
		self._global = data.MissionAssetsManager
		self:insert_buy_all_assets_asset()
	end
	sync_load_original(self, data)
end
