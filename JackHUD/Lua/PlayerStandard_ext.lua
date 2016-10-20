
local _do_action_intimidate_original = PlayerStandard._do_action_intimidate
local _start_action_melee_original = PlayerStandard._start_action_melee
local _interupt_action_melee_original = PlayerStandard._interupt_action_melee
local _do_melee_damage_original = PlayerStandard._do_melee_damage
local _start_action_interact_original = PlayerStandard._start_action_interact
local _interupt_action_interact_original = PlayerStandard._interupt_action_interact
local _start_action_charging_weapon_original = PlayerStandard._start_action_charging_weapon
local _end_action_charging_weapon_original = PlayerStandard._end_action_charging_weapon
local _start_action_reload_original = PlayerStandard._start_action_reload
local _update_reload_timers_original = PlayerStandard._update_reload_timers
local _interupt_action_reload_original = PlayerStandard._interupt_action_reload
local _update_melee_timers_original = PlayerStandard._update_melee_timers
local _do_melee_damage_original = PlayerStandard._do_melee_damage
local _interupt_action_melee_original = PlayerStandard._interupt_action_melee
local _check_action_throw_grenade_original = PlayerStandard._check_action_throw_grenade
local _check_action_interact_original = PlayerStandard._check_action_interact
local update_original = PlayerStandard.update

function PlayerStandard:_do_action_intimidate(t, interact_type, ...)
	if interact_type == "cmd_gogo" or interact_type == "cmd_get_up" then
		local duration = (tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1)) or 3.5
		managers.gameinfo:event("timed_buff", "activate", "inspire_debuff", { duration = duration })
	end
	
	return _do_action_intimidate_original(self, t, interact_type, ...)
end

function PlayerStandard:_start_action_melee(t, input, instant, ...)
	if not instant then
		local duration = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time
		managers.gameinfo:event("player_action", "activate", "melee_charge")
		managers.gameinfo:event("player_action", "set_duration", "melee_charge", { duration = duration })
	end
	
	return _start_action_melee_original(self, t, input, instant, ...)
end

function PlayerStandard:_interupt_action_melee(...)
	if self._state_data.melee_start_t then
		managers.gameinfo:event("player_action", "deactivate", "melee_charge")
	end
	
	return _interupt_action_melee_original(self, ...)
end

function PlayerStandard:_do_melee_damage(t, ...)
	if self._state_data.melee_start_t then
		managers.gameinfo:event("player_action", "deactivate", "melee_charge")
	end
	
	local result = _do_melee_damage_original(self, t, ...)
	
	if self._state_data.stacking_dmg_mul then
		self:_check_damage_stack_skill(t, "melee")
	end
	
	return result
end

function PlayerStandard:_start_action_interact(t, input, timer, interact_object, ...)
	if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
		local value = managers.player:upgrade_value("player", "interacting_damage_multiplier", 0)
		managers.gameinfo:event("buff", "activate", "die_hard")
		managers.gameinfo:event("buff", "set_value", "die_hard", { value = value })
	end
	
	managers.gameinfo:event("player_action", "activate", "interact", { duration = timer })
	managers.gameinfo:event("player_action", "set_data", "interact", { interact_id = interact_object:interaction().tweak_data })
	
	return _start_action_interact_original(self, t, input, timer, interact_object, ...)
end

function PlayerStandard:_interupt_action_interact(t, input, complete, ...)
	if self._interact_expire_t then
		if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
			managers.gameinfo:event("buff", "deactivate", "die_hard")
		end
		
		managers.gameinfo:event("player_action", "set_data", "interact", { completed = complete and true or false })
		managers.gameinfo:event("player_action", "deactivate", "interact")
	end
	
	return _interupt_action_interact_original(self, t, input, complete, ...)
end

function PlayerStandard:_start_action_charging_weapon(t, ...)
	managers.gameinfo:event("player_action", "activate", "weapon_charge")
	managers.gameinfo:event("player_action", "set_duration", "weapon_charge", { duration = self._equipped_unit:base():charge_max_t() })
	return _start_action_charging_weapon_original(self, t, ...)
end

