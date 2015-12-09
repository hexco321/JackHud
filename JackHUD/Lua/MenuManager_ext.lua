
--[[
	We setup the global table for our mod, along with some path variables, and a data table.
	We cache the ModPath directory, so that when our hooks are called, we aren't using the ModPath from a
		different mod.
]]
JackHUD = JackHUD or {}
JackHUD._path = ModPath
JackHUD._data_path = SavePath .. "JackHUD.txt"
JackHUD._data = {}
JackHUD._menus = {
	"jackhud_options"
	,"speed_up_options"
	,"hud_lists_options"
	,"kill_counter_options"
	,"menu_push_to_interact"
	,"flashlight_extender"
	,"jackhud_other_options"
}

--[[
	A simple save function that json encodes our _data table and saves it to a file.
]]
function JackHUD:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

--[[
	A simple load function that decodes the saved json _data table if it exists.
]]
function JackHUD:Load()
	self:LoadDefaults()
	local file = io.open( self._data_path, "r" )
	if file then
		local configt = json.decode( file:read("*all") )
		file:close()
		for k,v in pairs(configt) do
			self._data[k] = v
		end
	end
	self:Save()
end

function JackHUD:LoadDefaults()
	local default_file = io.open(self._path .."Menu/default_values.txt")
	self._data = json.decode( default_file:read("*all") )
	default_file:close()
end

function JackHUD:InitAllMenus()
	for _,menu in pairs(JackHUD._menus) do
		MenuHelper:LoadFromJsonFile(JackHUD._path .. "Menu/" .. menu .. ".txt", JackHUD, JackHUD._data)
	end
end

function JackHUD:ForceReloadAllMenus()
	for _,menu in pairs(JackHUD._menus) do
		_menu = MenuHelper:GetMenu(menu)
		for _,_item in pairs(_menu._items_list) do
			if _item._type == "toggle" then
				_item.selected = JackHUD._data[_item._parameters.name] and 1 or 2
			elseif _item._type == "multi_choice" then
				_item._current_index = JackHUD._data[_item._parameters.name]
			elseif _item._type == "slider" then
				_item._value = JackHUD._data[_item._parameters.name]
			end
		end
	end
end

if not JackHUD.setup then
	JackHUD:Load()
	JackHUD.setup = true
	log("JackHud loaded.")
end

