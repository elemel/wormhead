local heart = require("heart")
local Game = require("Game")

function love.load()
    love.window.setTitle("Wormhead")

    love.window.setMode(800, 600, {
        fullscreentype = "desktop",
        highdpi = true,
        resizable = true,
    })

    love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.setMeter(1)

    -- game = Game.new()
    loadHeart()
end

function loadHeart()
    game = heart.game.newGame({
        updatePhases = {"scripting", "physics", "graphics"},
        drawPhases = {"graphics"},
    })

    local graphicsSystem = heart.graphics.newGraphicsSystem(game, {})
    local physicsSystem = heart.physics.newPhysicsSystem(game, {})
    local scriptingSystem = heart.scripting.newScriptingSystem(game, {})
    scriptingSystem.environment.heart = heart
    scriptingSystem.environment.love = love

    game.componentCreators.body = assert(heart.physics.newBodyComponent)
    game.componentCreators.camera = assert(heart.graphics.newCameraComponent)
    game.componentCreators.circleFixture = assert(heart.physics.newCircleFixtureComponent)
    game.componentCreators.mesh = assert(heart.graphics.newMeshComponent)
    game.componentCreators.particleSystem = assert(heart.graphics.newParticleSystemComponent)
    game.componentCreators.rectangleFixture = assert(heart.physics.newRectangleFixtureComponent)
    game.componentCreators.script = assert(heart.scripting.newScriptComponent)
    game.componentCreators.transform = assert(heart.animation.newTransformComponent)
    game.componentCreators.wheelJoint = assert(heart.physics.newWheelJointComponent)

    heart.game.newEntity(game, nil, {
        components = {
            {
                componentType = "transform",
                scale = 1 / 16,
            },

            {
                componentType = "camera",
            },
        },
    })

    heart.game.newEntity(game, nil, {
        components = {
            {
                componentType = "transform",
            },

            {
                componentType = "script",
                name = "levelScript",
                scriptFilename = "resources/scripts/Level.lua",
            },
        },

        children = {
            {
                name = "asteroids",
            },
        },
    })

    local graphicsWidth, graphicsHeight = love.graphics.getDimensions()
    graphicsSystem:resize(graphicsWidth, graphicsHeight)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end
