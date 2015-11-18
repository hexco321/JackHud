if not JackHUD then
	return
end

HUDTeammate.SHOW_SPECIAL_KILLS = JackHUD._data.show_special_kills
HUDTeammate.SHOW_HEADSHOT_KILLS = JackHUD._data.show_headshot_kills
HUDTeammate.SHOW_AI_KILLS = JackHUD._data.show_ai_kills

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
		if not HUDManager.CUSTOM_TEAMMATE_PANEL and JackHUD._data.enable_kill_counter then
			self:_init_killcount()
		end
	end

	function HUDTeammate:set_voice_com(status)
		if JackHud.settings.show_voip_bubble then
			local texture = status and "guis/textures/pd2/jukebox_playing" or "guis/textures/pd2/hud_tabs"
			local texture_rect = status and { 0, 0, 16, 16 } or { 84, 34, 19, 19 }
			local callsign = self._panel:child("callsign")
			callsign:set_image(texture, unpack(texture_rect))
		end
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

	if JackHUD._data.enable_kill_counter then
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
		end

		function HUDTeammate:increment_kill_count(is_special, headshot)
			self._kill_count = self._kill_count + 1
			self._kill_count_special = self._kill_count_special + (is_special and 1 or 0)
			self._headshot_kills = self._headshot_kills + (headshot and 1 or 0)
			self:_update_kill_count_text()
		end

		function HUDTeammate:_update_kill_count_text()
			local kill_string = tostring(self._kill_count)
			if HUDTeammate.SHOW_SPECIAL_KILLS then
				kill_string = kill_string .. "/" .. tostring(self._kill_count_special)
			end
			if HUDTeammate.SHOW_HEADSHOT_KILLS then
				kill_string = kill_string .. " (" .. tostring(self._headshot_kills) .. ")"
			end
			self._kills_text:set_text(kill_string)
			local _, _, w, _ = self._kills_text:text_rect()
			self._kill_icon:set_right(self._kills_panel:w() - w - self._kill_icon:w() * 0.15)
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
	
		function HUDTeammate:set_state(...)
			set_state_original(self, ...)
		
			if not HUDTeammate.SHOW_AI_KILLS then
				self._kills_panel:set_visible(not self._ai and true or false)
			end
			
			if self._ai then
				self._kills_panel:set_bottom(self._panel:child("player"):bottom())
			else
				local name_label = self._panel:child("name")
				self._kills_panel:set_bottom((self._id == HUDManager.PLAYER_PANEL) and name_label:bottom() or name_label:top())
			end
		end
	end
end
