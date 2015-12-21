if not JackHUD then
	return
end

local _setup_item_rows_original = MenuNodeGui._setup_item_rows

function MenuNodeGui:_setup_item_rows(node, ...)
	_setup_item_rows_original(self, node, ...)
	if JackHUD._poco_conf and not JackHUD._poco_warning then
		JackHUD._fixed_poco_conf = deep_clone(JackHUD._poco_conflicting_defaults)
		for k,v in pairs(JackHUD._poco_conf.buff) do
			JackHUD._fixed_poco_conf.buff[k] = v
		end
		for k,v in pairs(JackHUD._poco_conf.game) do
			JackHUD._fixed_poco_conf.game[k] = v
		end
		for k,v in pairs(JackHUD._poco_conf.playerBottom) do
			JackHUD._fixed_poco_conf.playerBottom[k] = v
		end
		local conflict_found = nil
		local buff = JackHUD._fixed_poco_conf.buff
		if buff then
			if buff.hideInteractionCircle ~= nil then
				JackHUD._fixed_poco_conf.buff.hideInteractionCircle = nil
				conflict_found = true
			end
			if buff.showBoost ~= false then
				JackHUD._fixed_poco_conf.buff.showBoost = false
				conflict_found = true
			end
			if buff.showCharge ~= false then
				JackHUD._fixed_poco_conf.buff.showCharge = false
				conflict_found = true
			end
			if buff.showECM ~= false then
				JackHUD._fixed_poco_conf.buff.showECM = false
				conflict_found = true
			end
			if buff.showFeedback ~= false then
				JackHUD._fixed_poco_conf.buff.showFeedback = false
				conflict_found = true
			end
			if buff.showInteraction ~= false then
				JackHUD._fixed_poco_conf.buff.showInteraction = false
				conflict_found = true
			end
			if buff.showReload ~= false then
				JackHUD._fixed_poco_conf.buff.showReload = false
				conflict_found = true
			end
			if buff.showShield ~= false then
				JackHUD._fixed_poco_conf.buff.showShield = false
				conflict_found = true
			end
			if buff.showStamina ~= false then
				JackHUD._fixed_poco_conf.buff.showStamina = false
				conflict_found = true
			end
			if buff.showSwanSong ~= false then
				JackHUD._fixed_poco_conf.buff.showSwanSong = false
				conflict_found = true
			end
			if buff.showTapeLoop ~= false then
				JackHUD._fixed_poco_conf.buff.showTapeLoop = false
				conflict_found = true
			end
			if buff.simpleBusyIndicator ~= false then
				JackHUD._fixed_poco_conf.buff.simpleBusyIndicator = false
				conflict_found = true
			end
		end
		local game = JackHUD._fixed_poco_conf.game
		if game then
			if game.interactionClickStick ~= false then
				JackHUD._fixed_poco_conf.game.interactionClickStick = false
				conflict_found = true
			end
			if game.rememberGadgetState ~= false then
				JackHUD._fixed_poco_conf.game.rememberGadgetState = false
				conflict_found = true
			end
			if game.truncateNames ~= nil then
				JackHUD._fixed_poco_conf.game.truncateNames = nil
				conflict_found = true
			end
		end
		local playerBottom = JackHUD._fixed_poco_conf.playerBottom
		if playerBottom then
			if not playerBottom.showDetectionRisk or playerBottom.showDetectionRisk > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showDetectionRisk = 0
				conflict_found = true
			end
			if not playerBottom.showDowns or playerBottom.showDowns > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showDowns = 0
				conflict_found = true
			end
			if not playerBottom.showInteraction or playerBottom.showInteraction > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showInteraction = 0
				conflict_found = true
			end
			if not playerBottom.showInteractionTime or playerBottom.showInteractionTime > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showInteractionTime = 0
				conflict_found = true
			end
			if not playerBottom.showKill or playerBottom.showKill > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showKill = 0
				conflict_found = true
			end
			if not playerBottom.showSpecial or playerBottom.showSpecial > 0 then
				JackHUD._fixed_poco_conf.playerBottom.showSpecial = 0
				conflict_found = true
			end
			if playerBottom.showRank ~= false then
				JackHUD._fixed_poco_conf.playerBottom.showRank = false
				conflict_found = true
			end
			if playerBottom.uppercaseNames ~= false then
				JackHUD._fixed_poco_conf.playerBottom.uppercaseNames = false
				conflict_found = true
			end
		end
		if conflict_found and not JackHUD._poco_warning then
			local menu_title = "JackHUD: PocoHUD config incompatible"
			local menu_message = "Found some conflicting PocoHUD settings. Click ok to fix the conflicting settings."
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