function PlayerStandard:_end_action_charging_weapon(...)
	if self._state_data.charging_weapon then
		managers.gameinfo:event("player_action", "deactivate", "weapon_charge")
	end
	return _end_action_charging_weapon_original(self, ...)
end

--OVERRIDE
function PlayerStandard:_update_omniscience(t, dt)
	local action_forbidden = 
		not managers.player:has_category_upgrade("player", "standstill_omniscience") or 
		managers.player:current_state() == "civilian" or 
		self:_interacting() or 
		self._ext_movement:has_carry_restriction() or 
		self:is_deploying() or 
		self:_changing_weapon() or 
		self:_is_throwing_projectile() or 
		self:_is_meleeing() or 
		self:_on_zipline() or 
		self._moving or 
		self:running() or 
		self:_is_reloading() or 
		self:in_air() or 
		self:in_steelsight() or 
		self:is_equipping() or 
		self:shooting() or 
		not managers.groupai:state():whisper_mode() or 
		not tweak_data.player.omniscience
	
	if action_forbidden then
		if self._state_data.omniscience_t then
			managers.gameinfo:event("buff", "deactivate", "sixth_sense")
			self._state_data.omniscience_t = nil
		end
		return
	end
	
	if not self._state_data.omniscience_t then
		managers.gameinfo:event("buff", "activate", "sixth_sense")
		managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.start_t })
		managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = nil })
	end
	
	self._state_data.omniscience_t = self._state_data.omniscience_t or t + tweak_data.player.omniscience.start_t
	if t >= self._state_data.omniscience_t then
		local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, managers.slot:get_mask("trip_mine_targets"))
		managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = #sensed_targets })
		
		for _, unit in ipairs(sensed_targets) do
			if alive(unit) and not unit:base():char_tweak().is_escort then
				self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}
				if not self._state_data.omniscience_units_detected[unit:key()] or t >= self._state_data.omniscience_units_detected[unit:key()] then
					self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t
					managers.game_play_central:auto_highlight_enemy(unit, true)
				end
			else
			end
		end
		self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
		managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.interval_t })
	end
end


--local PREV_DMG_STACK = {}	--Prevent event flooding
function PlayerStandard:_check_damage_stack_skill(t, category)
	local stack = self._state_data.stacking_dmg_mul[category]
	
	if stack then
		local buff_id = category .. "_stack_damage"
		
		--if not PREV_DMG_STACK[category] or (PREV_DMG_STACK[category][1] ~= stack[1] or PREV_DMG_STACK[category][2] ~= stack[2]) then
		--	PREV_DMG_STACK[category] = { stack[1], stack[2] }
			
			if stack[2] > 0 then
				local value = managers.player:upgrade_value(category, "stacking_hit_damage_multiplier", 0)
				managers.gameinfo:event("timed_buff", "activate", buff_id, { expire_t = stack[1] })
				managers.gameinfo:event("buff", "set_stack_count", buff_id, { stack_count = stack[2] })
				managers.gameinfo:event("buff", "set_value", buff_id, { value = 1 + stack[2] * value })
			else
				managers.gameinfo:event("buff", "deactivate", buff_id)
			end
		--end
	end
end

--JackHUD

local TIMEOUT = 0.25

function PlayerStandard:update(t, ...)
	managers.hud:update_inspire_timer(self._ext_movement:morale_boost() and managers.enemy:get_delayed_clbk_expire_t(self._ext_movement:morale_boost().expire_clbk_id) - t or -1)
	return update_original(self, t, ...)
end

function PlayerStandard:_start_action_reload(t, ...)
_start_action_reload_original(self, t, ...)
	if self._equipped_unit:base():can_reload() and managers.player:current_state() ~= "bleed_out" and JackHUD:GetOption("show_reload_interaction") then
		self._state_data._isReloading = true
		managers.hud:show_interaction_bar(0, self._state_data.reload_expire_t or 0)
		self._state_data.reload_offset = t
	end
	if self._state_data.reload_expire_t then
		managers.gameinfo:event("player_action", "activate", "reload", { duration = self._state_data.reload_expire_t - t })
	end
end

