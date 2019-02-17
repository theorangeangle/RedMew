local function hello_world()
game.print('Hello World')
end

script.on_event(defines.events.on_player_joined_game, hello_world)