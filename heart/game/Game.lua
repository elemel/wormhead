local Game = {}
Game.__index = Game
Game.objectType = "game"

function Game.new(config)
    local game = setmetatable({}, Game)
    game.minDt = config.minDt or 0
    game.maxDt = config.maxDt or 1 / 30
    game.dt = 0
    game.systems = {}
    game.entities = {}
    game.images = {}
    game.meshes = {}
    game.skeletons = {}
    game.shaders = {}
    game.componentCreators = {}
    game.componentTypes = {}
    game.callbackHandlers = {}
    game.callbackHandlers.resize = {}

    if config.entityCategories then
        for i, category in ipairs(config.entityCategories) do
            game.entities[category] = {}
        end
    end

    game.updatePhases = config.updatePhases or {}
    game.updateHandlers = {}

    for i, phase in ipairs(game.updatePhases) do
        game.updateHandlers[phase] = {}
    end

    game.drawPhases = config.drawPhases or {}
    game.drawHandlers = {}

    for i, phase in ipairs(game.drawPhases) do
        game.drawHandlers[phase] = {}
    end

    return game
end

function Game:update(dt)
    self.dt = self.dt + dt

    if self.dt >= self.minDt then
        self.dt = math.min(self.dt, self.maxDt)

        for i, phase in ipairs(self.updatePhases) do
            for entity, handler in pairs(self.updateHandlers[phase]) do
                handler(entity, self.dt)
            end
        end

        self.dt = 0
    end
end

function Game:draw()
    for i, phase in ipairs(self.drawPhases) do
        for entity, handler in pairs(self.drawHandlers[phase]) do
            handler(entity)
        end
    end
end

function Game:callback(name, ...)
    for object, handler in pairs(self.callbackHandlers[name]) do
        handler(object, ...)
    end
end

return Game
