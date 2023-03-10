-- Copyright 2023 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local nuclearTiles = {
    'nuclear-ground',
    -- True Nukes
    'nuclear-deep',
    'nuclear-high',
    'nuclear-shallow',
    'nuclear-crater',
    'nuclear-crater-fill',
    'nuclear-crater-shallow-fill',
    'nuclear-deep-shallow-fill',
    'nuclear-deep-fill'
}

local function isNuclearTile(tileName)
    for _, v in pairs(nuclearTiles) do
        if v == tileName then
            return true
        end
    end
    return false
end

local nuclearEntities = {
    'nuclear-smouldering-smoke-source',
    -- True Nukes
    'radiation-cloud-visual-dummy',
    'radiation-cloud',
    'lingering-radiation-cloud-visual-dummy',
    'lingering-radiation-cloud',
    'thermobaric-wave-fire',
    'nuclear-fire',
    'dangerous-radiation-cloud',
    'medium-scorchmark-tintable',
    'nuclear-scorchmark',
    'medium-scorchmark-tintable',
    'small-scorchmark-tintable'
}

local biterDecoratives = {
    'enemy-decal',
    'enemy-decal-transparent',
    'shroom-decal',
    'worms-decal',
    'lichen-decal'
}

local function isNuclearEntity(entityName)
    for _, v in pairs(nuclearEntities) do
        if v == entityName then
            return True
        end
    end
    return false
end

local function getDistance(pos, tgt)
    local x = (tgt.x - pos.x) ^ 2
    local y = (tgt.y - pos.y) ^ 2
    local d = (x + y) ^ 0.5
    return d
end

local function getClosestTileNameAndDistance(tiles, pos)
    local result = 'dry-dirt'
    local lowest = 2 ^ 32 - 1
    for _, tile in pairs(tiles) do
        if tile.name ~= 'water' and tile.name ~= 'deepwater' and not isNuclearTile(tile.name) then
            local dist = getDistance(tile.position, pos)
            if dist < lowest then
                lowest = dist
                result = tile.name
            end
            if lowest <= 1 then
                return {result, lowest}
            end
        end
    end
    return {result, lowest}
end

local function getClosestTileName(surface, replacedTiles, rad, pos)
    local result = 'dry-dirt'
    local lowest = rad

    local tmp = getClosestTileNameAndDistance(replacedTiles, pos)
    -- FUCKED UP STUPID Lua COUNTING FROM 1 UNLIKE THE REST OF THE ENTIRE FUCKING WORLD !!!
    result = tmp[1]
    lowest = tmp[2]

    if lowest <= 1 then
        return result
    end

    local tiles = surface.find_tiles_filtered{position=pos, radius=rad}
    tmp = getClosestTileNameAndDistance(tiles, pos)
    -- FUCKED UP STUPID Lua COUNTING FROM 1 UNLIKE THE REST OF THE ENTIRE FUCKING WORLD !!!
    if (tmp[2] < lowest) then
        result = tmp[1]
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
    if data.item == 'rmnmks-remove-tool' then
        if settings.global['sil-rmnmks-clean-biter-goo'].value then
            data.surface.destroy_decoratives{area = data.area, name = biterDecoratives}
        end
        if settings.global['sil-rmnmks-clean-corpses'].value then
            local found = data.surface.find_entities_filtered{area = data.area, type = 'corpse'}
            for _, entity in pairs(found) do
                entity.destroy()
            end
        end
        if settings.global['sil-rmnmks-clean-shrubbery'].value then
            data.surface.destroy_decoratives{area = data.area, name = biterDecoratives, invert = true}
        end
    end
    local plr = game.get_player(data.player_index)
    if data.item == 'rmnmks-remove-tool' and not plr.force.technologies['atomic-bomb'].researched then
        return
    end
    data.surface.destroy_decoratives{area = data.area, name = 'nuclear-ground-patch'}
    local found = data.surface.find_tiles_filtered{area = data.area, name = nuclearTiles}
    if #found > 0 then
        local nTiles = {}
        local tiles = data.surface.find_tiles_filtered{area = data.area}
        for _, tile in pairs(found) do
            table.insert(nTiles, {name = getClosestTileName(data.surface, nTiles, 30, tile.position), position = tile.position})
        end
        data.surface.set_tiles(nTiles)
    end
    found = data.surface.find_entities_filtered{area = data.area, name = nuclearEntities}
    for _, ent in pairs(found) do
        ent.destroy()
    end
end

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, onSelection)
