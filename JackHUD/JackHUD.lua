if not Steam then
	return
end

--[[
	We setup the global table for our mod, along with some path variables, and a data table.
	We cache the ModPath directory, so that when our hooks are called, we aren't using the ModPath from a
		different mod.
]]
JackHUD = JackHUD or {}
if not JackHUD.setup then
	JackHUD._path = ModPath
	JackHUD._lua_path = ModPath .. "Lua/"
	JackHUD._data_path = SavePath .. "JackHUD.txt"
	JackHUD._poco_path = SavePath .. "hud3_config.json"
	JackHUD._data = {}
	JackHUD._menus = {
		"jackhud_options"
		,"jackhud_menu_tweaks"
		,"jackhud_hud_tweaks"
		,"hud_lists_options"
		,"kill_counter_options"
		,"hps_meter"
		,"menu_push_to_interact"
		,"gadget_options"
		,"jackhud_gameplay_tweaks"
	}
	JackHUD._hook_files = {
		["lib/managers/menumanager"] = "MenuManager_ext.lua",
		["lib/managers/group_ai_states/groupaistatebase"] = "GroupAIStateBase_ext.lua",
		["lib/managers/hud/hudassaultcorner"] = "HUDAssaultCorner_ext.lua",
		["lib/managers/hud/hudinteraction"] = "HUDInteraction_ext.lua",
		["lib/managers/hud/hudstatsscreen"] = "HUDStatsScreen_ext.lua",
		["lib/managers/hud/hudpresenter"] = "HUDPresenter_ext.lua",
		["lib/managers/hud/hudsuspicion"] = "HUDSuspicion_ext.lua",
		["lib/managers/hud/hudteammate"] = "HUDTeammate_ext.lua",
		["lib/managers/menu/lootdropscreengui"] = "LootDropScreenGui_ext.lua",
		["lib/managers/menu/menubackdropgui"] = "MenuBackDropGUI_ext.lua",
		["lib/managers/menu/menunodegui"] = "MenuNodeGui_ext.lua",
		["lib/managers/menu/menuscenemanager"] = "MenuSceneManager_ext.lua",
		["lib/managers/menu/stageendscreengui"] = "StageEndScreenGui_ext.lua",
		["lib/managers/enemymanager"] = "EnemyManager_ext.lua",
		["lib/managers/hudmanager"] = "HUDManager_ext.lua",
		["lib/managers/hudmanagerpd2"] = "HUDManagerPD2_ext.lua",
		["lib/managers/localizationmanager"] = "LocalizationManager_ext.lua",
		["lib/managers/missionassetsmanager"] = "MissionAssetsManager_ext.lua",
		["lib/managers/objectinteractionmanager"] = "ObjectInteractionManager_ext.lua",
		["lib/managers/playermanager"] = "PlayerManager_ext.lua",
		["lib/network/base/handlers/connectionnetworkhandler"] = "ConnectionNetworkHandler_ext.lua",
		["lib/network/handlers/unitnetworkhandler"] = "UnitNetworkHandler_ext.lua",
		["lib/states/ingamewaitingforplayers"] = "IngameWaitingForPlayersState_ext.lua",
		["lib/units/beings/player/states/playercivilian"] = "PlayerCivilian_ext.lua",
		["lib/units/beings/player/states/playerdriving"] = "PlayerDriving_ext.lua",
		["lib/units/beings/player/states/playerstandard"] = "PlayerStandard_ext.lua",
		["lib/units/beings/player/playerdamage"] = "PlayerDamage_ext.lua",
		["lib/units/beings/player/playermovement"] = "PlayerMovement_ext.lua",
		["lib/units/equipment/ammo_bag/ammobagbase"] = "AmmoBagBase_ext.lua",
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] = "BodyBagBase_ext.lua",
		["lib/units/equipment/doctor_bag/doctorbagbase"] = "DoctorBagBase_ext.lua",
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] = "ECMJammerBase_ext.lua",
		["lib/units/equipment/grenade_crate/grenadecratebase"] = "GrenadeCrateBase_ext.lua",
		["lib/units/equipment/sentry_gun/sentrygunbase"] = "SentryGunBase_ext.lua",
		["lib/units/equipment/sentry_gun/sentrygundamage"] = "SentryGunDamage_ext.lua",
		["lib/units/enemies/cop/copdamage"] = "CopDamage_ext.lua",
		["lib/units/props/digitalgui"] = "DigitalGui_ext.lua",
		["lib/units/props/securitycamera"] = "SecurityCamera_ext.lua",
		["lib/units/props/timergui"] = "TimerGui_ext.lua",
		["lib/units/weapons/newraycastweaponbase"] = "NewRayCastWeaponBase_ext.lua",
		["lib/units/weapons/raycastweaponbase"] = "RayCastWeaponBase_ext.lua",
		["lib/units/weapons/sentrygunweapon"] = "SentryGunWeapon_ext.lua",
		["lib/units/weapons/weaponflashlight"] = "WeaponFlashlight_ext.lua",
		["lib/units/weapons/weaponlaser"] = "WeaponLaser_ext.lua",
		["lib/setups/setup"] = "Setup_ext.lua",
		["lib/units/props/securitylockgui"] = "SecurityLockGui_ext.lua",
		["lib/units/interactions/interactionext"] = "InteractionExt_ext.lua",
		["lib/player_actions/skills/playeractionbloodthirstbase"] = "PlayerActionBloodThirsBase_ext.lua",
		["lib/player_actions/skills/playeractionexperthandling"] = "PlayerActionExpertHandling_ext.lua",
		["lib/player_actions/skills/playeractionshockandawe"] = "PlayerActionShockAndAwe_ext.lua",
		["lib/player_actions/skills/playeractiondireneed"] = "PlayerActionDireNeed_ext.lua",
		["lib/player_actions/skills/playeractionunseenstrike"] = "PlayerActionUnseenStrike_ext.lua",
		["lib/player_actions/skills/playeractionammoefficiency"] = "PlayerActionAmmoEfficiency_ext.lua",
		["lib/player_actions/skills/playeractiontriggerhappy"] = "PlayerActionTriggerHappy_ext.lua",
		["lib/utils/temporarypropertymanager"] = "TemporaryPropertyManager_ext.lua"
	}
	JackHUD._poco_conflicting_defaults = {
		buff = {
			mirrorDirection = true,
			showBoost = true,
			showCharge = true,
			showECM = true,
			showInteraction = true,
			showReload = true,
			showShield = true,
			showStamina = true,
			showSwanSong = true,
			showTapeLoop = true,
			simpleBusyIndicator = true
		},
		game = {
			interactionClickStick = true
		},
		playerBottom = {
			showRank = true,
			uppercaseNames = true
		}
	}

	--[[
		A simple save function that json encodes our _data table and saves it to a file.
	]]
	function JackHUD:Save()
		local file = io.open(self._data_path, "w+")
		if file then
			file:write(json.encode(self._data))
			file:close()
		end
	end

	--[[
		A simple load function that decodes the saved json _data table if it exists.
	]]
	function JackHUD:Load()
		self:LoadDefaults()
		local file = io.open(self._data_path, "r")
		if file then
			local configt = json.decode(file:read("*all"))
			file:close()
			for k,v in pairs(configt) do
				self._data[k] = v
			end
		end
		self:Save()
		self:CheckPoco()
	end

	function JackHUD:GetOption(id)
		return self._data[id]
	end

	function JackHUD:LoadDefaults()
		local default_file = io.open(self._path .."Menu/default_values.txt")
		self._data = json.decode(default_file:read("*all"))
		default_file:close()
	end

	function JackHUD:InitAllMenus()
		for _,menu in pairs(self._menus) do
			MenuHelper:LoadFromJsonFile(self._path .. "Menu/" .. menu .. ".txt", self, self._data)
		end
	end

	function JackHUD:ForceReloadAllMenus()
		for _,menu in pairs(self._menus) do
			for _,_item in pairs(MenuHelper:GetMenu(menu)._items_list) do
				if _item._type == "toggle" then
					_item.selected = self._data[_item._parameters.name] and 1 or 2
				elseif _item._type == "multi_choice" then
					_item._current_index = self._data[_item._parameters.name]
				elseif _item._type == "slider" then
					_item._value = self._data[_item._parameters.name]
				end
			end
		end
	end

	function JackHUD:CheckPoco()
		local file = io.open(self._poco_path)
		if file then
			self._poco_conf = json.decode( file:read("*all") )
			file:close()
		end
	end

	function JackHUD:ApplyFixedPocoSettings()
		local file = io.open( self._poco_path, "w+" )
		if file and self._fixed_poco_conf then
			file:write( json.encode( self._fixed_poco_conf ) )
			file:close()
			local menu_title = "JackHUD: PocoHUD config fixed"
			local menu_message = "Config fixed. You NEED to restart the game NOW, to finish the process."
			local menu_options = {
				[1] = {
					text = "ok, i understand",
					is_cancel_button = true,
				}
			}
			QuickMenu:new( menu_title, menu_message, menu_options, true )
		end
	end

	function JackHUD:SafeDoFile(fileName)
		local success, errorMsg = pcall(function()
			if io.file_is_readable(fileName) then
				dofile(fileName)
			else
				log("[Error] Could not open file '" .. fileName .. "'! Does it exist, is it readable?")
			end
		end)
		if not success then
			log("[Error]\nFile: " .. fileName .. "\n" .. errorMsg)
		end
	end

	function JackHUD:MakeOutlineText(panel, bg, txt)
		bg.name = nil
		local bgs = {}
		for i = 1, 4 do
			table.insert(bgs, panel:text(bg))
		end
		bgs[1]:set_x(txt:x() - 1)
		bgs[1]:set_y(txt:y() - 1)
		bgs[2]:set_x(txt:x() + 1)
		bgs[2]:set_y(txt:y() - 1)
		bgs[3]:set_x(txt:x() - 1)
		bgs[3]:set_y(txt:y() + 1)
		bgs[4]:set_x(txt:x() + 1)
		bgs[4]:set_y(txt:y() + 1)
		return bgs
	end

	function JackHUD:GetVersion()
		local version = "1.0"
		local revision = "0"
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "JackHUD" then
				version = info["version"]
				local updates = info["updates"]
				if updates then
					for k2, v2 in pairs(updates) do
						if v2.identifier == "jackhud" then
							revision = v2.revision
						end
					end
				end
			end
		end
		return version, revision
	end

	function JackHUD:GetJackPackVersion()
		local version = "1.0"
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "JackPackVersion" then
				version = info["version"]
			end
		end
		return version
	end

	function JackHUD:ShowJackPackDownloads()
		os.execute("start https://cloud.bangl.de/index.php/s/P5iWCDJgq8zBHiA?path=%2FJackPacks")
	end

	JackHUD:Load()
	JackHUD.setup = true
	log("JackHUD loaded.")
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if JackHUD._hook_files[requiredScript] then
		JackHUD:SafeDoFile(JackHUD._lua_path .. JackHUD._hook_files[requiredScript])
	else
		log("JackHUD: unlinked script called: " .. requiredScript)
	end
end
