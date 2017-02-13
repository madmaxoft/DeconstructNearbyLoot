

--- Returns true if the technology necessary for auto-deconstruction is researched for the specified player
local function isTechnologyResearched(a_Player)
	-- Check params:
	assert(a_Player)
	assert(a_Player.force)

	return a_Player.force.technologies["auto-deconstruct-loot-tech"].researched
end





--- Returns the caption to use for the button based on whether the deconstruction is enabled or not
local function getButtonCaption(a_IsEnabled)
	return a_IsEnabled and "D+" or "D-"
end





--- Map of PlayerName -> true for all players who have the deconstruction enabled via their UI
local g_PlayerDeconstructionEnabled = {}

--- Returns true if the specified player has deconstruction enabled via their UI
local function hasDeconstructionEnabled(a_Player)
	if (g_PlayerDeconstructionEnabled[a_Player.name]) then
		return true
	else
		return false
	end
end





--- Sets up, updates or tears down the GUI for a single player, based on the availability of the tech
local function updateGuiForPlayer(a_Player)
	-- Skip offline players:
	if not(a_Player.connected) then
		return
	end

	-- If the technology is available, add the GUI button (if not already present):
	if (isTechnologyResearched(a_Player)) then
		local button = a_Player.gui.top["auto-deconstruct-loot-button"]
		if (button) then
			button.caption = getButtonCaption(hasDeconstructionEnabled(a_Player))
		else
			a_Player.gui.top.add({
				type = "button",
				name = "auto-deconstruct-loot-button",
				-- sprite = getButtonSpriteName(hasDeconstructionEnabled(a_Player)),
				caption = getButtonCaption(hasDeconstructionEnabled(a_Player)),
			})
		end
		return
	end

	-- The technology is not available, remove the GUI button, if it exists for some reason:
	local button = a_Player.gui.top["auto-deconstruct-loot-button"]
	if (button) then
		button.destroy()
	end
end





--- Toggles the DeconstructionEnabled flag for the specified player, and updates their UI
local function togglePlayerDeconstructionEnabled(a_Player)
	local name = a_Player.name
	if (g_PlayerDeconstructionEnabled[name]) then
		g_PlayerDeconstructionEnabled[name] = nil
	else
		g_PlayerDeconstructionEnabled[name] = true
	end
	updateGuiForPlayer(a_Player)
end





--- When a player is created, joins game or is respawned, update their UI:
for _, evt in ipairs({
	defines.events.on_player_created,
	defines.events.on_player_joined_game,
	defines.events.on_player_respawned
}) do
	script.on_event(evt,
		function(a_Event)
			game.players[a_Event.player_index].print("event: " .. tostring(a_Event.name))
			updateGuiForPlayer(game.players[a_Event.player_index])
		end
	)
end





--- When a research is completed by a force, update all its players' GUIs
script.on_event(defines.events.on_research_finished,
	function(a_Event)
		if (a_Event.research.name == "auto-deconstruct-loot-tech") then
			for _, player in ipairs(a_Event.research.force.players) do
				updateGuiForPlayer(player)
			end
		end
	end
)





--- When a force is created, update all its players' GUIs
script.on_event(defines.events.on_force_created,
	function(a_Event)
		for _, player in ipairs(a_Event.force.players) do
			updateGuiForPlayer(player)
		end
	end
)






--- When forces are merged, update all their players' GUIs
script.on_event(defines.events.on_forces_merging,
	function(a_Event)
		for _, player in ipairs(a_Event.source.players) do
			updateGuiForPlayer(player)
			-- TODO: Check that this actually works, it probably doesn't, since the players are still in the old force
		end
	end
)





--- When the GUI button is clicked, toggle the player's collection:
script.on_event(defines.events.on_gui_click,
	function(a_Event)
		-- Not interested in anything else than our button:
		if (a_Event.element.name ~= "auto-deconstruct-loot-button") then
			return
		end
		local player = game.players[a_Event.player_index]
		togglePlayerDeconstructionEnabled(player)
	end
)





--- Mark all loot near to each player for deconstruction, every few ticks:
script.on_event(defines.events.on_tick,
	function(a_Event)
		-- Only run ten times a second (once every 6 ticks):
		if (a_Event.tick % 6 ~= 0) then
			return
		end

		-- Deconstruct items around each player who has AutoConstruction researched:
		for _, player in pairs(game.players or {}) do
			if (
				player.connected and              -- The player is connected (for MP games, skip disconnected players)
				player.character and              -- The player's character is valid (so that we can ask about its logistic_cell)
				hasDeconstructionEnabled(player)  -- The player has the necessary technology researched
			) then
				local logisticCell = player.character.logistic_cell
				if (logisticCell) then
					local pos = player.position
					local conRadius = logisticCell.construction_radius
					local entities = game.surfaces["nauvis"].find_entities_filtered({area = {{pos.x - conRadius, pos.y - conRadius}, {pos.x + conRadius, pos.y + conRadius}}, type = "item-entity"})
					for _, entity in ipairs(entities) do
						entity.order_deconstruction(player.force)
					end  -- for entity
				end
			end
		end  -- for player
	end
)




--- Add a remote call interface to force a GUI update (for games saved before the GUI was implemented):
remote.add_interface("DeconstructNearbyLoot", { updateGui = updateGuiForPlayer })
