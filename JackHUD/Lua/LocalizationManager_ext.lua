
local text_original = LocalizationManager.text

-- This hack allows us to reroute every call for texts.
function LocalizationManager:text(string_id, ...)
	if string_id == "hud_assault_enhanced" then
		-- enhanced assault banner
		return self:hud_assault_enhanced()
	else
		-- fallback to default
		return text_original(self, string_id, ...)
	end
end

function LocalizationManager:hud_assault_enhanced()
	if managers.groupai:state():get_hunt_mode() or not JackHUD:GetOption("enable_enhanced_assault_banner") then
		return self:text("hud_assault_assault")
	else
		local finaltext = "Assault Phase: " .. managers.groupai:state()._task_data.assault.phase
		local spawns = managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
		if spawns >= 0 and JackHUD:GetOption("enhanced_assault_spawns") then
			finaltext = finaltext .. " /// Spawns Left: " .. string.format("%d", spawns - managers.groupai:state()._task_data.assault.force_spawned)
		end
		local atime = managers.groupai:state()._task_data.assault.phase_end_t + math.lerp(managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul) + tweak_data.group_ai.besiege.assault.fade_duration * 2
		if JackHUD:GetOption("enhanced_assault_time") then
			if atime < 0 then
				finaltext = finaltext .. " /// OVERDUE"
			elseif atime > 0 then
				finaltext = finaltext .. " /// Time Left: " .. string.format("%.2f", atime + 350 - managers.groupai:state()._t)
			end
		end
		return finaltext
	end
end
