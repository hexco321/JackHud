if not JackHUD then
	return
end

if not HUDTeammate.increment_kill_count then

	local init_original = HUDTeammate.init
	local set_name_original = HUDTeammate.set_name
	local set_state_original = HUDTeammate.set_state
	local set_health_original = HUDTeammate.set_health
	local teammate_progress_original = HUDTeammate.teammate_progress

	function HUDTeammate:init(i, ...)
		init_original(self, i, ...)
		self._is_in_custody = false
		if i == HUDManager.PLAYER_PANEL then
			self:_init_stamina_meter()
			self:_init_armor_timer()
			self:_init_inspire_timer()
		else
			self:_init_interact_info()
		end
		self:_init_killcount()
		self:_init_revivecount()
	end

	function HUDTeammate:_init_stamina_meter()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		local stamina_size = 0.4
		if managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 0) > 0
				or managers.player:upgrade_value("player", "armor_health_store_amount", 0) > 0 then
			stamina_size = 0.3
		end
		self._stamina_bar = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/textures/pd2/hud_radial_rim",
			texture_rect = { 64, 0, -64, 64 },
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			alpha = 1,
			w = radial_health_panel:w() * stamina_size,
			h = radial_health_panel:h() * stamina_size,
			layer = 5
		})
		self._stamina_bar:set_color(Color(1, 1, 0, 0))
		self._stamina_bar:set_center(radial_health_panel:child("radial_health"):center())

		self._stamina_line = radial_health_panel:rect({
			color = Color.red,
			w = radial_health_panel:w() * 0.10,
			h = 1,
			layer = 10,
			alpha = 0,
		})
		self._stamina_line:set_center(radial_health_panel:child("radial_health"):center())
	end

	function HUDTeammate:_init_revivecount()
		self._detection_counter = self._player_panel:child("radial_health_panel"):text({
			name = "detection_risk",
			visible = managers.groupai:state():whisper_mode(),
			layer = 1,
			Color = Color.white,
			w = self._player_panel:child("radial_health_panel"):w(),
			x = 0,
			y = 0,
			h = self._player_panel:child("radial_health_panel"):h(),
			vertical = "center",
			align = "center",
			font_size = 14,
			font = tweak_data.hud_players.ammo_font
		})
		self._revives_counter = self._player_panel:child("radial_health_panel"):text({
			name = "revives_counter",
			visible = not managers.groupai:state():whisper_mode(),
			text = "0",
			layer = 1,
			color = Color.white,
			w = self._player_panel:child("radial_health_panel"):w(),
			x = 0,
			y = 0,
			h = self._player_panel:child("radial_health_panel"):h(),
			vertical = "center",
			align = "center",
			font_size = 14,
			font = tweak_data.hud_players.ammo_font
		})
		self._revives_count = 0
		if self._main_player then
			self:set_detection_risk(managers.blackmarket:get_suspicion_offset_of_local(0.75))
		end
	end

	function HUDTeammate:set_peer_id(peer_id)
		self._peer_id = peer_id
		local session = managers.network:session()
		if session then
			local peer = session:peer(peer_id)
			if peer and alive(peer:unit()) then
				self:set_detection_risk(managers.blackmarket:get_suspicion_offset_of_peer(peer, 0.75))
			end
		end
	end

	function HUDTeammate:_init_killcount()
		self._kills_panel = self._panel:panel({
			name = "kills_panel",
			visible = true,
			w = 100,
			h = 20,
			x = 0,
			halign = "right"
		})
		local player_panel = self._panel:child("player")
		local name_label = self._panel:child("name")
		self._kills_panel:set_rightbottom(player_panel:right(), name_label:bottom())
		self._kill_icon = self._kills_panel:bitmap({
			texture = "guis/textures/pd2/cn_miniskull",
			w = self._kills_panel:h() * 0.75,
			h = self._kills_panel:h(),
			texture_rect = { 0, 0, 12, 16 },
			alpha = 1,
			blend_mode = "add",
			layer = 0,
			color = Color(1, 1, 0.65882355, 0)
		})
		self._kills_text = self._kills_panel:text({
			name = "kills_text",
			text = "-",
			layer = 1,
			color = Color(1, 1, 0.65882355, 0),
			w = self._kills_panel:w() - self._kill_icon:w(),
			h = self._kills_panel:h(),
			vertical = "center",
			align = "right",
			font_size = self._kills_panel:h(),
			font = tweak_data.hud_players.name_font
		})
		self._kills_text:set_right(self._kills_panel:w())
		self:reset_kill_count()
		self:refresh_kill_count_visibility()
	end

	function HUDTeammate:_init_interact_info()
		self._interact_info_panel = self._panel:panel({
			name = "interact_info_panel",
			x = 0,
			y = 0,
			visible = false
		})
		self._interact_info = self._interact_info_panel:text({
			name = "interact_info",
			text = "|",
			layer = 3,
			color = Color.white,
			x = 0,
			y = 1,
			align = "right",
			vertical = "top",
			font_size = tweak_data.hud_players.name_size,
			font = tweak_data.hud_players.name_font
		})
		local _, _, text_w, text_h = self._interact_info:text_rect()
		self._interact_info:set_right(self._interact_info_panel:w() - 8)
		self._interact_info_bg = self._interact_info_panel:bitmap({
			name = "interact_info_bg",
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {
				84,
				0,
				44,
				32
			},
			layer = 2,
			color = Color.white / 3,
			x = 0,
			y = 0,
			align = "left",
			vertical = "bottom",
			w = text_w + 4,
			h = text_h
		})
	end

	function HUDTeammate:_init_inspire_timer()
		self._inspire_timer = self._player_panel:text({
			name = "inspire_timer",
			text = "0.0s",
			color = Color.white,
			visible = false,
			align = "right",
			vertical = "bottom",
			font = tweak_data.hud_players.name_font,
			font_size = 20,
			layer = 4
		})
		self._inspire_timer:set_right(self._player_panel:child("radial_health_panel"):right())
		self._inspire_timer_bg = managers.hud:make_outline_text(self._player_panel, {
			text = "0.0s",
			color = Color.black:with_alpha(0.5),
			visible = false,
			align = "right",
			vertical = "bottom",
			font = tweak_data.hud_players.name_font,
			font_size = 20,
			layer = 3
		}, self._inspire_timer)
	end

	function HUDTeammate:_init_armor_timer()
		self._armor_timer = self._player_panel:text({
			name = "armor_regen",
			text = "0.0s",
			color = Color.white,
			visible = false,
			align = "left",
			vertical = "bottom",
			font = tweak_data.hud_players.name_font,
			font_size = 20,
			layer = 4
		})
		self._armor_timer_bg = managers.hud:make_outline_text(self._player_panel, {
			text = "0.0s",
			color = Color.black:with_alpha(0.5),
			visible = false,
			align = "left",
			vertical = "bottom",
			font = tweak_data.hud_players.name_font,
			font_size = 20,
			layer = 3
		}, self._armor_timer)
	end

	function HUDTeammate:update_inspire_timer(t)
		if t and t > 0 and self._inspire_timer then
			t = string.format("%.1f", t) .. "s"
			self._inspire_timer:set_text(t)
			for _, bg in ipairs(self._inspire_timer_bg) do
				bg:set_text(t)
			end
			self:set_inspire_timer_visibility(JackHUD._data.show_inspire_timer)
		elseif self._inspire_timer and self._inspire_timer:visible() then
			self:set_inspire_timer_visibility(false)
		end
	end

	function HUDTeammate:update_armor_timer(t)
		if t and t > 0 and self._armor_timer then
			t = string.format("%.1f", t) .. "s"
			self._armor_timer:set_text(t)
			for _, bg in ipairs(self._armor_timer_bg) do
				bg:set_text(t)
			end
			self:set_armor_timer_visibility(JackHUD._data.show_armor_timer)
		elseif self._armor_timer and self._armor_timer:visible() then
			self:set_armor_timer_visibility(false)
		end
	end

	function HUDTeammate:teammate_progress(enabled, tweak_data_id, timer, success, ...)
		teammate_progress_original(self, enabled, tweak_data_id, timer, success, ...)
		if enabled then
			self:_start_interact_timer(timer)
		else
			self:_stop_interact_timer()
		end
	end

	function HUDTeammate:_start_interact_timer(interaction_time)
		self._timer_paused = 0
		self._timer = interaction_time
		local condition_timer = self._panel:child("condition_timer")
		condition_timer:set_font_size(tweak_data.hud_players.timer_size)
		condition_timer:set_color(Color.white)
		condition_timer:stop()
		condition_timer:set_visible(true)
		condition_timer:animate(callback(self, self, "_animate_interact_timer"), condition_timer)
	end

	function HUDTeammate:_stop_interact_timer(...)
		if not alive(self._panel) then
			return
		end
		local condition_timer = self._panel:child("condition_timer")
		condition_timer:set_visible(false)
		condition_timer:stop()
	end

	function HUDTeammate:_animate_interact_timer(_, condition_timer)
		while self._timer >= 0 do
			if self._timer_paused == 0 then
				self._timer = self._timer - coroutine.yield()
				if self._timer < 0 then
					self._timer = 0
				end
				condition_timer:set_text(string.format("%.1f", self._timer) .. "s")
				condition_timer:set_color(Color(self._timer / self._timer, 1, self._timer / self._timer))
			end
		end
	end

	function HUDTeammate:set_interact_text(text)
		if not self._interact_info then
			return
		end
		self._interact_info:set_text(text)
		local _, _, w, _ = self._interact_info:text_rect()
		self._interact_info_bg:set_w(w + 8)
		self._interact_info_bg:set_right(self._interact_info:right() + 4)
	end

	function HUDTeammate:set_interact_visible(visible)
		if self._interact_info_panel then
			self._interact_info_panel:set_visible(visible and not self._is_in_custody)
		end
	end

	function HUDTeammate:set_voice_com(status)
		local texture = status and "guis/textures/pd2/jukebox_playing" or "guis/textures/pd2/hud_tabs"
		local texture_rect = status and { 0, 0, 16, 16 } or { 84, 34, 19, 19 }
		local callsign = self._panel:child("callsign")
		callsign:set_image(texture, unpack(texture_rect))
	end

	function HUDTeammate:set_max_stamina(value)
		self._max_stamina = value
		local w = self._stamina_bar:w()
		local threshold = tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
		local angle = 360 * (1 - threshold/self._max_stamina) - 90
		local x = 0.5 * w * math.cos(angle) + w * 0.5 + self._stamina_bar:x()
		local y = 0.5 * w * math.sin(angle) + w * 0.5 + self._stamina_bar:y()
		self._stamina_line:set_x(x)
		self._stamina_line:set_y(y)
		self._stamina_line:set_rotation(angle)
	end

	function HUDTeammate:set_current_stamina(value)
		self._stamina_bar:set_color(Color(1, value/self._max_stamina, 0, 0))
	end

	function HUDTeammate:increment_revives()
		if self._revives_counter then
			self._revives_count = self._revives_count + 1
			self._revives_counter:set_text(tostring(self._revives_count))
		end
	end

	function HUDTeammate:reset_revives()
		if self._revives_counter then
			self._revives_count = 0
			self._revives_counter:set_text(tostring(self._revives_count))
		end
	end

	function HUDTeammate:set_armor_timer_visibility(visible)
		if self._armor_timer then
			self._armor_timer:set_visible(visible and not self._is_in_custody)
			for _, bg in ipairs(self._armor_timer_bg) do
				bg:set_visible(visible and not self._is_in_custody)
			end
		end
	end

	function HUDTeammate:set_inspire_timer_visibility(visible)
		if self._inspire_timer then
			self._inspire_timer:set_visible(visible and not self._is_in_custody)
			for _, bg in ipairs(self._inspire_timer_bg) do
				bg:set_visible(visible and not self._is_in_custody)
			end
		end
	end

	function HUDTeammate:set_revive_visibility(visible)
		if self._revives_counter then
			self._revives_counter:set_visible(not managers.groupai:state():whisper_mode() and visible and not self._is_in_custody)
		end
	end

	function HUDTeammate:set_detection_visibility(visible)
		if self._detection_counter then
			self._detection_counter:set_visible(managers.groupai:state():whisper_mode() and visible and not self._is_in_custody)
		end
	end

	function HUDTeammate:set_stamina_meter_visibility(visible)
		if self._stamina_bar then
			self._stamina_bar:set_visible(visible and not self._is_in_custody)
		end
	end

	function HUDTeammate:set_player_in_custody(incustody)
		self._is_in_custody = incustody
		self:set_revive_visibility(not incustody)
		self:set_stamina_meter_visibility(not incustody)
		if incustody then
			self:set_interact_visible(false)
			self:set_armor_timer_visibility(false)
			self:set_inspire_timer_visibility(false)
		end
	end

	function HUDTeammate:set_health(data)
		if data.revives then
			local revive_colors = { Color("FC9797"), Color("FCD997"), Color("C2FF97"), Color("97FC9A") }
			self._revives_counter:set_color(revive_colors[data.revives - 1] or Color.black:with_alpha(0.9))
			local has_messiah = false
			local messiah_charges = 0
			if self._main_player then
				messiah_charges = managers.player:upgrade_value("player", "pistol_revive_from_bleed_out", 0)
				has_messiah = messiah_charges > 0
				if has_messiah and managers.player:player_unit() and managers.player:player_unit():character_damage() then
					messiah_charges = managers.player:player_unit():character_damage()._messiah_charges
				end
			end
			if has_messiah then
				self._revives_counter:set_text(tostring(data.revives - 1) .. "/" .. tostring(messiah_charges))
			else
				self._revives_counter:set_text(tostring(data.revives - 1))
			end
			self:set_player_in_custody(data.revives - 1 < 0)
		end
		return set_health_original(self, data)
	end

	function HUDTeammate:set_hud_mode(mode)
		self:set_revive_visibility(not (mode == "stealth"))
		self:set_detection_visibility(mode == "stealth")
	end

	function HUDTeammate:set_detection_risk(risk)
		self._detection_counter:set_text(string.format("%.0f", risk * 100))
		self._detection_counter:set_color(Color(1, 0.99, 0.08, 0) * (risk / 0.75) + Color(1, 0, 0.71, 1) * (1 - risk / 0.75))
	end

	function HUDTeammate:increment_kill_count(is_special, headshot)
		self._kill_count = self._kill_count + 1
		self._kill_count_special = self._kill_count_special + (is_special and 1 or 0)
		self._headshot_kills = self._headshot_kills + (headshot and 1 or 0)
		self:_update_kill_count_text()
	end

	function HUDTeammate:_update_kill_count_text()
		local kill_string = tostring(self._kill_count)
		if JackHUD._data.show_special_kills then
			kill_string = kill_string .. "/" .. tostring(self._kill_count_special)
		end
		if JackHUD._data.show_headshot_kills then
			kill_string = kill_string .. " (" .. tostring(self._headshot_kills) .. ")"
		end
		self._kills_text:set_text(kill_string)
		local _, _, w, _ = self._kills_text:text_rect()
		self._kill_icon:set_right(self._kills_panel:w() - w - self._kill_icon:w() * 0.15)
		self:refresh_kill_count_visibility()
		if not self._color_pos then self._color_pos = 1 end
		self:_truncate_name()
	end

	function HUDTeammate:reset_kill_count()
		self._kill_count = 0
		self._kill_count_special = 0
		self._headshot_kills = 0
		self:_update_kill_count_text()
	end

	function HUDTeammate:set_name(teammate_name, ...)
		if teammate_name ~= self._name then
			self._name = teammate_name
			self:reset_kill_count()
		end
		self._color_pos = 1
		local peer = managers.network:session():peer(self._peer_id)
		local truncated_name = teammate_name:gsub('^%b[]',''):gsub('^%b==',''):gsub('^%s*(.-)%s*$','%1')
		if truncated_name:len() > 0 and teammate_name ~= truncated_name and JackHUD._data.truncate_name_tags then
			teammate_name = utf8.char(1031) .. truncated_name
		end
		if peer and peer:level() and JackHUD._data.show_client_ranks then
			local ranktag = ""
			if peer:rank() > 0 and managers.experience:rank_string((peer:rank())) then
				ranktag = managers.experience:rank_string((peer:rank())) .. "-"
			end
			local leveltag = ranktag .. peer:level() .. " "
			teammate_name = leveltag .. teammate_name
			self._color_pos = self._color_pos + leveltag:len()
		end
		self._panel:child("name"):set_text(teammate_name)
		set_name_original(self, self._panel:child("name"):text(), ...)
		self:_truncate_name()
	end

	function HUDTeammate:_truncate_name()
		local teammate_name
		local name_panel = self._panel:child("name")
		local _,_,w,_ = name_panel:text_rect()
		if JackHUD._data.enable_kill_counter then
			while (name_panel:x() + w) > (self._kills_panel:x() + self._kill_icon:x() - 2) do
				_,_,w,_ = name_panel:text_rect()
				teammate_name = name_panel:text()
				name_panel:set_text(teammate_name:sub(1, teammate_name:len() - 1))
			end
		end
		if JackHUD._data.colorize_names and not self._ai then
			self._panel:child("name"):set_range_color(self._color_pos, name_panel:text():len(), self._panel:child("callsign"):color():with_alpha(1))
		end
		self._panel:child("name_bg"):set_w(w + 4)
	end

	function HUDTeammate:refresh_kill_count_visibility()
		self._kills_panel:set_visible((not self._ai or JackHUD._data.show_ai_kills) and JackHUD._data.enable_kill_counter)
	end

	function HUDTeammate:set_state(...)
		set_state_original(self, ...)
		self:refresh_kill_count_visibility()
		if self._ai then
			self._kills_panel:set_bottom(self._panel:child("player"):bottom())
		else
			local name_label = self._panel:child("name")
			self._kills_panel:set_bottom(name_label:bottom())
		end
	end

end
