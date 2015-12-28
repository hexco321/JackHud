
local _setup_item_rows_original = MenuNodeMainGui._setup_item_rows

function MenuNodeMainGui:_setup_item_rows(node, ...)
	_setup_item_rows_original(self, node, ...)
	local mod_name = "JackHUD"
	if alive(self._version_string) and not self["_" .. mod_name .. "_version_added"] then
		local version, revision = JackHUD:GetVersion()
		local versionstring = self._version_string:text()
		local fullversion = mod_name .. " v" .. version .. "r" .. revision
		if versionstring == Application:version() then
			self._version_string:set_text("PAYDAY2 v" .. versionstring .. " with " .. fullversion)
		elseif self["_JackPackVersion_version_added"] then
			local jackpack_version = JackHUD:GetJackPackVersion()
			self._version_string:set_text(versionstring .. " (" .. mod_name .. " r" .. revision .. ")")
			if jackpack_version ~= version and not JackHUD._pack_warning then
				JackHUD._pack_warning = true
				QuickMenu:new("Warning", "Seems like there's a new JackPack, you should get it.", {{text = "Thanks", is_cancel_button = true}}, true)
			end
		else
			self._version_string:set_text(versionstring .. " and " .. fullversion)
		end
		self["_" .. mod_name .. "_version_added"] = true
	end
	if JackHUD._poco_conf and not JackHUD._poco_warning then
		JackHUD._fixed_poco_conf = deep_clone(JackHUD._poco_conflicting_defaults)
		for k,v in pairs(JackHUD._poco_conf) do
			if not JackHUD._fixed_poco_conf[k] then
				JackHUD._fixed_poco_conf[k] = v
			else
				for k2,v2 in pairs(JackHUD._poco_conf[k]) do
					JackHUD._fixed_poco_conf[k][k2] = v2
				end
			end
		end
		local conflict_found = nil
		local conflicts = {}
		local buff = JackHUD._fixed_poco_conf.buff
		if buff then
			if buff.hideInteractionCircle ~= nil then
				JackHUD._fixed_poco_conf.buff.hideInteractionCircle = nil
				table.insert(conflicts, "buff.hideInteractionCircle")
				conflict_found = true
			end
			if buff.showBoost ~= false then
				JackHUD._fixed_poco_conf.buff.showBoost = false
				table.insert(conflicts, "buff.showBoost")
				conflict_found = true
			end
			if buff.showCharge ~= false then
				JackHUD._fixed_poco_conf.buff.showCharge = false
				table.insert(conflicts, "buff.showCharge")
				conflict_found = true
			end
			if buff.showECM ~= false then
				JackHUD._fixed_poco_conf.buff.showECM = false
				table.insert(conflicts, "buff.showECM")
				conflict_found = true
			end
			if buff.showInteraction ~= false then
				JackHUD._fixed_poco_conf.buff.showInteraction = false
				table.insert(conflicts, "buff.showInteraction")
				conflict_found = true
			end
			if buff.showReload ~= false then
				JackHUD._fixed_poco_conf.buff.showReload = false
				table.insert(conflicts, "buff.showReload")
				conflict_found = true
			end
			if buff.showShield ~= false then
				JackHUD._fixed_poco_conf.buff.showShield = false
				table.insert(conflicts, "buff.showShield")
				conflict_found = true
			end
			if buff.showStamina ~= false then
				JackHUD._fixed_poco_conf.buff.showStamina = false
				table.insert(conflicts, "buff.showStamina")
				conflict_found = true
			end
			if buff.showSwanSong ~= false then
				JackHUD._fixed_poco_conf.buff.showSwanSong = false
				table.insert(conflicts, "buff.showSwanSong")
				conflict_found = true
			end
			if buff.showTapeLoop ~= false then
				JackHUD._fixed_poco_conf.buff.showTapeLoop = false
				table.insert(conflicts, "buff.showTapeLoop")
				conflict_found = true
			end
			if buff.simpleBusyIndicator ~= false then
				JackHUD._fixed_poco_conf.buff.simpleBusyIndicator = false
				table.insert(conflicts, "buff.simpleBusyIndicator")
				conflict_found = true
			end
		end
		local game = JackHUD._fixed_poco_conf.game
		if game then
			if game.interactionClickStick ~= false then
				JackHUD._fixed_poco_conf.game.interactionClickStick = false
				table.insert(conflicts, "game.interactionClickStick")
				conflict_found = true
			end
			if game.rememberGadgetState ~= false then
				JackHUD._fixed_poco_conf.game.rememberGadgetState = false
				table.insert(conflicts, "game.rememberGadgetState")
				conflict_found = true
			end
			if game.truncateNames ~= nil then
				JackHUD._fixed_poco_conf.game.truncateNames = nil
				table.insert(conflicts, "game.truncateNames")
				conflict_found = true
			end
		end
		local playerBottom = JackHUD._fixed_poco_conf.playerBottom
		if playerBottom then
			if not playerBottom.showDetectionRisk or playerBottom.showDetectionRisk > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showDetectionRisk = 0
				table.insert(conflicts, "playerBottom.showDetectionRisk")
				conflict_found = true
			end
			if not playerBottom.showDowns or playerBottom.showDowns > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showDowns = 0
				table.insert(conflicts, "playerBottom.showDowns")
				conflict_found = true
			end
			if not playerBottom.showInteraction or playerBottom.showInteraction > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showInteraction = 0
				table.insert(conflicts, "playerBottom.showInteraction")
				conflict_found = true
			end
			if not playerBottom.showInteractionTime or playerBottom.showInteractionTime > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showInteractionTime = 0
				table.insert(conflicts, "playerBottom.showInteractionTime")
				conflict_found = true
			end
			if not playerBottom.showKill or playerBottom.showKill > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showKill = 0
				table.insert(conflicts, "playerBottom.showKill")
				conflict_found = true
			end
			if not playerBottom.showSpecial or playerBottom.showSpecial > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showSpecial = 0
				table.insert(conflicts, "playerBottom.showSpecial")
				conflict_found = true
			end
			if playerBottom.showRank ~= false then
				JackHUD._fixed_poco_conf.playerBottom.showRank = false
				table.insert(conflicts, "playerBottom.showRank")
				conflict_found = true
			end
			if playerBottom.uppercaseNames ~= false then
				JackHUD._fixed_poco_conf.playerBottom.uppercaseNames = false
				table.insert(conflicts, "playerBottom.uppercaseNames")
				conflict_found = true
			end
		end
		if conflict_found and not JackHUD._poco_warning then
			local menu_title = "JackHUD: PocoHUD config incompatible"
			local menu_message = "Found some conflicting PocoHUD settings: " .. json.encode(conflicts) ..  " - Click ok to fix the conflicting settings."
			local menu_options = {
				[1] = {
					text = "ok, fix it please",
					callback = function()
						JackHUD:ApplyFixedPocoSettings()
					end,
				},
				[2] = {
					text = "cancel",
					is_cancel_button = true,
				},
			}
			JackHUD._poco_warning = true
			QuickMenu:new( menu_title, menu_message, menu_options, true )
		end
	end
end
