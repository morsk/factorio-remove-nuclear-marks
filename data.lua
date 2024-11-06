-- Copyright 2023 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

if not mods['Mower'] and not mods['Dectorio'] then
    data:extend{
        {
            type = 'custom-input',
            name = 'rmnmks-remove',
            key_sequence = 'CONTROL + ALT + X',
            action = 'spawn-item',
            item_to_spawn = 'rmnmks-remove-tool',
        },
        {
            type = 'selection-tool',
            name = 'rmnmks-remove-tool',
            icon = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
            icon_size = 32,
            flags = {'only-in-cursor', 'spawnable'},
            stack_size = 1,
            stackable = false,
            toggleable = false,
            show_in_library = false,
            subgroup = 'tool',
            select = {
                border_color = {0.7, 0.0, 0.7},
                cursor_box_type = 'not-allowed',
                mode = {'nothing'}
            },
            alt_select = {
                border_color = {0.7, 0.0, 0.7},
                cursor_box_type = 'not-allowed',
                mode = {'nothing'}
            },
        },
        {
            type = 'shortcut',
            name = 'rmnmks-remove-shortcut',
            associated_control_input = 'rmnmks-remove',
            action = 'spawn-item',
            item_to_spawn = 'rmnmks-remove-tool',
            icon = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
            icon_size = 32,
            small_icon = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
            small_icon_size = 32,
        }
    }
end
