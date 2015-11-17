if not JackHUD then
	return
end

local SHOW_BUFFS = JackHUD._data.show_buffs
local SHOW_TIMERS = JackHUD._data.show_timers

--TODO: Rewrite rest of options
HUDManager.ListOptions = HUDManager.ListOptions or {
	right_list_height_offset = 0,     --margin from top for the right list
	right_list_scale = 1,    --size scale of right list
	left_list_height_offset = 40,      --margin from top for the left list
	left_list_scale = 1,       --size scale of left list
	buff_list_height_offset = 125,     --margin from bottom for the buff list
	buff_list_scale = 1,       --size scale of buff list

	--left side list
	show_timers = JackHUD._data.show_timers,       --drills, timelocks, hacking etc.
	show_equipment = JackHUD._data.show_equipment,     --deployables (ammo, doc bags, body bags)
	show_minions = JackHUD._data.show_minions,       --converted enemies, type and health
	show_pagers = JackHUD._data.show_pagers,       --active pagers
	remove_answered_pager_contour = JackHUD._data.remove_answered_pager_contour,      --removes the interaction contour on answered pagers
	show_ecms = JackHUD._data.show_ecms, --active ecms
	 
	--right side list
	show_enemies = JackHUD._data.show_enemies,       --currently spawned enemies
	aggregate_enemies = JackHUD._data.aggregate_enemies, --don't split enemies on type; use a single entry for all
	show_civilians = JackHUD._data.show_civilians,     --currently spawned, untied civs
	show_hostages = JackHUD._data.show_hostages,      --currently tied civilian and dominated cops
	show_pager_count = JackHUD._data.show_pager_count,   --show number of triggered pagers (only counts pagers triggered while you were present)
	show_loot = JackHUD._data.show_loot,  --show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
	aggregate_loot = JackHUD._data.aggregate_loot,    --don't split loot on type; use a single entry for all
	separate_bagged_loot = JackHUD._data.separate_bagged_loot, --show bagged loot as a separate value
	show_special_pickups = JackHUD._data.show_special_pickups,       --show number of special equipment/items
	 
	--buff list
	show_buffs = JackHUD._data.show_buffs --active effects (buffs/debuffs). also see the hudlist.buffitembase.buffs table definitions, where you can set the ignore flag to not show specific things (or screw around with other things at your own risk)
	
}

local HUDManager_update_original = HUDManager.update
local HUDManager_setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2

function HUDManager:_setup_player_info_hud_pd2(...)
	HUDManager_setup_player_info_hud_pd2_original(self, ...)
	
	self._lists_initialized = true
	
	self:_setup_left_list()
	self:_setup_right_list()
	if SHOW_BUFFS then
		self:_setup_buff_list()
	end
end

function HUDManager:update(t, dt, ...)
	for _, list in pairs(self._hud_panel_lists or {}) do
		if list:is_active() then
			list:update(t, dt)
		end
	end
	
	return HUDManager_update_original(self, t, dt, ...)
end

function HUDManager:list_initialized()
	return self._lists_initialized
end

function HUDManager:register_hud_list(name, class, params, ...)
	self._hud_panel_lists = self._hud_panel_lists or {}
	
	if not self._hud_panel_lists[name] then
		if type(class) == "string" then
			class = _G.HUDList[class]
		end
			
		self._hud_panel_lists[name] = class and class:new(nil, name, params, ...)
	end
	
	return self._hud_panel_lists[name]
end

function HUDManager:hud_list(name)
	return self._hud_panel_lists and self._hud_panel_lists[name] or nil
end

