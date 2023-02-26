-- Copyright 2023 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

if not mods['Mower'] and not mods['Dectorio'] then
    data:extend({
        {
            name = 'sil-rmnmks-clean-shrubbery',
            type = 'bool-setting',
            setting_type = 'runtime-global',
            order = 'a',
            default_value = false
        },
        {
            name = 'sil-rmnmks-clean-biter-goo',
            type = 'bool-setting',
            setting_type = 'runtime-global',
            order = 'b',
            default_value = false
        },
        {
            name = 'sil-rmnmks-clean-corpses',
            type = 'bool-setting',
            setting_type = 'runtime-global',
            order = 'c',
            default_value = false
        },
    })
end
