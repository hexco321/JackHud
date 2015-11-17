
--[[
	We setup the global table for our mod, along with some path variables, and a data table.
	We cache the ModPath directory, so that when our hooks are called, we aren't using the ModPath from a
		different mod.
]]
JackHUD = JackHUD or {}
JackHUD._path = ModPath
JackHUD._data_path = SavePath .. "JackHUD.txt"
JackHUD._data = {}

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
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	else
	log("No previous save found. Creating new using default values")
	local default_file = io.open(self._path .."Menu/default_values.txt")
		if default_file then
			self._data = json.decode( default_file:read("*all") )
			self:Save()
		end
	end
end

if not JackHUD.setup then
	JackHUD:Load()
	JackHUD.setup = true
	log("Mod Collection loaded")
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

--[[
	Setup our menu callbacks, load our saved data, and build the menu from our json file.
]]
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_jackhud", function( menu_manager )

	--[[
		Setup our callbacks as defined in our item callback keys, and perform our logic on the data retrieved.
	]]

	MenuCallbackHandler.callback_show_timers = function(self, item)
		JackHUD._data.show_timers = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_show_equipment = function(self, item)
		JackHUD._data.show_equipment = (item:value() =="on")
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

	MenuCallbackHandler.callback_remove_answered_pager_contour = function(self, item)
		JackHUD._data.remove_answered_pager_contour = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_show_ecms = function(self, item)
		JackHUD._data.show_ecms = (item:value() =="on")
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_show_enemies = function(self, item)
		JackHUD._data.show_enemies = (item:value() =="on")
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_aggregate_enemies = function(self, item)
		JackHUD._data.aggregate_enemies = (item:value() =="on")
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

	MenuCallbackHandler.callback_show_special_pickups = function(self, item)
		JackHUD._data.show_special_pickups = (item:value() =="on")
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_show_buffs = function(self, item)
		JackHUD._data.show_buffs = (item:value() =="on")
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_hide_chat_after = function(self, item)
		JackHUD._data.hide_chat_after = item:value()
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

	MenuCallbackHandler.callback_flashlight_range = function(self, item)
		JackHUD._data.flashlight_range = item:value()
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_flashlight_angle = function(self, item)
		JackHUD._data.flashlight_angle = item:value()
		JackHUD:Save()
	end	

	MenuCallbackHandler.callback_enable_kill_counter = function(self, item)
		JackHUD._data.enable_kill_counter = (item:value() =="on")
		JackHUD:Save()
	end	
	
	MenuCallbackHandler.callback_do_decapitations = function(self, item)
		JackHUD._data.do_decapitations = (item:value() =="on")
		JackHUD:Save()
	end
	
	MenuCallbackHandler.callback_enable_flashlight_extender = function(self, item)
		JackHUD._data.enable_flashlight_extender = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_enable_pacified = function(self, item)
		JackHUD._data.enable_pacified = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_enable_speed_up = function(self, item)
		JackHUD._data.enable_speed_up = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_black_screen_skip = function(self, item)
		JackHUD._data.black_screen_skip = (item:value() =="on")
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_loot_screen_skip = function(self, item)
		JackHUD._data.loot_screen_skip = item:value()
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_stat_screen_skip = function(self, item)
		JackHUD._data.stat_screen_skip = item:value()
		JackHUD:Save()
	end

	MenuCallbackHandler.callback_enable_filtersettings = function(self, item)
		JackHUD._data.enable_filtersettings = item:value()
		JackHUD:Save()
	end
	--[[
		Load our previously saved data from our save file.
	]]
	JackHUD:Load()

	--[[
		Load our menu json file and pass it to our MenuHelper so that it can build our in-game menu for us.
		We pass our parent mod table as the second argument so that any keybind functions can be found and called
			as necessary.
		We also pass our data table as the third argument so that our saved values can be loaded from it.
	]]
	MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/JackHUD.txt", JackHUD, JackHUD._data )
	MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/ingame_options.txt", JackHUD, JackHUD._data )
		MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/hud_lists.txt", JackHUD, JackHUD._data )
		MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/kill_counter.txt", JackHUD, JackHUD._data )
		MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/flashlight_extender.txt", JackHUD, JackHUD._data )
	MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/menu_options.txt", JackHUD, JackHUD._data )
		MenuHelper:LoadFromJsonFile( JackHUD._path .. "Menu/speed_up.txt", JackHUD, JackHUD._data )

end )
