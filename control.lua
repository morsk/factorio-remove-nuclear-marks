-- Copyright 2023 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local tempSurfaceName = "remove_nuclear_marks"

local nuclearTiles = {
    'nuclear-ground',
}
if script.active_mods['True-Nukes'] then
    -- True Nukes
    table.insert(nuclearTiles, 'nuclear-deep')
    table.insert(nuclearTiles, 'nuclear-high')
    table.insert(nuclearTiles, 'nuclear-shallow')
    table.insert(nuclearTiles, 'nuclear-crater')
    table.insert(nuclearTiles, 'nuclear-crater-fill')
    table.insert(nuclearTiles, 'nuclear-crater-shallow-fill')
    table.insert(nuclearTiles, 'nuclear-deep-shallow-fill')
    table.insert(nuclearTiles, 'nuclear-deep-fill')
end

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
}
if script.active_mods['True-Nukes'] then
    -- True Nukes
    table.insert(nuclearEntities, 'radiation-cloud-visual-dummy')
    table.insert(nuclearEntities, 'radiation-cloud')
    table.insert(nuclearEntities, 'lingering-radiation-cloud-visual-dummy')
    table.insert(nuclearEntities, 'lingering-radiation-cloud')
    table.insert(nuclearEntities, 'thermobaric-wave-fire')
    table.insert(nuclearEntities, 'nuclear-fire')
    table.insert(nuclearEntities, 'dangerous-radiation-cloud')
    table.insert(nuclearEntities, 'medium-scorchmark-tintable')
    table.insert(nuclearEntities, 'nuclear-scorchmark')
    table.insert(nuclearEntities, 'medium-scorchmark-tintable')
    table.insert(nuclearEntities, 'small-scorchmark-tintable')
end

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
            return true
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

-- Do not call this without pcall + cleaning up any temporary surface it creates.
local function fixNuclearTilesInternal(surface, found)
    local nTiles = {}
    local tempSurface = game.create_surface(tempSurfaceName, surface.map_gen_settings)
    -- Mark chunks for generation.
    for _, tile in pairs(found) do
        tempSurface.request_to_generate_chunks(tile.position, 0)
    end
    -- Force chunk generation.
    tempSurface.force_generate_chunk_requests()
    -- Copy tiles from the temp surface.
    for _, tile in pairs(found) do
        table.insert(nTiles, {name = tempSurface.get_tile(tile.position).name, position = tile.position})
    end
    surface.set_tiles(nTiles)
end

-- Wrapper to call fixNuclearTilesInternal only with pcall + cleanup.
local function fixNuclearTiles(...)
    -- We use, then delete a surface with this name, so there had better not be one already.
    if game.get_surface(tempSurfaceName) then
        game.print("Can't create our temp surface '"..tempSurfaceName.."' as it already exists. This is probably a bug.", { skip = defines.print_skip.never })
        return
    end
    -- pcall because we have cleanup to do even if this breaks
    local ok, result = pcall(fixNuclearTilesInternal, ...)
    -- cleanup
    if game.get_surface(tempSurfaceName) then
        game.delete_surface(tempSurfaceName)
    end
    -- print any errors
    if not ok then
        game.print(result, { skip = defines.print_skip.never })
    end
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
    data.surface.destroy_decoratives{area = data.area, name = 'nuclear-ground-patch'}
    local found = data.surface.find_tiles_filtered{area = data.area, name = nuclearTiles}
    if #found > 0 then
        fixNuclearTiles(data.surface, found)
    end
    found = data.surface.find_entities_filtered{area = data.area, name = nuclearEntities}
    for _, ent in pairs(found) do
        ent.destroy()
    end
end

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, onSelection)