--[[
	Load our localization keys for our menu, and menu items.
]]
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_jackhud", function( loc )
	for _, filename in pairs(file.GetFiles(JackHUD._path .. "Loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(JackHUD._path .. "Loc/" .. filename)
			break
		end
	end
	loc:load_localization_file(JackHUD._path .. "Loc/english.txt", false)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_jackhud", function(menu_manager, menu_nodes)
	--[[
		Add "Reset all options" to the jackhud main menu.
	]]
	MenuHelper:AddButton({
		id = "jackhud_reset",
		title = "jackhud_reset",
		desc = "jackhud_reset_desc",
		callback = "callback_jackhud_reset",
		menu_id = "jackhud_options",
		priority = 100
	})
	MenuHelper:AddDivider({
		id = "jackhud_reset_divider",
		size = 16,
		menu_id = "jackhud_options",
		priority = 99
	})
end)

--[[
	Setup our menu callbacks, load our saved data, and build the menu from our json file.
]]
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_jackhud", function( menu_manager )

	--[[
		Setup our callbacks as defined in our item callback keys, and perform our logic on the data retrieved.
	]]

	-- Screen skipping
	MenuCallbackHandler.callback_skip_black_screen = function(self, item)
		JackHUD._data.skip_black_screen = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_skip_stat_screen = function(self, item)
		JackHUD._data.skip_stat_screen = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_stat_screen_skip = function(self, item)
		JackHUD._data.stat_screen_skip = item:value()
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_skip_card_picking = function(self, item)
		JackHUD._data.skip_card_picking = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_skip_loot_screen = function(self, item)
		JackHUD._data.skip_loot_screen = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_loot_screen_skip = function(self, item)
		JackHUD._data.loot_screen_skip = item:value()
		JackHUD:Save()
	end

	-- HUD Lists (Timers)
	MenuCallbackHandler.callback_show_timers = function(self, item)
		JackHUD._data.show_timers = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_equipment = function(self, item)
		JackHUD._data.show_equipment = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_sentries = function(self, item)
		JackHUD._data.show_sentries = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_hide_empty_sentries = function(self, item)
		JackHUD._data.hide_empty_sentries = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_ecms = function(self, item)
		JackHUD._data.show_ecms = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_ecm_retrigger = function(self, item)
		JackHUD._data.show_ecm_retrigger = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_minions = function(self, item)
		JackHUD._data.show_minions = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_pagers = function(self, item)
		JackHUD._data.show_pagers = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_tape_loop = function(self, item)
		JackHUD._data.show_tape_loop = (item:value() =="on")
		JackHUD:Save()
	end

	-- HUD Lists (Counters)
	MenuCallbackHandler.callback_show_enemies = function(self, item)
		JackHUD._data.show_enemies = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_aggregate_enemies = function(self, item)
		JackHUD._data.aggregate_enemies = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_turrets = function(self, item)
		JackHUD._data.show_turrets = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_civilians = function(self, item)
		JackHUD._data.show_civilians = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_hostages = function(self, item)
		JackHUD._data.show_hostages = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_minion_count = function(self, item)
		JackHUD._data.show_minion_count = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_pager_count = function(self, item)
		JackHUD._data.show_pager_count = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_loot = function(self, item)
		JackHUD._data.show_loot = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_aggregate_loot = function(self, item)
		JackHUD._data.aggregate_loot = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_separate_bagged_loot = function(self, item)
		JackHUD._data.separate_bagged_loot = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_gage_packages = function(self, item)
		JackHUD._data.show_gage_packages = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_special_pickups = function(self, item)
		JackHUD._data.show_special_pickups = (item:value() =="on")
		JackHUD:Save()
	end

	-- HUD Lists (Buffs)
	MenuCallbackHandler.callback_show_buffs = function(self, item)
		JackHUD._data.show_buffs = (item:value() =="on")
		JackHUD:Save()
	end

	-- Kill counter
	MenuCallbackHandler.callback_enable_kill_counter = function(self, item)
		JackHUD._data.enable_kill_counter = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_special_kills = function(self, item)
		JackHUD._data.show_special_kills = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_headshot_kills = function(self, item)
		JackHUD._data.show_headshot_kills = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_ai_kills = function(self, item)
		JackHUD._data.show_ai_kills = (item:value() =="on")
		JackHUD:Save()
	end

	-- Flashlight extender
	MenuCallbackHandler.callback_enable_flashlight_extender = function(self, item)
		JackHUD._data.enable_flashlight_extender = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_flashlight_range = function(self, item)
		JackHUD._data.flashlight_range = item:value()
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_flashlight_angle = function(self, item)
		JackHUD._data.flashlight_angle = item:value()
		JackHUD:Save()
	end

	-- Push to interact
	MenuCallbackHandler.callback_push_to_interact = function(self, item)
		JackHUD._data.push_to_interact = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_equipment_interrupt = function(self, item)
		JackHUD._data.equipment_interrupt = (item:value() =="on")
		JackHUD:Save()
	end

	-- Other
	MenuCallbackHandler.callback_enable_filtersettings = function(self, item)
		JackHUD._data.enable_filtersettings = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_lobby_skins_mode = function(self, item)
		JackHUD._data.lobby_skins_mode = item:value()
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_remove_answered_pager_contour = function(self, item)
		JackHUD._data.remove_answered_pager_contour = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_enable_pacified = function(self, item)
		JackHUD._data.enable_pacified = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_suspicion_text = function(self, item)
		JackHUD._data.show_suspicion_text = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_reload_interaction = function(self, item)
		JackHUD._data.show_reload_interaction = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_interaction_circle = function(self, item)
		JackHUD._data.show_interaction_circle = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_interaction_text = function(self, item)
		JackHUD._data.show_interaction_text = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_text_borders = function(self, item)
		JackHUD._data.show_text_borders = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_truncate_name_tags = function(self, item)
		JackHUD._data.truncate_name_tags = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_show_client_ranks = function(self, item)
		JackHUD._data.show_client_ranks = (item:value() =="on")
		JackHUD:Save()
	end
	MenuCallbackHandler.callback_colorize_names = function(self, item)
		JackHUD._data.colorize_names = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_jackhud_reset = function(self, item)
		local menu_title = managers.localization:text("jackhud_reset")
		local menu_message = managers.localization:text("jackhud_reset_message")
		local menu_options = {
			[1] = {
				text = managers.localization:text("jackhud_reset_ok"),
				callback = function()
					JackHUD:LoadDefaults()
					JackHUD:ForceReloadAllMenus()
					JackHUD:Save()
				end,
			},
			[2] = {
				text = managers.localization:text("jackhud_reset_cancel"),
				is_cancel_button = true,
			},
		}
		QuickMenu:new( menu_title, menu_message, menu_options, true )
	end

	--[[
		Load our previously saved data from our save file.
	]]
	JackHUD:Load()
	JackHUD:InitAllMenus()

	--[[
		Set keybind defaults
	]]
	LuaModManager:SetPlayerKeybind("load_pre", LuaModManager:GetPlayerKeybind("load_pre") or "f5")
	LuaModManager:SetPlayerKeybind("save_pre", LuaModManager:GetPlayerKeybind("save_pre") or "f6")
end )
