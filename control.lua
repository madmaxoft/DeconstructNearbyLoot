--- Mark all loot near to each player for deconstruction, every few ticks:
script.on_event(defines.events.on_tick,
	function(event)
		-- Only run ten times a second (once every 6 ticks):
		if (event.tick % 6 ~= 0) then
			return
		end

		-- Deconstruct items around each player who has AutoConstruction researched:
		for _, player in pairs(game.players or {}) do
			if (
				player.connected and                                            -- The player is connected (for MP games, skip disconnected players)
				player.character and                                            -- The player's character is valid (so that we can ask about its logistic_cell)
				player.force.technologies["automated-construction"].researched  -- The player has AutoConstruction researched
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
