if not JackHUD then
	return
end
if JackHUD and JackHUD._data.enable_kill_counter then
	HUDTeammate.SHOW_SPECIAL_KILLS = JackHUD._data.show_special_kills
	HUDTeammate.SHOW_HEADSHOT_KILLS = JackHUD._data.show_headshot_kills
	HUDTeammate.SHOW_AI_KILLS = JackHUD._data.show_ai_kills

	if not HUDTeammate.increment_kill_count and not HUDManager.CUSTOM_TEAMMATE_PANEL then	--Custom HUD compatibility
		local init_original = HUDTeammate.init
		local set_name_original = HUDTeammate.set_name
		local set_state_original = HUDTeammate.set_state

		function HUDTeammate:init(...)
			init_original(self, ...)
			if not HUDManager.CUSTOM_TEAMMATE_PANEL then
				self:_init_killcount()
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
