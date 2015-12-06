if not JackHUD then
	return
end

if not HUDTeammate.increment_kill_count and not HUDManager.CUSTOM_TEAMMATE_PANEL then
	local init_original = HUDTeammate.init
	function HUDTeammate:init(i, ...)
		init_original(self, i, ...)

		if i == HUDManager.PLAYER_PANEL then
			local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
	
			self._stamina_bar = radial_health_panel:bitmap({
				name = "radial_stamina",
				texture = "guis/textures/pd2/hud_radial_rim",
				texture_rect = { 64, 0, -64, 64 },
				render_template = "VertexColorTexturedRadial",
				blend_mode = "add",
				alpha = 1,
				w = radial_health_panel:w() * 0.4,
				h = radial_health_panel:h() * 0.4,
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
		if not HUDManager.CUSTOM_TEAMMATE_PANEL then
			self:_init_killcount()
		end
		self:_init_revivecount()
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
			font_size = 20,
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
			font_size = 20,
			font = tweak_data.hud_players.ammo_font
		})
		self._revives_count = 0
		if self._main_player then
			self:set_detection_risk(managers.blackmarket:get_suspicion_offset_of_outfit_string(managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string()), tweak_data.player.SUSPICION_OFFSET_LERP or 0.75))
		end
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

	function HUDTeammate:set_revive_visibility(visible)
		if self._revives_counter then
			self._revives_counter:set_visible(not managers.groupai:state():whisper_mode() and visible)
		end
	end

	local set_health_original = HUDTeammate.set_health
	function HUDTeammate:set_health(data)
		if data.revives then
			local revive_colors = { Color("FC9797"), Color("FCD997"), Color("C2FF97"), Color("97FC9A") }
			self._revives_counter:set_color(revive_colors[data.revives - 1] or Color.purple:with_alpha(0.9))

			--[[if self._main_player and PlayerDamage then
				if managers.player:player_unit() and managers.player:player_unit():character_damage() then
					local myval = managers.player:upgrade_value("player", "pistol_revive_from_bleed_out", 0)
				else
					local myval = PlayerDamage._messiah_charges
				end
			end
			if myval and myval >= 0 then
				self._revives_counter:set_text(tostring(data.revives - 1 .. "/" .. myval))
			else]]
				self._revives_counter:set_text(tostring(data.revives - 1))
			--end

			self._revives_counter:set_visible(not managers.groupai:state():whisper_mode() and data.revives - 1 >= 0)
		end
		return set_health_original(self, data)
	end

	function HUDTeammate:set_hud_mode(mode)
		self._revives_counter:set_visible(not (mode == "stealth"))
		self._detection_counter:set_visible(mode == "stealth")
	end

	function HUDTeammate:set_detection_risk(risk)
		self._detection_counter:set_text(string.format("%.0f", risk * 100))
		self._detection_counter:set_color(Color(1, 0.99, 0.08, 0) * (risk / 0.75) + Color(1, 0, 0.71, 1) * (1 - risk / 0.75))
	end

	local set_name_original = HUDTeammate.set_name
	local set_state_original = HUDTeammate.set_state
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
		self._kills_panel:set_rightbottom(player_panel:right(), (self._id == HUDManager.PLAYER_PANEL) and name_label:bottom() or name_label:top())
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
		return set_name_original(self, teammate_name, ...)
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
			self._kills_panel:set_bottom((self._id == HUDManager.PLAYER_PANEL) and name_label:bottom() or name_label:top())
		end
	end
end