function HUDManager:_setup_left_list()
	local list_width = 600
	local list_height = 800
	local x = 0
	local y = HUDManager.ListOptions.left_list_height_offset or 40
	local scale = HUDManager.ListOptions.left_list_scale or 1
	local list = managers.hud:register_hud_list("left_side_list", HUDList.VerticalList, { align = "left", x = x, y = y, w = list_width, h = list_height, top_to_bottom = true, item_margin = 5 })

	--Timers
	list:register_item("timers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
	list:item("timers"):set_static_item(HUDList.LeftListIcon, 1, 4/5, { 
		{ atlas = true, texture_rect = { 3 * 64, 6 * 64, 64, 64 } },
	})
	
	--Deployables
	local icons = HUDList.EquipmentItem.ICON_TABLE
	list:register_item("equipment", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
	list:item("equipment"):set_static_item(HUDList.LeftListIcon, 1, 1, { 
		{ atlas = true, h = 2/3, w = 2/3, texture_rect = { icons.ammo_bag.x, icons.ammo_bag.y, 64, 64 }, valign = "top", halign = "right" },
		{ atlas = true, h = 2/3, w = 2/3, texture_rect = { icons.doc_bag.x, icons.doc_bag.y, 64, 64 }, valign = "bottom", halign = "left" },
	})
	
	--Minions
	list:register_item("minions", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, left_to_right = true, item_margin = 5 })
	list:item("minions"):set_static_item(HUDList.LeftListIcon, 1, 4/5, { 
		{ atlas = true, texture_rect = { 6 * 64, 8 * 64, 64, 64 } },
	})
	
	--Pagers
	list:register_item("pagers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
	list:item("pagers"):set_static_item(HUDList.LeftListIcon, 1, 1, { 
		{ spec = true, texture_rect = { 1 * 64, 4 * 64, 64, 64 } },
	})
	
	--ECMs
	list:register_item("ecms", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5 })
	list:item("ecms"):set_static_item(HUDList.LeftListIcon, 1, 1, { 
		{ atlas = true, texture_rect = { 1 * 64, 4 * 64, 64, 64 } },
	})


	if HUDManager.ListOptions.show_timers then
		--Initialize stored timers
		for _, timer in ipairs(DigitalGui.TIMER_CACHE) do
			timer:create_list_item()
		end
	end
	
	if HUDManager.ListOptions.show_equipment then
		for key, data in pairs(DoctorBagBase.SPAWNED_BAGS) do
			data.unit:base():_create_list_item()
		end
		for key, data in pairs(AmmoBagBase.SPAWNED_BAGS) do
			data.unit:base():_create_list_item()
		end
		for key, data in pairs(BodyBagsBagBase.SPAWNED_BAGS) do
			data.unit:base():_create_list_item()
		end
	end
end

function HUDManager:_setup_right_list()
	local list_width = 800
	local list_height = 800
	local x = self:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:right() - list_width
	local y = HUDManager.ListOptions.right_list_height_offset or 0
	local scale = HUDManager.ListOptions.right_list_scale or 1
	local list = managers.hud:register_hud_list("right_side_list", HUDList.VerticalList, { align = "right", x = x, y = y, w = list_width, h = list_height, top_to_bottom = true, item_margin = 5 })
	
	--Enemy counter
	local unit_count_list = list:register_item("enemy_count_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 1 })
	for name, data in pairs(HUDList.UnitCountItem.UNIT_ICON_MAP) do
		unit_count_list:register_item(name, data.class or HUDList.UnitCountItem)
	end
	
	--Hostage/civilian/pager counter
	local hostage_count_list = list:register_item("hostage_count_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 4 })
	for name, data in pairs(HUDList.UnitCountItem.HOSTAGE_ICON_MAP) do
		hostage_count_list:register_item(name, HUDList.HostageUnitCountItem)
	end
	hostage_count_list:register_item("PagerCount", HUDList.UsedPagersItem)

	--Loot
	local loot_list = list:register_item("loot_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 2 })
	for name, data in pairs(HUDList.LootItem.LOOT_ICON_MAP) do
		loot_list:register_item(name, data.class or HUDList.LootItem)
	end
	
	--Special pickups
	local special_equipment_list = list:register_item("special_pickup_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 4 })
	for id, data in pairs(HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP) do
		special_equipment_list:register_item(id, data.class or HUDList.SpecialPickupItem)
	end
end

function HUDManager:_setup_buff_list()
	local function register_buff_item(buff)
		if not buff.ignore then
			local item
			if HUDManager.CUSTOM_TEAMMATE_PANEL then
				item = managers.hud:hud_list("buff_list"):register_item(buff.name, buff.class or "BuffItemBase", buff)
			else
				item = managers.hud:hud_list("buff_list"):item(buff.type):register_item(buff.name, buff.class or "BuffItemBase", buff)
			end
			
			if item then
				if buff.no_fade then
					item:set_fade_time(0)
				end
				if buff.no_expiration then
					item:set_keep_on_expiration(true)
				end
			end
			
			return item
		end
	end
	
	local scale = HUDManager.ListOptions.buff_list_scale or 1

	if HUDManager.CUSTOM_TEAMMATE_PANEL then
		local list_width = self._teammate_panels[HUDManager.PLAYER_PANEL]:panel():w()
		local list_height = 40 * scale
		local x = self._teammate_panels[HUDManager.PLAYER_PANEL]:panel():left()
		local y = self._teammate_panels[HUDManager.PLAYER_PANEL]:panel():top() - (list_height + 5)
		local buff_list = self:register_hud_list("buff_list", HUDList.HorizontalList, { align = "center", x = x, y = y , w = list_width, h = list_height, centered = true, item_margin = 0 })
	else
		local list_width = 800
		local list_height = 150 * scale
		local x = self:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:right() - list_width
		local y = self:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:bottom() - ((HUDManager.ListOptions.buff_list_height_offset or 125) + list_height)
		local buff_list = self:register_hud_list("buff_list", HUDList.VerticalList, { align = "right", x = x, y = y , w = list_width, h = list_height, bottom_to_top = true, item_margin = 0 })
		buff_list:register_item("debuff", HUDList.HorizontalList, { align = "bottom", w = buff_list:panel():w(), h = buff_list:panel():h() / 3, right_to_left = true, item_margin = 0 })
		buff_list:register_item("team", HUDList.HorizontalList, { align = "bottom", w = buff_list:panel():w(), h = buff_list:panel():h() / 3, right_to_left = true, item_margin = 0 })
		buff_list:register_item("temporary", HUDList.HorizontalList, { align = "bottom", w = buff_list:panel():w(), h = buff_list:panel():h() / 3, right_to_left = true, item_margin = 0 })
	end
	
	for _, buff in pairs(HUDList.BuffItemBase.BUFFS.temporary) do
		if not buff.ignore then
			local new_item = register_buff_item(buff)
			if new_item and buff.has_aced and buff.has_aced() then
				new_item:set_aced(true)
			end
		end
	end
	
	for category, upgrade_data in pairs(HUDList.BuffItemBase.BUFFS.team) do
		for upgrade, buff in pairs(upgrade_data) do
			if not buff.ignore then
				local new_item = register_buff_item(buff)
				
				--Manually activate local player team buffs
				if new_item and managers.player:has_team_category_upgrade(category, upgrade) then
					if buff.level then
						new_item:set_level(buff.level)
					end
					
					if buff.has_aced and buff.has_aced() then
						new_item:set_aced(true)
					end
					
					new_item:activate()
				end
			end
		end
	end
	
	for _, buff in pairs(HUDList.BuffItemBase.BUFFS.special) do
		if not buff.ignore then
			local new_item = register_buff_item(buff)
			if new_item and buff.has_aced and buff.has_aced() then
				new_item:set_aced(true)
			end
		end
	end
end

function HUDManager:update_buff_item(buff, callbacks)
	local item
	if HUDManager.CUSTOM_TEAMMATE_PANEL then
		item = not buff.ignore and self:hud_list("buff_list"):item(buff.name)
	else
		item = not buff.ignore and self:hud_list("buff_list"):item(buff.type):item(buff.name)
	end
	
	if item then
		for cbk, args in pairs(callbacks or {}) do
			if type(args) == "table" then
				item[cbk](item, unpack(args))
			else
				item[cbk](item, args)
			end
		end
	end
end





--TEST INTERFACE FUNCTIONS
	
function HUDManager:set_show_timers(status)
	--TODO
end
	
function HUDManager:set_show_equipment(status)
	if HUDManager.ListOptions.show_equipment ~= status then
		io.write("set_show_equipment: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_equipment = status
		
		if self:list_initialized() then
			local equipment_list = self:hud_list("left_side_list"):item("equipment")
			if status then
				for key, data in pairs(DoctorBagBase.SPAWNED_BAGS) do
					data.unit:base():_create_list_item()
				end
				for key, data in pairs(AmmoBagBase.SPAWNED_BAGS) do
					data.unit:base():_create_list_item()
				end
				for key, data in pairs(BodyBagsBagBase.SPAWNED_BAGS) do
					data.unit:base():_create_list_item()
				end
			else
				for name, item in pairs(equipment_list:items()) do
					item:delete(true)
				end
			end
		end
	end
end

function HUDManager:set_show_ecms(status)
	if HUDManager.ListOptions.show_ecms ~= status then
		io.write("set_show_ecms: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_ecms = status
		
		if self:list_initialized() then
			local ecm_list = self:hud_list("left_side_list"):item("ecms")
			if status then
				for key, data in pairs(ECMJammerBase.SPAWNED_ECMS) do
					local item = ecm_list:register_item(tostring(key), HUDList.ECMItem)
					item:set_active(data.active)
				end
			else
				for name, item in pairs(ecm_list:items()) do
					item:delete(true)
				end
			end
		end
	end
end

function HUDManager:set_show_minions(status)
	if HUDManager.ListOptions.show_minions ~= status then
		io.write("set_show_minions: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_minions = status
		
		if self:list_initialized() then
			local minion_list = self:hud_list("left_side_list"):item("minions")
			if status then
				for key, data in pairs(managers.enemy:minion_units()) do
					local item = minion_list:register_item(tostring(key), HUDList.MinionItem, data.unit)
					item:activate()
					item:set_owner(data.owner_id)
					item:set_upgrade(data.upgraded)
					item:set_health(data.health)
				end
			else
				for name, item in pairs(minion_list:items()) do
					item:delete(true)
				end
			end
		end
	end
end

function HUDManager:set_show_pagers(status)
	--TODO
end

function HUDManager:set_remove_answered_pager_contour(status)
	io.write("set_remove_answered_pager_contour: " .. tostring(status and true or false) .. "\n")
	HUDManager.ListOptions.remove_answered_pager_contour = status
end

function HUDManager:set_show_enemies(status)
	if HUDManager.ListOptions.show_enemies ~= status then
		io.write("set_show_enemies: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_enemies = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("enemy_count_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_enemy_aggregation(status, force_refresh)
	if HUDManager.ListOptions.aggregate_enemies ~= status or force_refresh then
		io.write("set_enemy_aggregation: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.aggregate_enemies = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("enemy_count_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_show_turrets(status)
	if HUDManager.ListOptions.show_turrets ~= status then
		io.write("set_show_turrets: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_turrets = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("enemy_count_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_show_civilians(status)
	if HUDManager.ListOptions.show_civilians ~= status then
		io.write("set_show_civilians: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_civilians = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("enemy_count_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_show_hostages(status)
	if HUDManager.ListOptions.show_hostages ~= status then
		io.write("set_show_hostages: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_hostages = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("hostage_count_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_show_pager_count(status)
	if HUDManager.ListOptions.show_pager_count ~= status then
		io.write("set_show_pager_count: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_pager_count = status
		
		if self:list_initialized() and managers.groupai:state():whisper_mode() then
			self:hud_list("right_side_list"):item("hostage_count_list"):item("PagerCount"):post_init()
		end
	end
end

function HUDManager:set_show_loot(status)
	if HUDManager.ListOptions.show_loot ~= status then
		io.write("set_show_loot: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_loot = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("loot_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_loot_aggregation(status, force_refresh)
	if HUDManager.ListOptions.aggregate_loot ~= status or force_refresh then
		io.write("set_loot_aggregation: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.aggregate_loot = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("loot_list"):items()) do
				item:post_init()
			end
		end
	end
end

function HUDManager:set_show_special_pickups(status)
	if HUDManager.ListOptions.show_special_pickups ~= status then
		io.write("set_show_special_pickups: " .. tostring(status and true or false) .. "\n")
		HUDManager.ListOptions.show_special_pickups = status
		
		if self:list_initialized() then
			for name, item in pairs(self:hud_list("right_side_list"):item("special_pickup_list"):items()) do
				item:post_init()
			end
		end
	end
end






------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--LIST CLASS DEFINITION BLOCK
do

	HUDList = HUDList or {}
	
	HUDList.ItemBase = HUDList.ItemBase or class() --DO NOT INSTANTIATE THIS CLASS
	function HUDList.ItemBase:init(parent, name, params)
		self._parent = parent
		self._name = name
		self._align = params.align or "center"
		self._fade_time = params.fade_time or 0.25
		self._move_speed = params.move_speed or 150
		self._priority = params.priority
		
		self._panel = (parent and parent:panel() or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel):panel({
			name = name,
			visible = true,
			alpha = 0,
			w = params.w or 0,
			h = params.h or 0,
			x = params.x or 0,
			y = params.y or 0,
			layer = 10
		})
	end

	function HUDList.ItemBase:post_init(...) end
	function HUDList.ItemBase:name() return self._name end
	function HUDList.ItemBase:panel() return self._panel end
	function HUDList.ItemBase:parent() return self._parent end
	function HUDList.ItemBase:align() return self._align end
	function HUDList.ItemBase:is_active() return self._active end
	function HUDList.ItemBase:priority() return self._priority end
	function HUDList.ItemBase:fade_time() return self._fade_time end
	function HUDList.ItemBase:hidden() return self._force_hide end

	function HUDList.ItemBase:_set_item_visible(status)
		self._panel:set_visible(status and not self._force_hide)
	end
	
	function HUDList.ItemBase:set_force_hide(status)
		self._force_hide = status
		self:_set_item_visible(self._active)
		if self._parent then
			self._parent:set_item_hidden(self, status)
		end
	end
	
	function HUDList.ItemBase:set_priority(priority)
		self._priority = priority
	end
	
	function HUDList.ItemBase:set_fade_time(time)
		self._fade_time = time
	end
	
	function HUDList.ItemBase:set_move_speed(speed)
		self._move_speed = speed
	end

	function HUDList.ItemBase:set_active(status)
		if status then
			self:activate()
		else
			self:deactivate()
		end
	end

	function HUDList.ItemBase:activate()
		self._active = true
		self._scheduled_for_deletion = nil
		self:_show()
	end

	function HUDList.ItemBase:deactivate()
		self._active = false
		self:_hide()
	end

	function HUDList.ItemBase:delete(instant)
		self._scheduled_for_deletion = true
		self._active = false
		self:_hide(instant)
	end
	
	function HUDList.ItemBase:_delete()
		if alive(self._panel) then
			--self._panel:stop()		--Should technically do this, but screws with unrelated animations for some reason...
			if self._parent then
				self._parent:_remove_item(self)
				self._parent:set_item_visible(self, false)
			end
			if alive(self._panel:parent()) then
				self._panel:parent():remove(self._panel)
			end
		end
	end

	function HUDList.ItemBase:_show(instant)
		if alive(self._panel) then
			--self._panel:set_visible(true)
			self:_set_item_visible(true)
			self:_fade(1, instant)
			if self._parent then
				self._parent:set_item_visible(self, true)
			end
		end
	end

	function HUDList.ItemBase:_hide(instant)
		if alive(self._panel) then
			self:_fade(0, instant)
			if self._parent then
				self._parent:set_item_visible(self, false)
			end
		end
	end
	
	function HUDList.ItemBase:_fade(target_alpha, instant)
		self._panel:stop()
		--if self._panel:alpha() ~= target_alpha then
			--self._active_fade = { instant = instant, alpha = target_alpha }
			self._active_fade = { instant = instant or self._panel:alpha() == target_alpha, alpha = target_alpha }
		--end
		self:_animate_item()
	end

	function HUDList.ItemBase:move(x, y, instant)
		if alive(self._panel) then
			self._panel:stop()
			--if self._panel:x() ~= x or self._panel:y() ~= y then
				--self._active_move = { instant = instant, x = x, y = y }
				self._active_move = { instant = instant or (self._panel:x() == x and self._panel:y() == y), x = x, y = y }
			--end
			self:_animate_item()
		end
	end
	
	function HUDList.ItemBase:cancel_move()
		self._panel:stop()
		self._active_move = nil
		self:_animate_item()
	end
	
	function HUDList.ItemBase:_animate_item()
		if alive(self._panel) and self._active_fade then
			self._panel:animate(callback(self, self, "_animate_fade"), self._active_fade.alpha, self._active_fade.instant)
		end
		
		if alive(self._panel) and self._active_move then
			self._panel:animate(callback(self, self, "_animate_move"), self._active_move.x, self._active_move.y, self._active_move.instant)
		end
	end
	
	function HUDList.ItemBase:_animate_fade(panel, alpha, instant)
		if not instant and self._fade_time > 0 then
			local fade_time = self._fade_time
			local init_alpha = panel:alpha()
			local change = alpha > init_alpha and 1 or -1
			local T = math.abs(alpha - init_alpha) * fade_time
			local t = 0
			
			while alive(panel) and t < T do
				panel:set_alpha(math.clamp(init_alpha + t * change * 1 / fade_time, 0, 1))
				t = t + coroutine.yield()
			end
		end
		
		self._active_fade = nil
		if alive(panel) then
			panel:set_alpha(alpha)
			--panel:set_visible(alpha > 0)
			self:_set_item_visible(alpha > 0)
		end
		--if self._parent and alpha == 0 then
		--	self._parent:set_item_visible(self, false)
		--end
		if self._scheduled_for_deletion then
			self:_delete()
		end
	end
	
	function HUDList.ItemBase:_animate_move(panel, x, y, instant)
		if not instant and self._move_speed > 0 then
			local move_speed = self._move_speed
			local init_x = panel:x()
			local init_y = panel:y()
			local x_change = x > init_x and 1 or x < init_x and -1
			local y_change = y > init_y and 1 or y < init_y and -1
			local T = math.max(math.abs(x - init_x) / move_speed, math.abs(y - init_y) / move_speed)
			local t = 0
			
			while alive(panel) and t < T do
				if x_change then
					panel:set_x(init_x  + t * x_change * move_speed)
				end
				if y_change then
					panel:set_y(init_y  + t * y_change * move_speed)
				end
				t = t + coroutine.yield()
			end
		end

		self._active_move = nil
		if alive(panel) then
			panel:set_x(x)
			panel:set_y(y)
		end
	end
	
	--TODO: Move this color stuff. Good to have, but has nothing to do with the list and should be localized to subclasses where it is used
	HUDList.ItemBase.DEFAULT_COLOR_TABLE = {
		{ ratio = 0.0, color = Color(1, 0.9, 0.1, 0.1) }, --Red
		{ ratio = 0.5, color = Color(1, 0.9, 0.9, 0.1) }, --Yellow
		{ ratio = 1.0, color = Color(1, 0.1, 0.9, 0.1) } --Green
	}
	function HUDList.ItemBase:_get_color_from_table(value, max_value, color_table, default_color)
		local color_table = color_table or HUDList.ItemBase.DEFAULT_COLOR_TABLE
		local ratio = math.clamp(value / max_value, 0 , 1)
		local tmp_color = color_table[#color_table].color
		local color = default_color or Color(tmp_color.alpha, tmp_color.red, tmp_color.green, tmp_color.blue)
		
		for i, data in ipairs(color_table) do
			if ratio < data.ratio then
				local nxt = color_table[math.clamp(i-1, 1, #color_table)]
				local scale = (ratio - data.ratio) / (nxt.ratio - data.ratio)
				color = Color(
					(data.color.alpha or 1) * (1-scale) + (nxt.color.alpha or 1) * scale, 
					(data.color.red or 0) * (1-scale) + (nxt.color.red or 0) * scale, 
					(data.color.green or 0) * (1-scale) + (nxt.color.green or 0) * scale, 
					(data.color.blue or 0) * (1-scale) + (nxt.color.blue or 0) * scale)
				break
			end
		end
		
		return color
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.ListBase = HUDList.ListBase or class(HUDList.ItemBase) --DO NOT INSTANTIATE THIS CLASS
	function HUDList.ListBase:init(parent, name, params)
		params.fade_time = params.fade_time or 0
		HUDList.ListBase.super.init(self, parent, name, params)

		self._stack = params.stack or false
		self._queue = not self._stack
		self._item_fade_time = params.item_fade_time
		self._item_move_speed = params.item_move_speed
		self._item_margin = params.item_margin or 0
		self._margin = params.item_margin or 0
		self._stack = params.stack or false
		self._items = {}
		self._shown_items = {}
	end

	function HUDList.ListBase:item(name)
		return self._items[name]
	end

	function HUDList.ListBase:items()
		return self._items
	end
	
	function HUDList.ListBase:num_items()
		return table.size(self._items)
	end

	function HUDList.ListBase:active_items()
		local count  = 0
		for name, item in pairs(self._items) do
			if item:is_active() then
				count = count + 1
			end
		end
		return count
	end

	function HUDList.ListBase:shown_items()
		return #self._shown_items
	end

	function HUDList.ListBase:update(t, dt)
		local delete_items = {}
		for name, item in pairs(self._items) do
			if item.update and item:is_active() then
				item:update(t, dt)
			end
		end
	end

	function HUDList.ListBase:register_item(name, class, ...)
		if not self._items[name] then
			if type(class) == "string" then
				class = _G.HUDList[class]
			end
			
			local new_item = class and class:new(self, name, ...)
			
			if new_item then
				if self._item_fade_time then
					new_item:set_fade_time(self._item_fade_time)
				end
				if self._item_move_speed then
					new_item:set_move_speed(self._item_move_speed)
				end
				new_item:post_init(...)
				self:_set_default_item_position(new_item)
			end
			
			self._items[name] = new_item
		end
		
		return self._items[name]
	end

	function HUDList.ListBase:unregister_item(name, instant)
		if self._items[name] then
			self._items[name]:delete(instant)
		end
	end

	function HUDList.ListBase:set_static_item(class, ...)
		self:delete_static_item()
		
		if type(class) == "string" then
			class = _G.HUDList[class]
		end
		
		self._static_item = class and class:new(self, "static_list_item", ...)
		if self._static_item then
			self:setup_static_item()
			self._static_item:panel():show()
			self._static_item:panel():set_alpha(1)
		end
		
		return self._static_item
	end

	function HUDList.ListBase:delete_static_item()
		if self._static_item then
			self._static_item:delete(true)
			self._static_item = nil
		end
	end

	function HUDList.ListBase:set_item_visible(item, visible)
		local index
		for i, shown_item in ipairs(self._shown_items) do
			if shown_item == item then
				index = i
				break
			end
		end
	
		--local threshold = self._static_item and 1 or 0	--TODO
	
		if visible and not index then
			if #self._shown_items <= 0 then
				self:activate()
			end
			
			local insert_index = #self._shown_items + 1
			if item:priority() then
				for i, list_item in ipairs(self._shown_items) do
					if not list_item:priority() or (list_item:priority() > item:priority()) then
						insert_index = i
						break
					end
				end
			end
			
			table.insert(self._shown_items, insert_index, item)
		elseif not visible and index then
			table.remove(self._shown_items, index)
			if #self._shown_items <= 0 then
				managers.enemy:add_delayed_clbk("visibility_cbk_" .. self._name, callback(self, self, "_cbk_update_visibility"), Application:time() + item:fade_time())
				--self:deactivate()
			end
		else
			return
		end
		
		self:_update_item_positions(item)
	end
	
	function HUDList.ListBase:set_item_hidden(item, hidden)
		self:_update_item_positions(nil, true)
	end
	
	function HUDList.ListBase:_cbk_update_visibility()
		if #self._shown_items <= 0 then
			self:deactivate()
		end
	end
	
	function HUDList.ListBase:_remove_item(item)
		self._items[item:name()] = nil
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.HorizontalList = HUDList.HorizontalList or class(HUDList.ListBase)
	function HUDList.HorizontalList:init(parent, name, params)
		params.align = params.align == "top" and "top" or params.align == "bottom" and "bottom" or "center"
		HUDList.HorizontalList.super.init(self, parent, name, params)
		self._left_to_right = params.left_to_right
		self._right_to_left = params.right_to_left and not self._left_to_right
		self._centered = params.centered and not (self._right_to_left or self._left_to_right)
	end

	function HUDList.HorizontalList:_set_default_item_position(item)
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		item:panel():set_top(y)
	end
	
	function HUDList.HorizontalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		local x = self._left_to_right and 0 or self._panel:w() - item:panel():w()
		item:panel():set_left(x)
		item:panel():set_top(y)
		self:_update_item_positions()
	end
	
	function HUDList.HorizontalList:_update_item_positions(insert_item, instant_move)
		if self._centered then
			local total_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					total_width = total_width + item:panel():w() + self._item_margin
				end
			end
			total_width = total_width - self._item_margin
			
			local left = (self._panel:w() - math.min(total_width, self._panel:w())) / 2
			
			if self._static_item then
				self._static_item:move(left, item:panel():y(), instant_move)
				left = left + self._static_item:panel():w() + self._item_margin
			end
			
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					if insert_item and item == insert_item then
						if item:panel():x() ~= left then
							item:panel():set_x(left - item:panel():w() / 2)
							item:move(left, item:panel():y(), instant_move)
						end
					else
						item:move(left, item:panel():y(), instant_move)
					end
					left = left + item:panel():w() + self._item_margin
				end
			end
		else
			local prev_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					local width = item:panel():w()
					local new_x = (self._left_to_right and prev_width) or (self._panel:w() - (width+prev_width))
					if insert_item and item == insert_item then
						item:panel():set_x(new_x)
						item:cancel_move()
					else
						item:move(new_x, item:panel():y(), instant_move)
					end
					
					prev_width = prev_width + width + self._item_margin
				end
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.VerticalList = HUDList.VerticalList or class(HUDList.ListBase)
	function HUDList.VerticalList:init(parent, name, params)
		params.align = params.align == "left" and "left" or params.align == "right" and "right" or "center"
		HUDList.VerticalList.super.init(self, parent, name, params)
		self._top_to_bottom = params.top_to_bottom
		self._bottom_to_top = params.bottom_to_top and not self._top_to_bottom
		self._centered = params.centered and not (self._bottom_to_top or self._top_to_bottom)
	end

	function HUDList.VerticalList:_set_default_item_position(item)
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		item:panel():set_left(x)
	end

	function HUDList.VerticalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		local y = self._top_to_bottom and 0 or self._panel:h() - item:panel():h()
		item:panel():set_left(x)
		item:panel():set_y(y)
		self:_update_item_positions()
	end
	
	function HUDList.VerticalList:_update_item_positions(insert_item, instant_move)
		if self._centered then
			local total_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					total_height = total_width + item:panel():h() + self._item_margin
				end
			end
			total_height = total_height - self._item_margin
			
			local top = (self._panel:h() - math.min(total_height, self._panel:h())) / 2
			
			if self._static_item then
				self._static_item:move(item:panel():x(), top, instant_move)
				top = top + self._static_item:panel():h() + self._item_margin
			end
			
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					if insert_item and item == insert_item then
						if item:panel():y() ~= top then
							item:panel():set_y(top - item:panel():h() / 2)
							item:move(item:panel():x(), top, instant_move)
						end
					else
						item:move(item:panel():x(), top, instant_move)
					end
					top = top + item:panel():h() + self._item_margin
				end
			end
		else
			local prev_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					local height = item:panel():h()
					local new_y = (self._top_to_bottom and prev_height) or (self._panel:h() - (height+prev_height))
					if insert_item and item == insert_item then
						item:panel():set_y(new_y)
						item:cancel_move()
					else
						item:move(item:panel():x(), new_y, instant_move)
					end
					prev_height = prev_height + height + self._item_margin
				end
			end
		end
	end
	
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--LIST ITEM CLASS DEFINITION BLOCK
do
	HUDList.RightListItem = HUDList.RightListItem or class(HUDList.ItemBase)
	function HUDList.RightListItem:init(parent, name, icon, params)
		params = params or {}
		params.align = params.align or "right"
		params.w = params.w or parent:panel():h() / 2
		params.h = params.h or parent:panel():h()
		HUDList.ItemBase.init(self, parent, name, params)
	
		local x, y = unpack((icon.atlas or icon.spec) or { 0, 0 })
		local texture = icon.texture
			or icon.spec and "guis/textures/pd2/specialization/icons_atlas" 
			or icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" 
			or icon.waypoints and "guis/textures/pd2/pd2_waypoints"
			or icon.hudtabs and "guis/textures/pd2/hud_tabs"
			or icon.hudpickups and "guis/textures/pd2/hud_pickups"
			or icon.hudicons and "guis/textures/hud_icons"
		local texture_rect = (icon.spec or icon.atlas) and { x * 64, y * 64, 64, 64 } or icon.waypoints or icon.hudtabs or icon.hudpickups or icon.hudicons or icon.texture_rect
		
		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			h = self._panel:w() * (icon.h_ratio or 1),
			w = self._panel:w() * (icon.w_ratio or 1),
			alpha = icon.alpha or 1,
			blend_mode = icon.blend_mode or "add",
			color = icon.color or Color.white,
		})
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:w(),
			}, {})
		self._box:set_bottom(self._panel:bottom())
		
		self._text = self._box:text({
			name = "text",
			text = "",
			align = "center",
			vertical = "center",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6
		})
	end
	
	function HUDList.RightListItem:set_count(num)
		self._count = num
		self._text:set_text(tostring(self._count))
		if self._count > 0 then
			self:activate()
		else
			self:deactivate()
		end
	end
	
	function HUDList.RightListItem:change_count(diff)
		self:set_count((self._count or 0) + diff)
	end
	
	function HUDList.RightListItem:_animate_change(text, duration, incr)
		text:set_color(Color.white)
		
		local t = duration
		while t > 0 do
			local dt = coroutine.yield()
			t = math.max(t - dt, 0)
			local ratio = math.sin(t/duration * 1440 + 90) * 0.5 + 0.5
			text:set_color(Color(incr and ratio or 1, incr and 1 or ratio, ratio))
		end
		
		text:set_color(Color.white)
	end

	
	HUDList.UnitCountItem = HUDList.UnitCountItem or class(HUDList.RightListItem)
	HUDList.UnitCountItem.UNIT_ICON_MAP = {
		all =						{ atlas = {0, 5}, color = Color.red },	--Aggregated enemies
		cop =					{ atlas = {0, 5}, color = Color.red, priority = 3 },	--Non-special police
		sniper =				{ atlas = {6, 5}, color = Color.red },
		tank =					{ atlas = {3, 1}, color = Color.red },
		taser =					{ atlas = {3, 5}, color = Color.red },
		spooc =				{ atlas = {1, 3}, color = Color.red },
		shield =				{ atlas = {1, 1}, color = Color.red },
		security =				{ atlas = {0, 5}, color = Color.yellow, priority = 2 },
		mobster_boss =	{ atlas = {3, 1}, color = Color(1, 0.64, 0), priority = 2 },
		thug =					{ atlas = {0, 5}, color = Color(1, 0.64, 0), priority = 2 },
		turret =					{ atlas = {7, 5}, color = Color.red, class = "TurretUnitCountItem" },
		civilian =				{ atlas = {6, 7}, color = Color.white, priority = 1, class = "CivilianUnitCountItem" }
	}
	HUDList.UnitCountItem.HOSTAGE_ICON_MAP = {
		cop_hostage =		{ atlas = {2, 8}, color = Color.white },
		civilian_hostage =	{ texture = "guis/textures/pd2/hud_icon_hostage", color = Color.white },
	}		

	function HUDList.UnitCountItem:init(parent, name, unit_data)
		local unit_data = unit_data or HUDList.UnitCountItem.UNIT_ICON_MAP[name] or HUDList.UnitCountItem.HOSTAGE_ICON_MAP[name]
		local params = unit_data.priority and { priority = unit_data.priority }
		HUDList.RightListItem.init(self, parent, name, unit_data, params)
		
		self._count = 0
		self._unit_type = name
		self._aggregation_exception = unit_data and unit_data.aggregation_exception
		
		if self._unit_type == "all" then
			self._unit_type = nil	--Aggregate enemy item
		elseif self._unit_type == "shield" then	--Shield special case for screwing around with the icon
			self._icon:set_w(self._panel:w() * 0.8)
			self._icon:set_right(self._panel:right() - self._icon:w() * 0.2)
			
			self._shield_icon = self._panel:bitmap({
				name = "shield_icon",
				texture = "guis/textures/pd2/skilltree/icons_atlas",
				texture_rect = { 2 * 64, 0, 64 * 0.3, 64 },
				rotation = 180,
				h = self._panel:w(),
				w = self._panel:w() * 0.4,
				blend_mode = "add",
				color = Color.red,
			})
			self._shield_icon:set_right(self._panel:right())
		end
	end
	
	function HUDList.UnitCountItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_enemies then
			if HUDManager.ListOptions.aggregate_enemies then
				if not self._unit_type then
					count = managers.enemy and managers.enemy:unit_count(self._unit_type) or 0
				end
			else
				if self._unit_type then
					count = managers.enemy and managers.enemy:unit_count(self._unit_type) or 0
				end
			end
		end
		
		self:set_count(count)
	end
	
	HUDList.TurretUnitCountItem = HUDList.TurretUnitCountItem or class(HUDList.UnitCountItem)
	function HUDList.TurretUnitCountItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_turrets then
			count = managers.enemy and managers.enemy:unit_count(self._unit_type) or 0
		end
		
		self:set_count(count)
	end		
	
	HUDList.CivilianUnitCountItem = HUDList.CivilianUnitCountItem or class(HUDList.UnitCountItem)
	function HUDList.CivilianUnitCountItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_civilians then
			count = managers.enemy and managers.enemy:unit_count(self._unit_type) or 0
		end
		
		self:set_count(count)
	end
	
	HUDList.HostageUnitCountItem = HUDList.HostageUnitCountItem or class(HUDList.UnitCountItem)
	function HUDList.HostageUnitCountItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_hostages then
			count = managers.groupai and managers.groupai:state() and managers.groupai:state():hostage_count_by_type(self._unit_type) or 0
		end
		
		self:set_count(count)
	end
	
	
	HUDList.UsedPagersItem = HUDList.UsedPagersItem or class(HUDList.RightListItem)
	function HUDList.UsedPagersItem:init(parent, name)
		HUDList.RightListItem.init(self, parent, name, { spec = {1, 4} })
	end
	
	function HUDList.UsedPagersItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_pager_count then
			count =managers.interaction and managers.interaction:used_pager_count() or 0
		end
		
		self:set_count(count)
	end
	
	function HUDList.UsedPagersItem:set_count(num)
		HUDList.RightListItem.set_count(self, num)
		
		if self._count >= 5 then
			self._text:set_color(Color.red)
		end
	end
	
	
	HUDList.SpecialPickupItem = HUDList.SpecialPickupItem or class(HUDList.RightListItem)
	HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP = {
		crowbar =					{ hudpickups = { 0, 64, 32, 32 } },
		keycard =					{ hudpickups = { 32, 0, 32, 32 } },
		courier = 					{ atlas = { 6, 0 } },
		planks =					{ hudpickups = { 0, 32, 32, 32 } },
		meth_ingredients =	{ waypoints = { 192, 32, 32, 32 } },
	}
	
	function HUDList.SpecialPickupItem:init(parent, name, pickup_data)
		local pickup_data = pickup_data or HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP[name]
		HUDList.RightListItem.init(self, parent, name, pickup_data)
		
		self._count = 0
		self._id = name
	end
	
	function HUDList.SpecialPickupItem:post_init()
		local count = 0
		
		if HUDManager.ListOptions.show_special_pickups then
			count = managers.interaction and managers.interaction:special_pickup_count(self._id) or 0
		end
		
		self:set_count(count)
	end

	
	HUDList.LootItem = HUDList.LootItem or class(HUDList.RightListItem)
	HUDList.LootItem.LOOT_ICON_MAP = {
		--If you add stuff here, be sure to add the loot type to ObjectInteractionManager as well
		all =				{ },	--Aggregated loot
		gold =			{ text = "Gold" },
		money =		{ text = "Money" },
		jewelry =		{ text = "Jewelry" },
		painting =		{ text = "Painting" },
		coke =			{ text = "Coke" },
		meth =			{ text = "Meth" },
		weapon =		{ text = "Weapon" },
		server =		{ text = "Server" },
		turret =			{ text = "Turret" },
		shell =			{ text = "Shell" },
		artifact =		{ text = "Artifact" },
		armor =			{ text = "Armor" },
		toast =			{ text = "Toast" },
		diamond =		{ text = "Diamond" },
		bomb =			{ text = "Bomb" },
		evidence =	{ text = "Evidence" },
		warhead =		{ text = "Warhead" },
		--container =	{ text = "?" },
	}
	
	function HUDList.LootItem:init(parent, name, loot_data)
		local loot_data = loot_data or HUDList.LootItem.LOOT_ICON_MAP[name]
		HUDList.RightListItem.init(self, parent, name, loot_data.icon_data or { hudtabs = { 32, 32, 32, 32 }, alpha = 0.75, w_ratio = 1.2 })
	
		self._loot_id = name
		self._count = 0
		self._bagged_count = 0
	
		self._icon:set_center(self._panel:center())
		self._icon:set_top(self._panel:top())
		if HUDManager.ListOptions.separate_bagged_loot then
			self._text:set_font_size(self._text:font_size() * 0.9)
		end

		if loot_data.text then
			self._name_text = self._panel:text({
				name = "text",
				text = string.sub(loot_data.text, 1, 5) or "",
				align = "center",
				vertical = "center",
				w = self._panel:w(),
				h = self._panel:w(),
				color = Color(0.0, 0.5, 0.0),
				blend_mode = "normal",
				font = tweak_data.hud_corner.assault_font,
				font_size = self._panel:w() * 0.4,
				layer = 10
			})
			self._name_text:set_center(self._icon:center())
			self._name_text:set_y(self._name_text:y() + self._icon:h() * 0.1)
		end
		
		if name == "all" then
			self._loot_id = nil
		end
	end
	
	function HUDList.LootItem:post_init()
		local loot, bagged
		
		if HUDManager.ListOptions.show_loot then
			if HUDManager.ListOptions.aggregate_loot then
				if not self._loot_id then
					loot, bagged = managers.interaction and managers.interaction:loot_count(self._loot_id)
				end
			else
				if self._loot_id then
					loot, bagged = managers.interaction and managers.interaction:loot_count(self._loot_id)
				end
			end
		end
		
		self:set_count(loot or 0, bagged or 0)
	end
	
	function HUDList.LootItem:set_count(value, bagged_value)
		local old_total = self._count + self._bagged_count
		local new_total = value + bagged_value
		if old_total > 0 and new_total > 0 then
			self._text:stop()
			self._text:animate(callback(self, self, "_animate_change"), 1, old_total < new_total)
		end
		
		self._count = value
		self._bagged_count = bagged_value
		if HUDManager.ListOptions.separate_bagged_loot then
			self._text:set_text(self._count .. "/" .. self._bagged_count)
		else
			self._text:set_text(new_total)
		end
		
		if self._count > 0 or self._bagged_count > 0 then
			self:activate()
		else
			self:deactivate()
		end
	end
	
	function HUDList.LootItem:change_count(diff, bagged)
		self:set_count(self._count + (not bagged and diff or 0), self._bagged_count + (bagged and diff or 0))
	end
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--TODO: See if these classes can be consolidated a bit
	
	HUDList.LeftListIcon = HUDList.LeftListIcon or class(HUDList.ItemBase)
	function HUDList.LeftListIcon:init(parent, name, ratio_w, ratio_h, icons)
		HUDList.ItemBase.init(self, parent, name, { align = "center", w = parent:panel():h() * (ratio_w or 1), h = parent:panel():h() * (ratio_h or 1) })
		
		self._icons = {}
		for i, icon in ipairs(icons) do
			local texture = icon.spec and "guis/textures/pd2/specialization/icons_atlas" 
				or icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" 
				or icon.waypoints and "guis/textures/pd2/pd2_waypoints"
				or icon.texture
		
			local bitmap = self._panel:bitmap({
				name = "icon_" .. tostring(i),
				texture = texture,
				texture_rect = icon.texture_rect or nil,
				h = self:panel():w() * (icon.h or 1),
				w = self:panel():w() * (icon.w or 1),
				blend_mode = "add",
				color = icon.color or Color.white,
			})
			
			bitmap:set_center(self._panel:center())
			if icon.valign == "top" then 
				bitmap:set_top(self._panel:top())
			elseif icon.valign == "bottom" then 
				bitmap:set_bottom(self._panel:bottom())
			end
			if icon.halign == "left" then
				bitmap:set_left(self._panel:left())
			elseif icon.halign == "right" then
				bitmap:set_right(self._panel:right())
			end
		
			table.insert(self._icons, bitmap)
		end
	end

	HUDList.TimerItem = HUDList.TimerItem or class(HUDList.ItemBase)
	HUDList.TimerItem.STANDARD_COLOR = Color(1, 1, 1, 1)
	HUDList.TimerItem.UPGRADE_COLOR = Color(1, 0.0, 0.8, 1.0)
	HUDList.TimerItem.DISABLED_COLOR = Color(1, 1, 0, 0)
	HUDList.TimerItem.FLASH_SPEED = 2
	function HUDList.TimerItem:init(parent, name, position, text, unit)
		HUDList.ItemBase.init(self, parent, name, { align = "left", w = parent:panel():h() * 4/5, h = parent:panel():h() })
		
		self._show_distance = true
		self._unit = unit
		self._name = name
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
		}
		self._current_color = self.STANDARD_COLOR
		self._position = position
		
		self._type_text = self._panel:text({
			name = "type_text",
			text = text,
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:h() * 0.3,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 1/3
		})
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h() * 0.7,
			}, {})
		self._box:set_bottom(self._panel:bottom())
		
		self._distance_text = self._box:text({
			name = "distance",
			align = "center",
			vertical = "top",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.4
		})
		
		self._time_text = self._box:text({
			name = "time",
			align = "center",
			vertical = "bottom",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6
		})
		
		self:_set_colors(self._current_color)
	end

	function HUDList.TimerItem:update(t, dt)
		if not alive(self._unit) then
			io.write("HUDList.TimerItem:update(): unit dead; deleting list entry (learn to destroy your objects, OVK)\n")
			self:delete()
			return
		end
		
		if self._show_distance then
			local player = managers.player:player_unit()
			local distance = alive(player) and (mvector3.normalize(player:position() - self._position) / 100) or 0
			self._distance_text:set_text(string.format("%.0fm", distance))
		end
		
		if self._jammed then
			local new_color = self:_get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			self:_set_colors(new_color)
		end
	end
	
	function HUDList.TimerItem:update_timer(t, time_left)
		self._time_text:set_text(string.format("%d:%02d", time_left/60, time_left%60))
	end
	
	function HUDList.TimerItem:set_jammed(status)
		if not status then
			self:_set_colors(self._current_color)
		end
		self._jammed = status
	end
	
	function HUDList.TimerItem:set_powered(status)
		self:set_jammed(status)
	end

	function HUDList.TimerItem:_set_colors(color)
		self._time_text:set_color(color)
		self._type_text:set_color(color)
		self._distance_text:set_color(color)
	end
	
	HUDList.DrillItem = HUDList.DrillItem or class(HUDList.TimerItem)
	function HUDList.DrillItem:init(parent, name, unit)
		HUDList.TimerItem.init(self, parent, name, unit:position(), "Drill", unit)
	end
	
	function HUDList.DrillItem:set_can_upgrade(status)
		self._can_upgrade = status
		self._current_color = status and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table[2].color = status and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self:_set_colors(self._current_color)
	end
	
	HUDList.HackItem = HUDList.HackItem or class(HUDList.TimerItem)
	function HUDList.HackItem:init(parent, name, unit)
		HUDList.TimerItem.init(self, parent, name, unit:position(), "Hack", unit)
	end
	
	HUDList.SawItem = HUDList.SawItem or class(HUDList.TimerItem)
	function HUDList.SawItem:init(parent, name, unit)
		HUDList.TimerItem.init(self, parent, name, unit:position(), "Saw", unit)
	end
	
	HUDList.DigitalTimerItem = HUDList.DigitalTimerItem or class(HUDList.TimerItem)
	function HUDList.DigitalTimerItem:init(parent, name, unit)
		HUDList.TimerItem.init(self, parent, name, unit:position(), "Timer", unit)
	end

	HUDList.TemperatureGaugeItem = HUDList.TemperatureGaugeItem or class(HUDList.TimerItem)
	function HUDList.TemperatureGaugeItem:init(parent, name, unit, params)
		HUDList.TimerItem.init(self, parent, name, unit:position(), "Temp.", unit)
		self:set_time_values(params.start, params.goal)
		self._show_distance = nil
	end
	
	function HUDList.TemperatureGaugeItem:update_timer(t, value)
		if self._start_time and self._goal_time then
			self._distance_text:set_text(string.format("%d", value))
			self._time_text:set_text(string.format("%.0f%%", math.clamp((value - self._start_time) / (self._goal_time - self._start_time), 0, 1) * 100))
		else
			self._time_text:set_text(string.format("%d", value))
		end
	end
	
	function HUDList.TemperatureGaugeItem:set_time_values(start, goal)
		self._start_time = start
		self._goal_time = goal
	end
	
	
	HUDList.EquipmentItem = HUDList.EquipmentItem or class(HUDList.ItemBase)
	HUDList.EquipmentItem.ICON_TABLE = {
		sentry = { x = 7 * 64, y = 5 * 64 },
		ammo_bag = { x = 1 * 64, y = 0 * 64 },
		doc_bag = { x = 2 * 64, y = 7 * 64 },
		body_bag = { x = 5 * 64, y = 11 * 64 },
	}
	function HUDList.EquipmentItem:init(parent, name, type, equipment)
		HUDList.ItemBase.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h() })
		
		self._equipment = equipment
		local icon = HUDList.EquipmentItem.ICON_TABLE[type]
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, {})
		
		self._icon = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { icon.x, icon.y, 64, 64 },
			h = self:panel():w() * 0.8,
			w = self:panel():w() * 0.8,
			blend_mode = "add",
			layer = 0,
			color = Color.white,
		})
		self._icon:set_center(self._panel:center())
		self._icon:set_top(self._panel:top())
		
		self._info_text = self._panel:text({
			name = "info",
			text = "",
			align = "center",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:h() * 0.4,
			color = Color.white,
			layer = 1,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.4,
		})
		self._info_text:set_bottom(self._panel:bottom())
	end

	function HUDList.EquipmentItem:set_owner(peer_id)
		self._owner = peer_id
		self:_set_color()
	end
	
	function HUDList.EquipmentItem:_set_color()
		if self._owner then
			local color = self._owner > 0 and tweak_data.chat_colors[self._owner]:with_alpha(1) or Color.white
			self._icon:set_color(color)
		end
	end
	
	HUDList.BagEquipmentItem = HUDList.BagEquipmentItem or class(HUDList.EquipmentItem)
	function HUDList.BagEquipmentItem:init(parent, name, type, equipment)
		HUDList.EquipmentItem.init(self, parent, name, type, equipment)
		self._amount_format = "%.0f" .. (type == "ammo_bag" and "%%" or "")
	end
	
	function HUDList.BagEquipmentItem:set_max_amount(max_amount)
		self._max_amount = max_amount
		self:_update_info_text()
	end

	function HUDList.BagEquipmentItem:set_amount(amount)
		self._current_amount = amount
		self:_update_info_text()
	end
	
	function HUDList.BagEquipmentItem:_update_info_text()
		if self._current_amount and self._max_amount then
			self._info_text:set_text(string.format(self._amount_format, self._current_amount))
			self._info_text:set_color(self:_get_color_from_table(self._current_amount, self._max_amount))
		end
	end
	
	
	HUDList.MinionItem = HUDList.MinionItem or class(HUDList.ItemBase)
	HUDList.MinionItem._UNIT_NAMES = {
		security = "Security",
		gensec = "Security",
		cop = "Cop",
		fbi = "FBI",
		swat = "SWAT",
		heavy_swat = "H. SWAT",
		fbi_swat = "FBI SWAT",
		fbi_heavy_swat = "H. FBI SWAT",
		city_swat = "GenSec",
	}
	function HUDList.MinionItem:init(parent, name, unit, peer_id, upgrade)
		HUDList.ItemBase.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h() })
		
		self._unit = unit
		self._max_health = unit:character_damage()._HEALTH_INIT
		local type_str = self._UNIT_NAMES[unit:base()._tweak_table] or "UNKNOWN"
	
		self._health_bar = self._panel:bitmap({
			name = "radial_health",
			texture = "guis/textures/pd2/hud_health",
			texture_rect = { 64, 0, -64, 64 },
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 2,
			color = Color(1, 1, 0, 0),
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._health_bar:set_bottom(self._panel:bottom())
		
		self._hit_indicator = self._panel:bitmap({
			name = "radial_health",
			texture = "guis/textures/pd2/hud_radial_rim",
			blend_mode = "add",
			layer = 1,
			color = Color.red,
			alpha = 0,
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._hit_indicator:set_center(self._health_bar:center())

		self._outline = self._panel:bitmap({
			name = "outline",
			texture = "guis/textures/pd2/hud_shield",
			texture_rect = { 64, 0, -64, 64 },
			--render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			w = self._panel:w() * 0.95,
			h = self._panel:w() * 0.95,
			layer = 1,
			color = Color(1, 1, 1, 1),
		})
		self._outline:set_center(self._health_bar:center())
		
		self._unit_type = self._panel:text({
			name = "type",
			text = type_str,
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:w() * 0.3,
			color = Color.white,
			layer = 3,
			font = tweak_data.hud_corner.assault_font,
			font_size = math.min(8 / string.len(type_str), 1) * 0.25 * self._panel:h(),
		})

		self:set_health(self._max_health, true)
		self:set_owner(peer_id)
		self:set_upgrade(upgrade)
	end
	
	function HUDList.MinionItem:set_health(health, skip_animate)
		self._health_bar:set_color(Color(1, health / self._max_health, 1, 1))
		
		if not (skip_animate or self._dead) then
			self._hit_indicator:stop()
			self._hit_indicator:animate(callback(self, self, "_animate_damage"))
		end
	end

	function HUDList.MinionItem:die()
		self._dead = true
		self._panel:stop()
		self:_animate_item()	--Restart fade/move if necessary
		self._panel:animate(callback(self, self, "_animate_death"))
	end
	
	function HUDList.MinionItem:set_owner(peer_id)
		self._unit_type:set_color(peer_id and tweak_data.chat_colors[peer_id]:with_alpha(1) or Color(1, 1, 1, 1))
	end
	
	function HUDList.MinionItem:set_upgrade(upgrade)
		self._outline:set_color(upgrade and Color(1, 0.8, 0.8, 1) or Color(1, 0.3, 0.3, 0.3))
	end
	
	function HUDList.MinionItem:_animate_damage(icon)
		local duration = 1
		local t = duration
		icon:set_alpha(1)
		
		while t > 0 do
			local dt = coroutine.yield()
			t = math.clamp(t - dt, 0, duration)
			icon:set_alpha(t/duration)
		end
		
		icon:set_alpha(0)
	end

	function HUDList.MinionItem:_animate_death(panel)
		--TODO: Also need to override base item _animate_item in case move/fade order is issued and death animation is interrupted. Possibly more  trouble than worth
		self:delete()
	end
	
	
	HUDList.PagerItem = HUDList.PagerItem or class(HUDList.ItemBase)
	function HUDList.PagerItem:init(parent, name, unit)
		HUDList.ItemBase.init(self, parent, name, { align = "left", w = parent:panel():h(), h = parent:panel():h() })
		
		self._unit = unit
		self._max_duration_t = 12
		self._duration_t = self._max_duration_t
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, {})

		self._timer_text = self._box:text({
			name = "time",
			align = "center",
			vertical = "top",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.red,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.5,
			text = string.format("%.1fs", self._duration_t)
		})
		
		self._distance_text = self._box:text({
			name = "distance",
			align = "center",
			vertical = "bottom",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.5,
			text = "DIST"
		})
	end
	
	function HUDList.PagerItem:set_duration(duration_t)
		self._duration_t = duration_t
	end
	
	function HUDList.PagerItem:set_answered()
		if not self._answered then
			self._answered = true
			self._timer_text:set_color(Color(1, 0.1, 0.9, 0.1))
		end
	end
	
	function HUDList.PagerItem:update(t, dt)
		if not self._answered then
			self._duration_t = math.max(self._duration_t - dt, 0)
			self._timer_text:set_text(string.format("%.1fs", self._duration_t))
			self._timer_text:set_color(self:_get_color_from_table(self._duration_t, self._max_duration_t))
			
			if self._duration_t <= 0 then
				self._parent:unregister_item(self._name)
			end
		end

		local distance = 0
		if alive(self._unit) and alive(managers.player:player_unit()) then
			distance = mvector3.normalize(managers.player:player_unit():position() - self._unit:position()) / 100
		end
		self._distance_text:set_text(string.format("%.0fm", distance))
	end	


	HUDList.ECMItem = HUDList.ECMItem or class(HUDList.ItemBase)
	function HUDList.ECMItem:init(parent, name)
		HUDList.ItemBase.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })
		
		self._max_duration = tweak_data.upgrades.ecm_jammer_base_battery_life * 
			tweak_data.upgrades.values.ecm_jammer.duration_multiplier[1] * 
			tweak_data.upgrades.values.ecm_jammer.duration_multiplier_2[1]
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, {})
		
		self._text = self._box:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6,
		})
	end
	
	function HUDList.ECMItem:update_timer(t, time_left)
		self._text:set_text(string.format("%.1f", time_left))
		self._text:set_color(self:_get_color_from_table(time_left, self._max_duration))
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.BuffItemBase = HUDList.BuffItemBase or class(HUDList.ItemBase)
	HUDList.BuffItemBase.BUFFS = {
		temporary = {
			--Underdog basic
			dmg_multiplier_outnumbered = {
				name = "underdog", 
				type = "temporary",
				atlas = { 2, 1 },
				has_aced = function() return managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered") end,
				class = "TimedBuffItem"
			},
			--Underdog aced (redundant, just to make sure this temporary upgrade is handled cleanly)
			dmg_dampener_outnumbered = {
				name = "underdog", 
				type = "temporary",
				atlas = { 2, 1 },
				class = "TimedBuffItem"
			},
			dmg_dampener_outnumbered_strong = {
				name = "overdog", 
				type = "temporary",
				spec = { 6, 4 },
				class = "TimedBuffItem"
			},
			dmg_dampener_close_contact = {	--TODO: Fix level counter? (has 3 levels)
				name = "close_combat", 
				type = "temporary",
				spec = { 5, 4 },
				class = "TimedBuffItem"
			},
			--Combat medic basic
			combat_medic_damage_multiplier = {
				name = "combat_medic", 
				type = "temporary",
				atlas = { 5, 7 },
				class = "TimedBuffItem"
			},
			--Overkill basic/aced
			overkill_damage_multiplier = {
				name = "overkill", 
				type = "temporary",
				atlas = { 3, 2 },
				has_aced = function() return managers.player:has_category_upgrade("player", "overkill_all_weapons") end,
				class = "TimedBuffItem"
			},
			--Bullet storm basic/aced
			no_ammo_cost = {
				name = "bullet_storm", 
				type = "temporary",
				atlas = { 4, 5 },
				class = "TimedBuffItem"
			},
			--Pain killer basic/aced
			passive_revive_damage_reduction = {
				name = "pain_killer", 
				type = "temporary",
				atlas = { 0, 10 },
				has_aced = function(level) return (level and level > 1) end,
				class = "TimedBuffItem"
			},
			--Swan song basic/aced
			berserker_damage_multiplier = {
				name = "swan_song", 
				type = "temporary",
				atlas = { 5, 12 }, 
				has_aced = function() return managers.player:has_category_upgrade("player", "berserker_no_ammo_cost") end,
				ignore = true,
				class = "TimedBuffItem"
			},
			--Quick fix aced
			first_aid_damage_reduction = {
				name = "quick_fix", 
				type = "temporary",
				atlas = { 1, 11 },
				class = "TimedBuffItem"
			},
			--Life drain
			melee_life_leech = {
				name = "life_drain", 
				type = "debuff",
				spec = { 7, 4 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem",
			},
			--Medical supplies
			loose_ammo_restore_health = {
				name = "medical_supplies", 
				type = "debuff",
				spec = { 4, 5 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem",
			},
			--Ammo give out
			loose_ammo_give_team = {
				name = "ammo_give_out", 
				type = "debuff",
				spec = { 5, 5 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem",
			},
		},
		team = {
			stamina = {
				--Endurance aced
				multiplier = {
					name = "endurance", 
					type = "team",
					atlas = { 1, 8 },
					has_aced = function() return true end,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
				--Crew chief tier 3
				passive_multiplier = {
					name = "crew_chief", 
					type = "team",
					atlas = { 2, 7 },
					level = 3,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
				--Crew chief tier 9
				hostage_multiplier = { 
					name = "crew_chief", 
					type = "team",
					atlas = { 2, 7 },
					level = 9,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
			health = {
				--Crew chief tier 5
				passive_multiplier = {
					name = "crew_chief", 
					type = "team",
					atlas = { 2, 7 },
					level = 5,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
				--Crew chief tier 9
				hostage_multiplier = {
					name = "crew_chief", 
					type = "team",
					atlas = { 2, 7 },
					level = 9,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
			armor = {
				--Crew chief tier 7
				multiplier = {
					name = "crew_chief", 
					type = "team",
					atlas = { 2, 7 },
					level = 7,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
				--Bulletproof aced
				regen_time_multiplier = {
					name = "bulletproof", 
					type = "team",
					atlas = { 6, 4 },
					has_aced = function() return true end,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
				--Armorer tier 9
				passive_regen_time_multiplier = {
					name = "armorer", 
					type = "team",
					spec = { 6, 0 },
					level = 9,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
			weapon = {
				--Leadership aced
				recoil_multiplier = {
					name = "leadership", 
					type = "team",
					atlas = { 7, 7 },
					has_aced = function() return true end,
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
			pistol = {
				--Leadership basic
				recoil_multiplier = {
					name = "leadership", 
					type = "team",
					atlas = { 7, 7 },
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
			akimbo = {
				--Leadership basic
				recoil_multiplier = {
					name = "leadership", 
					type = "team",
					atlas = { 7, 7 },
					ace_icon_color = Color(1, 0.2, 1.0, 0.2)
				},
			},
		},
		special = {
			--Inspire basic
			inspire = {
				name = "inspire",
				type = "temporary",
				atlas = { 4, 9 },
				class = "TimedBuffItem"
			},
			--Inspire debuff
			inspire_debuff = {
				name = "inspire_debuff",
				type = "debuff",
				atlas = { 4, 9 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem"
			},
			--Berserker basic/aced
			berserker = { 
				name = "berserker", 
				type = "temporary",
				atlas = { 2, 2 }, 
				has_aced = function() return managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") end,
				class = "BerserkerBuffItem"
			},
			--Bullseye debuff
			bullseye_debuff = {
				name = "bullseye_debuff",
				type = "debuff",
				atlas = { 6, 11 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem"
			},
			--Jacket perks debuff (shared cooldown)
			tension_debuff = {
				name = "tension_debuff",
				type = "debuff",
				spec = { 0, 5 },
				icon_color = Color(1, 0.6, 0, 0),
				no_fade = true,
				class = "TimedBuffItem"
			},
			--Suppression debuff
			suppression = { 
				name = "suppression_debuff", 
				type = "debuff",
				atlas = { 7, 0 }, 
				ignore = true,
				class = "TimedBuffItem",
				no_fade = true,
				icon_color = Color(1, 0.6, 0, 0)
			},
			--Armor regen debuff
			armor_regen = { 
				name = "armor_regen_debuff", 
				type = "debuff",
				spec = { 6, 0 }, 
				class = "TimedBuffItem",
				no_fade = true,
				icon_color = Color(1, 0.6, 0, 0),
				icon_scale = 1.3
			},
			--Trigger happy basic/aced
			trigger_happy = { 
				name = "trigger_happy", 
				type = "temporary",
				atlas = { 7, 11 }, 
				stack = true, 
				stack_limit = tweak_data.upgrades.max_weapon_dmg_mul_stacks or 5,
				class = "TimedBuffItem"
			},
			--Hostage taker basic/aced
			hostage_taker = {
				name = "hostage_taker", 
				type = "temporary",
				atlas = { 2, 10 },
				ignore = true,
				has_aced = function() return managers.player:upgrade_level("player", "hostage_health_regen_addend", 0) > 1 end,
				icon_scale = 1.35
			},
			--Crew chief tier 9 active effect
			hostage_situation = {
				name = "hostage_situation", 
				type = "temporary",
				spec = { 0, 1 }, 
				stack = true, 
				stack_limit = 10
			},
			--Partner in crime basic/aced
			partner_in_crime = {
				name = "partner_in_crime",
				type = "temporary",
				atlas = { 1, 10 },
				has_aced = function() return managers.player:has_category_upgrade("player", "minion_master_health_multiplier") end,
			},
			--Sixth sense basic
			sixth_sense = {
				name = "sixth_sense",
				type = "temporary",
				atlas = { 6, 10 },
				stack = true,
				--no_expiration = true,
				flash_color = Color.blue,
				class = "TimedBuffItem"
			},
			--Close combat / overdog melee stack damage
			melee_stack_damage = {
				name = "melee_stack_damage",
				type = "temporary",
				spec = { 5, 4 },
				stack = true,
				stack_limit = tweak_data.upgrades.max_melee_weapon_dmg_mul_stacks or 5,
				has_aced = function() return managers.player:upgrade_level("melee", "stacking_hit_damage_multiplier", 0) > 1 end,
				class = "TimedBuffItem"
			},
			bow_charge = {
				name = "bow_charge",
				type = "temporary",
				texture = "guis/dlcs/west/textures/pd2/blackmarket/icons/weapons/plainsrider",
				flash_color = Color.red,
				no_fade = true,
				class = "ChargedBuffItem",
				icon_rotation = 90,
				icon_w_ratio = 0.5,
				icon_scale = 2,
			},
			melee_charge = {
				name = "melee_charge",
				type = "temporary",
				atlas = { 4, 10 },
				flash_color = Color.red,
				no_fade = true,
				class = "ChargedBuffItem",
			},
		},
	}
	function HUDList.BuffItemBase:init(parent, name, buff, w, h)
		HUDList.ItemBase.init(self, parent, name, { align = "bottom", w = w or parent:panel():h(), h = h or parent:panel():h() })
		
		local x, y = unpack(buff.atlas or buff.spec or { 0, 0 })
		local texture = buff.atlas and "guis/textures/pd2/skilltree/icons_atlas" or buff.spec and "guis/textures/pd2/specialization/icons_atlas" or buff.texture
		local texture_rect = (buff.atlas or buff.spec) and { x * 64, y * 64, 64, 64 } or buff.rect
		
		self._icon = self._panel:bitmap({
				name = "icon",
				texture = texture,
				texture_rect = texture_rect,
				valign = "center",
				align = "center",
				h = self:panel():w() * 0.7 * (buff.icon_scale or 1) * (buff.icon_h_ratio or 1),
				w = self:panel():w() * 0.7 * (buff.icon_scale or 1) * (buff.icon_w_ratio or 1),
				blend_mode = "add",
				layer = 5,
				color = buff.icon_color or Color.white,
				rotation = buff.icon_rotation or 0,
		})
		self._icon:set_center(self:panel():center())
		
		self._flash_icon = self._panel:bitmap({
				name = "flash_icon",
				texture = texture,
				texture_rect = texture_rect,
				valign = "center",
				align = "center",
				layer = 10,
				h = self._icon:h(),
				w = self._icon:w(),
				blend_mode = "add",
				color = buff.flash_color or Color.blue,
				alpha = 0,
				rotation = buff.icon_rotation or 0,
		})
		self._flash_icon:set_center(self._icon:center())
		
		self._ace_icon = self._panel:bitmap({
			name = "icon_aced",
			texture = "guis/textures/pd2/skilltree/ace",
			texture_rect = { 37, 28, 54, 70 },
			valign = "center",
			align = "center",
			visible = buff.has_aced and buff.has_aced() or false,
			layer = 0,
			alpha = 0.75,
			h = self._icon:h(),
			w = 0.8 * self._icon:w(),
			blend_mode = "add",
			layer = 6,
			color = buff.ace_icon_color or nil,
		})
		self._ace_icon:set_center(self._icon:center())
		
		if buff.level then
			self._level_text = self._panel:text({
				name = "level_text",
				text = "0",
				valign = "center",
				align = "center",
				vertical = "center",
				w = self._icon:w(),
				h = self._icon:h() * 0.5,
				layer = 10,
				color = Color.green,
				blend_mode = "normal",
				font = tweak_data.hud_corner.assault_font,
				font_size = math.round(self._icon:h() * 0.5),
				visible = false
			})
			self._level_text:set_center(self:panel():center())
			self._level_text:set_bottom(self:panel():bottom())
			self._icon:set_top(self:panel():top())
			self._flash_icon:set_center(self._icon:center())
		end
		
		if buff.stack then
			self._stack_limit = buff.stack_limit
			self._stack_text = self._panel:text({
				name = "stack_text",
				text = "0",
				valign = "right",
				align = "right",
				vertical = "right",
				w = self._icon:w(),
				h = self._icon:h() * 0.5,
				layer = 1,
				color = Color.green,
				blend_mode = "normal",
				font = tweak_data.hud_corner.assault_font,
				font_size = math.round(self._icon:h() * 0.5)
			})
			self._stack_text:set_right(self._icon:right())
			self._stack_text:set_bottom(self._icon:bottom())
		end
		
		self._bg = self._panel:rect({
			name = "bg",
			layer = -1,
			h = self._icon:h(),
			w = self._icon:w(),
			color = Color.black,
			alpha = 0,
			color = Color.black,
		})
		self._bg:set_center(self._icon:center())
	end
	
	function HUDList.BuffItemBase:set_aced(status)
		self._ace_icon:set_visible(status)
	end
	
	function HUDList.BuffItemBase:set_level(new_level, override)
		if self._level_text then
			self._current_level = override and new_level or math.max(self._current_level or 0, new_level)
			self._level_text:set_text("Tier " .. self._current_level)
			self._level_text:set_visible(self._current_level > 1)
		end
	end
	
	function HUDList.BuffItemBase:set_stack_count(new_count, show_zero)
		if new_count <= 0 then
			if not show_zero then
				self:deactivate()
			end
			self._stack_text:set_text("")
		elseif self._stack_text then
			local count = self._stack_limit and math.min(new_count, self._stack_limit) or new_count
			self._stack_text:set_text(tostring(count))
			self:activate()
		end
	end
	
	function HUDList.BuffItemBase:flash(duration, continuous)
		self:stop_flash()
		self._flash_icon:animate(callback(self, self, "_animate_flash"), duration or 0.5, continuous)
	end
	
	function HUDList.BuffItemBase:stop_flash()
		self._flash_icon:stop()
		self._flash_icon:set_alpha(0)
		self._icon:set_alpha(1)
	end
	
	function HUDList.BuffItemBase:_animate_flash(icon, duration, continuous)
		repeat
			local t = duration
			while t > 0 do
				local dt = coroutine.yield()
				t = math.max(t - dt, 0)
				local value = math.sin(t/duration * 180)
				self._flash_icon:set_alpha(value)
				self._icon:set_alpha(1-value)
			end
		until not continuous

		self._flash_icon:set_alpha(0)
		self._icon:set_alpha(1)
	end

	HUDList.TimedBuffItem = HUDList.TimedBuffItem or class(HUDList.BuffItemBase)
	function HUDList.TimedBuffItem:init(parent, name, buff)
		HUDList.BuffItemBase.init(self, parent, name, buff)
		
		self._timer = CircleBitmapGuiObject:new(self._panel, {
			use_bg = true,
			radius = 0.9 * self:panel():w() / 2,
			color = Color(1, 1, 1, 1),
			blend_mode = "add",
			layer = 0
		})
		self._timer._circle:set_center(self._icon:center())
		self:set_current(1)
		
		self._remaining_t = 0
		self._duration_t = 0
	end

	function HUDList.TimedBuffItem:set_keep_on_expiration(status)
		self._keep_on_expiration = status
	end
	
	function HUDList.TimedBuffItem:set_duration(duration)
		self._remaining_t = duration
		self._duration_t = duration
		self:set_current(1)
		self:activate()
	end
	
	function HUDList.TimedBuffItem:refresh_duration()
		self:set_duration(self._duration_t)
	end

	function HUDList.TimedBuffItem:update(t, dt)
		self._remaining_t = self._remaining_t - dt
		
		if self._remaining_t <= 0 then
			if not self._keep_on_expiration then
				self:deactivate()
			end
			self:set_current(0)
		else
			self:set_current(self._remaining_t / self._duration_t)
		end
	end
	
	function HUDList.TimedBuffItem:set_current(ratio)
		self._timer._circle:set_color(Color(1, ratio, 1, 1))	--TODO: why the hell wont set_current directly on the timer work?
	end
	
	
	HUDList.ChargedBuffItem = HUDList.ChargedBuffItem or class(HUDList.BuffItemBase)
	function HUDList.ChargedBuffItem:init(parent, name, buff)
		HUDList.BuffItemBase.init(self, parent, name, buff)
		
		self._timer = CircleBitmapGuiObject:new(self._panel, {
			use_bg = true,
			radius = 0.9 * self:panel():w() / 2,
			color = Color(1, 1, 1, 1),
			blend_mode = "add",
			layer = 0
		})
		self._timer._circle:set_center(self._icon:center())
		self:set_current(1)
		
		self._remaining_t = 0
		self._duration_t = 0
	end
	
	function HUDList.ChargedBuffItem:set_current(ratio)
		self._timer._circle:set_color(Color(1, ratio, 1, 1))	--TODO: why the hell wont set_current directly on the timer work?
		if ratio >= 1 and not self._flashing then
			self._flashing = true
			self:flash(0.2, true)
		elseif ratio == 0 and self._flashing then
			self._flashing = nil
			self:stop_flash()
			self:deactivate()
		elseif ratio > 0 then
			self:activate()
		end
	end
	

	HUDList.BerserkerBuffItem = HUDList.BerserkerBuffItem or class(HUDList.BuffItemBase)
	function HUDList.BerserkerBuffItem:init(parent, name)
		HUDList.BuffItemBase.init(self, parent, name, self.BUFFS.special.berserker)
		
		self._text = self._panel:text({
			name = "text",
			text = "0",
			valign = "bottom",
			halign = "center",
			align = "center",
			vertical = "bottom",
			horizontal = "center",
			w = self._icon:w(),
			h = math.round(self._icon:w() * 0.4),
			layer = 0,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = math.round(self._icon:w() * 0.4),
			blend_mode = "normal"
		})
		self._icon:set_top(self:panel():top() + self._icon:h() * 0.1) --Extra space for ace card
		self._ace_icon:set_center(self._icon:center())
		self._flash_icon:set_center(self._icon:center())
		self._text:set_center(self._icon:center())
		self._text:set_bottom(self:panel():bottom())
		self._bg:set_center(self._icon:center())

		self._has_berserker = managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") or 
			managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier")
	end

	function HUDList.BerserkerBuffItem:set_health(ratio)
		local threshold = tweak_data.upgrades.player_damage_health_ratio_threshold
		if self._has_berserker and ratio <= threshold then
			local damage_ratio = 1 - ratio / math.max(0.01, threshold)
			self._text:set_color(self:_get_color_from_table(damage_ratio, 1))
			self._text:set_text(string.format("%.0f", damage_ratio * 100) .. "%")
			self:activate()
		else
			self:deactivate()
		end
	end
end

if JackHUD and JackHUD._data.enable_kill_counter then
	HUDManager._USE_KILL_COUNTER = true	--Custom HUD compatibility

	function HUDManager:increment_kill_count(teammate_panel_id, is_special, headshot)
		self._teammate_panels[teammate_panel_id]:increment_kill_count(is_special, headshot)
	end

	function HUDManager:reset_kill_count(teammate_panel_id)
		self._teammate_panels[teammate_panel_id]:reset_kill_count()
	end
end