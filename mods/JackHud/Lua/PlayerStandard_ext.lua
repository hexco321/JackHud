if not JackHUD then
	return
end

local SHOW_BUFFS = JackHUD._data.show_buffs

if SHOW_BUFFS then

	local _start_action_charging_weapon_original = PlayerStandard._start_action_charging_weapon
	local _end_action_charging_weapon_original = PlayerStandard._end_action_charging_weapon
	local _update_charging_weapon_timers_original = PlayerStandard._update_charging_weapon_timers
	local _start_action_melee_original = PlayerStandard._start_action_melee
	local _update_melee_timers_original = PlayerStandard._update_melee_timers
	local _do_melee_damage_original = PlayerStandard._do_melee_damage
	local _do_action_intimidate_original = PlayerStandard._do_action_intimidate
	local _check_action_primary_attack_original = PlayerStandard._check_action_primary_attack

	function PlayerStandard:_update_omniscience(t, dt)
		if managers.groupai:state():whisper_mode() then
			local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or managers.player:current_state() == "civilian" or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_grenade() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not tweak_data.player.omniscience
			if action_forbidden then
				if self._state_data.omniscience_t then
					--managers.player:set_buff_attribute("sixth_sense", "stack_count", 0)
					managers.player:deactivate_buff("sixth_sense")
					self._state_data.omniscience_t = nil
					self._state_data.omniscience_units_detected = {}
				end
				return
			end

			if not self._state_data.omniscience_t then
				managers.player:activate_timed_buff("sixth_sense", tweak_data.player.omniscience.start_t + 0.05)
				managers.player:set_buff_attribute("sixth_sense", "stack_count", 0)
				self._state_data.omniscience_t = t + tweak_data.player.omniscience.start_t
			end

			if t >= self._state_data.omniscience_t then
				local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, World:make_slot_mask(12, 21, 33))
				self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}
				managers.player:set_buff_attribute("sixth_sense", "stack_count", #sensed_targets, true)

				for _, unit in ipairs(sensed_targets) do
					if alive(unit) and not tweak_data.character[unit:base()._tweak_table].is_escort and not unit:anim_data().tied then
						if not self._state_data.omniscience_units_detected[unit:key()] or t >= self._state_data.omniscience_units_detected[unit:key()] then
							self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t
							managers.game_play_central:auto_highlight_enemy(unit, true)
							--managers.player:set_buff_attribute("sixth_sense", "flash")
							break
						end
					end
				end
				self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
				managers.player:activate_timed_buff("sixth_sense", tweak_data.player.omniscience.interval_t + 0.05)
			end
		end
	end

	function PlayerStandard:_start_action_charging_weapon(...)
		managers.player:activate_buff("bow_charge")
		managers.player:set_buff_attribute("bow_charge", "progress", 0)
		return _start_action_charging_weapon_original(self, ...)
	end

	function PlayerStandard:_end_action_charging_weapon(...)
		managers.player:deactivate_buff("bow_charge")
		return _end_action_charging_weapon_original(self, ...)
	end

	function PlayerStandard:_update_charging_weapon_timers(...)
		if self._state_data.charging_weapon then
			local weapon = self._equipped_unit:base()
			if not weapon:charge_fail() then
				managers.player:set_buff_attribute("bow_charge", "progress", weapon:charge_multiplier())
			end
		end
		return _update_charging_weapon_timers_original(self, ...)
	end

	function PlayerStandard:_start_action_melee(...)
		managers.player:set_buff_attribute("melee_charge", "progress", 0)
		return _start_action_melee_original(self, ...)
	end

	function PlayerStandard:_update_melee_timers(t, ...)
		if self._state_data.meleeing and self._state_data.melee_start_t and self._state_data.melee_start_t + 0.3 < t then
			managers.player:activate_buff("melee_charge")
			managers.player:set_buff_attribute("melee_charge", "progress", self:_get_melee_charge_lerp_value(t))
		end
		return _update_melee_timers_original(self, t, ...)
	end

	function PlayerStandard:_do_melee_damage(t, ...)
		managers.player:deactivate_buff("melee_charge")

		local result = _do_melee_damage_original(self, t, ...)
		if self._state_data.stacking_dmg_mul then
			local stack = self._state_data.stacking_dmg_mul.melee
			if stack then
				if stack[2] > 0 then
					managers.player:activate_timed_buff("melee_stack_damage", (stack[1] or 0) - t)
					managers.player:set_buff_attribute("melee_stack_damage", "stack_count", stack[2])
				else
					managers.player:deactivate_buff("melee_stack_damage")
				end
			end
		end
		return result
	end

	function PlayerStandard:_do_action_intimidate(t, interact_type, ...)
		if interact_type == "cmd_gogo" or interact_type == "cmd_get_up" then
			managers.player:activate_timed_buff("inspire_debuff", self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		end
		return _do_action_intimidate_original(self, t, interact_type, ...)
	end

	function PlayerStandard:_check_action_primary_attack(t, ...)
		local result = _check_action_primary_attack_original(self, t, ...)
		if self._state_data.stacking_dmg_mul then
			local weapon_category = self._equipped_unit:base():weapon_tweak_data().category
			local stack = self._state_data.stacking_dmg_mul[weapon_category]
			if stack then
				if stack[2] > 0 then
					managers.player:activate_timed_buff("trigger_happy", (stack[1] or 0) - t)
					managers.player:set_buff_attribute("trigger_happy", "stack_count", stack[2])
				else
					managers.player:deactivate_buff("trigger_happy")
				end
			end
		end
		return result
	end

end

local TIMEOUT = 0.25

local _check_action_throw_grenade_original = PlayerStandard._check_action_throw_grenade

function PlayerStandard:_check_action_throw_grenade(t, input, ...)
	if input.btn_throw_grenade_press then
		if managers.groupai:state():whisper_mode() and (t - (self._last_grenade_t or 0) >= TIMEOUT) then
			self._last_grenade_t = t
			return
		end
	end

	return _check_action_throw_grenade_original(self, t, input, ...)
end

local _check_action_interact_original = PlayerStandard._check_action_interact
function PlayerStandard:_check_action_interact(t, input, ...)
	if not (self:_check_interact_toggle(t, input) and JackHUD._data.push_to_interact) then
		return _check_action_interact_original(self, t, input, ...)
	end
end

function PlayerStandard:_check_interact_toggle(t, input)
	local interrupt_key_press = input.btn_interact_press
	if JackHUD._data.equipment_interrupt then
		interrupt_key_press = input.btn_use_item_press
	end
	if interrupt_key_press and self:_interacting() then
		self:_interupt_action_interact()
		return true
	elseif input.btn_interact_release and self._interact_params then
		return true
	end
end
