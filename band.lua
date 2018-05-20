local Event = require 'utils.event'
local Gui = require 'utils.gui'
local Token = require 'utils.global_token'

local band_roles = require 'resources.band_roles'
local band_roles_token = Token.register_global(band_roles)

local player_tags = {}
local player_tags_token = Token.register_global(player_tags)

Event.on_load(
    function()
        band_roles = Token.get_global(band_roles_token)
        player_tags = Token.get_global(player_tags_token)
    end
)

local function change_player_tag(player, band_name)
    local tag_name = '[' .. band_name .. ']'

    local old_tag = player.tag
    if old_tag == tag_name then
        return false
    end

    if old_tag ~= '' then
        local players = player_tags[old_tag]
        if players then
            players[player.index] = nil
        end
    end

    if band_name == '' then
        player.tag = ''
        return true
    end

    local players = player_tags[tag_name]
    if not players then
        players = {}
        player_tags[tag_name] = players
    end

    players[player.index] = true

    player.tag = tag_name

    local verbs = band_roles[band_name].verbs
    local verb
    if verbs then
        verb = verbs[math.random(#verbs)]
    else
        verb = 'expanded'
    end

    game.print(tag_name .. ' squad has `' .. verb .. '` with ' .. player.name)

    return true
end

local main_button_name = Gui.uid_name()
local main_frame_name = Gui.uid_name()
local band_button_name = Gui.uid_name()
local clear_button_name = Gui.uid_name()

local function player_joined(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end

    if player.gui.top[main_button_name] ~= nil then
        return
    end

    player.gui.top.add {name = main_button_name, type = 'button', caption = 'tag'}
end

local function draw_main_frame(player)
    local left = player.gui.left
    local main_frame =
        left.add {type = 'frame', name = main_frame_name, caption = 'Choose your tag', direction = 'vertical'}

    main_frame.style.maximal_height = 500

    local scroll_pane = main_frame.add {type = 'scroll-pane', direction = 'vertical', vertical_scroll_policy = 'always'}

    scroll_pane.style.right_padding = 0

    for band_name, band_data in pairs(band_roles) do
        local tag_name = '[' .. band_name .. ']'
        local players = player_tags[tag_name]

        local size = players and table.size(players) or 0
        if size == 0 then
            size = ''
        else
            size = ' (' .. size .. ')'
        end

        local row = scroll_pane.add {type = 'flow', direction = 'horizontal'}

        local button = row.add {type = 'sprite-button', name = band_button_name, sprite = band_data.path}

        Gui.set_data(button, band_name)

        local role_label = row.add {type = 'label', caption = band_name .. size}
        role_label.style.top_padding = 8
        role_label.style.minimal_width = 120

        local list = row.add {type = 'flow', direction = 'horizontal'}

        if players then
            for k, _ in pairs(players) do
                local p = game.players[k]
                if p and p.valid and p.connected then
                    local color = {r = 0.4 + 0.6 * p.color.r, g = 0.4 + 0.6 * p.color.g, b = 0.4 + 0.6 * p.color.b}

                    local label = list.add {type = 'label', caption = game.players[k].name}
                    label.style.top_padding = 8
                    label.style.font_color = color
                end
            end
        end

        list.style.minimal_width = 100
    end

    local flow = main_frame.add {type = 'flow'}
    flow.add {type = 'button', name = main_button_name, caption = 'close'}
    flow.add {type = 'button', name = clear_button_name, caption = 'clear tag'}
end

local function redraw_main_frame()
    for _, p in ipairs(game.connected_players) do
        local main_frame = p.gui.left[main_frame_name]
        if main_frame then
            Gui.remove_data_recursivly(main_frame)
            main_frame.destroy()

            draw_main_frame(p)
        end
    end
end

local function toggle(event)
    local left = event.player.gui.left
    local main_frame = left[main_frame_name]

    if main_frame then
        Gui.remove_data_recursivly(main_frame)
        main_frame.destroy()
    else
        draw_main_frame(event.player)
    end
end

Gui.on_click(main_button_name, toggle)

Gui.on_click(
    band_button_name,
    function(event)
        local tag = Gui.get_data(event.element)

        if change_player_tag(event.player, tag) then
            redraw_main_frame()
        end
    end
)

Gui.on_click(
    clear_button_name,
    function(event)
        if change_player_tag(event.player, '') then
            redraw_main_frame()
        end
    end
)

Event.add(defines.events.on_player_joined_game, player_joined)

--[[ local function tag_command(cmd)
    change_player_tag(game.players[cmd.player_index], 'Oil')
    redraw_main_frame()
end

commands.add_command('tag', '<player> <tag> Sets a players tag. (Admins only)', tag_command) ]]