function PlayerStandard:_update_reload_timers(t, dt, input)
_update_reload_timers_original(self, t, dt, input)
	if JackHUD:GetOption("show_reload_interaction") then
		if not self._state_data.reload_expire_t and self._state_data._isReloading then
			managers.hud:hide_interaction_bar(true)
			self._state_data._isReloading = false
		elseif self._state_data._isReloading and managers.player:current_state() ~= "bleed_out" then
			managers.hud:set_interaction_bar_width(
				t and t - self._state_data.reload_offset or 0,
				self._state_data.reload_expire_t and self._state_data.reload_expire_t - self._state_data.reload_offset or 0
			)
		end
	end
	
	local reloading = self._state_data.reload_expire_t
	
	if reloading and not self._state_data.reload_expire_t then
		managers.gameinfo:event("player_action", "deactivate", "reload")
	end
	
end

function PlayerStandard:_interupt_action_reload(t)
	if self._state_data._isReloading and managers.player:current_state() ~= "bleed_out" and JackHUD:GetOption("show_reload_interaction") then
		managers.hud:hide_interaction_bar(false)
		self._state_data._isReloading = false
	end
	if self._state_data.reload_expire_t then
		managers.gameinfo:event("player_action", "deactivate", "reload")
	end
	return _interupt_action_reload_original(self, t)
end

function PlayerStandard:_update_melee_timers(t, ...)
	if JackHUD:GetOption("show_melee_interaction") then
		if self._state_data.meleeing and not self._state_data.melee_attack_allowed_t and not tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].instant then
			if math.clamp(t - (self._state_data.melee_start_t or 0), 0, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time) < 0.12 or self._state_data._at_max_melee then
			elseif math.clamp(t - (self._state_data.melee_start_t or 0), 0, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time) >= tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time then
				managers.hud:hide_interaction_bar(true)
				self._state_data._at_max_melee = true
			elseif math.clamp(t - (self._state_data.melee_start_t or 0), 0, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time) >= 0.12 and self._state_data._need_show_interact == nil then
				self._state_data._need_show_interact = true
			elseif self._state_data._need_show_interact then
				managers.hud:show_interaction_bar(0, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time or 0)
				self._state_data._need_show_interact = false
			else
				managers.hud:set_interaction_bar_width(math.clamp(t - (self._state_data.melee_start_t or 0), 0, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time), tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time)
			end
		end
	end
	return _update_melee_timers_original(self, t, ...)
end

function PlayerStandard:_do_melee_damage(t, ...)
	
	if JackHUD:GetOption("show_melee_interaction") then
		managers.hud:hide_interaction_bar(false)
		self._state_data._need_show_interact = nil
		self._state_data._at_max_melee = nil
	end
	_do_melee_damage_original(self, t, ...)
end

function PlayerStandard:_interupt_action_melee(...)
	if JackHUD:GetOption("show_melee_interaction") and self._state_data.meleeing then
		self._state_data._need_show_interact = nil
		self._state_data._at_max_melee = nil
		managers.hud:hide_interaction_bar(false)
	end
	_interupt_action_melee_original(self, ...)
end

function PlayerStandard:_check_action_throw_grenade(t, input, ...)
	if input.btn_throw_grenade_press then
		if JackHUD:GetOption("anti_stealth_grenades") and managers.groupai:state():whisper_mode() and (t - (self._last_grenade_t or 0) >= TIMEOUT) then
			self._last_grenade_t = t
			return
		end
	end
	return _check_action_throw_grenade_original(self, t, input, ...)
end

function PlayerStandard:_check_action_interact(t, input, ...)
	if not (self:_check_interact_toggle(t, input) and JackHUD:GetOption("push_to_interact")) then
		return _check_action_interact_original(self, t, input, ...)
	end
end

function PlayerStandard:_check_interact_toggle(t, input)
	local interrupt_key_press = input.btn_interact_press
	if JackHUD:GetOption("equipment_interrupt") then
		interrupt_key_press = input.btn_use_item_press
	end
	if interrupt_key_press and self:_interacting() then
		self:_interupt_action_interact()
		return true
	elseif input.btn_interact_release and self._interact_params then
		return true
	end
end