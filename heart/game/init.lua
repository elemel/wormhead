local Entity = require("heart.game.Entity")
local Game = require("heart.game.Game")

local game = {}

game.newGame = Game.new
game.newEntity = Entity.new

return game
