-- Copyright 2021 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local function getDistance(pos, tgt)
    local x = (tgt.x - pos.x) ^ 2
    local y = (tgt.y - pos.y) ^ 2
    local d = (x + y) ^ 0.5
    return d
end

local function getClosestTileName(tiles, pos)
    local result = 'dry-dirt'
    local lowest = 30
    for _, tile in pairs(tiles) do
        if tile.name ~= 'water' and tile.name ~= 'deepwater' then
            local dist = getDistance(tile.position, pos)
            if tile.name ~= 'nuclear-ground' and dist < lowest then
                lowest = dist
                result = tile.name
            end
        end
    end
    return result
end

local function onSelection(data)
    local run = false
    if script.active_mods['Mower'] ~= nil and data.item == 'mower-mower' then
        run = true
    elseif script.active_mods['Dectorio'] ~= nil and data.item == 'dect-lawnmower' then
        run = true
    else
        run = data.item == 'rmnmks-remove-tool'
    end
    if not run then
        return
    end
    local plr = game.get_player(data.player_index)
    if data.item == 'rmnmks-remove-tool' and not plr.force.technologies['atomic-bomb'].researched then
        return
    end
    data.surface.destroy_decoratives{area = data.area, name = 'nuclear-ground-patch'}
    local found = data.surface.find_tiles_filtered{area = data.area, name = 'nuclear-ground'}
    if #found > 0 then
        local tiles = data.surface.find_tiles_filtered{area = data.area}
        local nTiles = {}
        for _, tile in pairs(found) do
            table.insert(nTiles, {name = getClosestTileName(tiles, tile.position), position = tile.position})
        end
        data.surface.set_tiles(nTiles)
    end
    found = data.surface.find_entities_filtered{area = data.area, name = {'nuclear-smouldering-smoke-source'}}
    for _, ent in pairs(found) do
        ent.destroy()
    end
end

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, onSelection)
