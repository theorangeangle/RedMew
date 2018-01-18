map_gen_decoratives = false -- Generate our own decoratives
map_gen_rows_per_tick = 4 -- Inclusive integer between 1 and 32. Used for map_gen_threaded, higher numbers will generate map quicker but cause more lag.

-- Recommend to use map_gen, but map_gen_not_threaded may be useful for testing / debugging.
--require "locale.gen_combined.grilledham_map_gen.map_gen_not_threaded"
require "locale.gen_combined.grilledham_map_gen.map_gen"

local pic = require "locale.gen_combined.grilledham_map_gen.data.template"
local pic = decompress(pic)
local map = picture_builder(pic)

-- this changes the size of the map
--map = scale(map, 2, 2)

-- this moves the map, effectively changing the spawn point.
--map = translate(map, 0, -200)

-- this sets the tile outside the bounds of the map to deepwater, remove this and it will be void.
--map = change_tile(map, false, "deepwater")

return map