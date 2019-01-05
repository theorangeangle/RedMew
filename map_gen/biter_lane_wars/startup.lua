local filepath = global.blw_scenario.filepath
local Task = require 'utils.task'
local Token = require 'utils.token'
local RS = require 'map_gen.shared.redmew_surface'
local Event = require 'utils.event'
local map_gen_settings_presets = require 'resources.map_gen_settings'
local Generate = require("map_gen.shared.generate")

local Maps = require(filepath .. 'resources.maps')
local surface_name = RS.get_surface_name()

RS.set_map_gen_settings({map_gen_settings_presets.void})

local regen_decoratives = false
local tiles_per_tick = 64

local on_timer_complete =
    Token.register(
    function()
        Generate.unregister_non_threaded()
        local surface = RS.get_surface()
        for chunk in surface.get_chunks() do
            surface.delete_chunk(chunk)
        end

        --local shape = function(x, y, world)
        --    return not (x > 20 or x < -20 or y > 20)
        --end

        local shape = require(filepath .. 'resources.maps').single.shape

        if shape then
            local surfaces = {
                [surface_name] = shape
            }
            Generate.register_threaded({surfaces = surfaces, regen_decoratives = regen_decoratives, tiles_per_tick = tiles_per_tick})
        end
    end
)

-- create lobby
-- start timer

-- after timer build the teams

-- once we have teams, build the map

-- once the map is built (need to figure out when that is)
-- teleport the teams

-- start the timer

-- wave 1

local function on_init()
    Task.set_timeout(5, on_timer_complete)



end

-- Setup lobby

local shape = Maps.lobby.shape

if shape then
    local surfaces = {
        [RS.get_surface_name()] = shape,
    }
    Generate.register_threaded({surfaces = surfaces, regen_decoratives = regen_decoratives})
end

Event.on_init(on_init)
