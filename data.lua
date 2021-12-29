if not mods['Mower'] and not mods['Dectorio'] then
    data:extend{
        {
            type = 'custom-input',
            name = 'rmnmks-remove',
            key_sequence = 'CONTROL + ALT + X',
            action = 'spawn-item',
            item_to_spawn = 'rmnmks-remove-tool',
            technology_to_unlock = 'atomic-bomb',
        },
        {
            type = 'selection-tool',
            name = 'rmnmks-remove-tool',
            icon = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
            icon_size = 32,
            flags = {'only-in-cursor', 'hidden', 'spawnable'},
            stack_size = 1,
            stackable = false,
            toggleable = false,
            show_in_library = false,
            subgroup = 'tool',
            selection_mode = 'nothing',
            selection_color = { r = 0.7, b = 0.7 },
            selection_cursor_box_type = 'not-allowed',
            alt_selection_mode = 'nothing',
            alt_selection_color = { r = 0.7, b = 0.7 },
            alt_selection_cursor_box_type = 'not-allowed'
        },
        {
            type = 'shortcut',
            name = 'rmnmks-remove-shortcut',
            associated_control_input = 'rmnmks-remove',
            action = 'spawn-item',
            item_to_spawn = 'rmnmks-remove-tool',
            technology_to_unlock = 'atomic-bomb',
            icon =
            {
                filename = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
                priority = 'extra-high-no-scale',
                size = 32,
                scale = 0.5,
                mipmap_count = 2,
                flags = {'gui-icon'}
            },
            small_icon =
            {
                filename = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
                priority = 'extra-high-no-scale',
                size = 32,
                scale = 0.5,
                mipmap_count = 2,
                flags = {'gui-icon'}
            },
            disabled_small_icon =
            {
                filename = '__remove-nuclear-marks__/graphics/icons/icon-crossed.png',
                priority = 'extra-high-no-scale',
                size = 32,
                scale = 0.5,
                mipmap_count = 2,
                flags = {'gui-icon'}
            }
        }
    }
end
