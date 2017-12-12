local utils = require("heart.utils")

local GraphicsSystem = {}
GraphicsSystem.__index = GraphicsSystem
GraphicsSystem.objectType = "system"
GraphicsSystem.systemType = "graphics"

function GraphicsSystem.new(game, config)
    local system = setmetatable({}, GraphicsSystem)
    system.game = assert(game)
    system.game.systems.graphics = system
    system.cameraComponents = {}
    system.meshComponents = {}
    system.overlayHandlers = {}
    system.particleSystemComponents = {}
    system.game.updateHandlers.graphics[system] = system.updateGraphics
    system.game.drawHandlers.graphics[system] = system.drawGraphics
    system.game.callbackHandlers.resize[system] = system.resize
    return system
end

function GraphicsSystem:destroy()
    self.game.callbackHandlers.resize[self] = nil
    self.game.drawHandlers.graphics[self] = nil
    self.game.updateHandlers.graphics[self] = nil
    self.game.systems.graphics = nil
end

function GraphicsSystem:updateGraphics(dt)
    for component, _ in pairs(self.particleSystemComponents) do
        local oldX = component.x
        local oldY = component.y
        component.transformComponent:setDirty(false)
        component.x, component.y = component.transformComponent.worldTransform:transformPoint(0, 0)
        component.particles:setPosition(component.x, component.y)
        local linearVelocityX = (component.x - oldX) / dt
        local linearVelocityY = (component.y - oldY) / dt
        local speed = utils.length2(linearVelocityX, linearVelocityY)
        component.particles:setSpeed(speed)
        local direction = math.atan2(linearVelocityY, linearVelocityX)
        component.particles:setDirection(direction)
        component.particles:update(dt)
    end
end

function GraphicsSystem:drawGraphics()
    for component, _ in pairs(self.cameraComponents) do
        love.graphics.reset()

        love.graphics.setScissor(
            component.viewportX, component.viewportY,
            component.viewportWidth, component.viewportHeight)

        love.graphics.translate(
            component.viewportX + 0.5 * component.viewportWidth,
            component.viewportY + 0.5 * component.viewportHeight)

        component.transformComponent:setDirty(false)

        local x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY =
            component.transformComponent.worldTransform:decompose()

        local scale = scaleX * math.min(component.viewportWidth, component.viewportHeight)

        love.graphics.scale(scale)
        love.graphics.setLineWidth(1 / scale)
        love.graphics.translate(-x, -y)

        for component, _ in pairs(self.meshComponents) do
            component.transformComponent:setDirty(false)

            love.graphics.setShader(self.game.shaders.default)

            self.game.shaders.default:send("inverseBindPoseTransforms", {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            })

            local transform = component.transformComponent.worldTransform

            self.game.shaders.default:send("boneTransforms", {
                transform.a, transform.d, 0, 0,
                transform.b, transform.e, 0, 0,
                0, 0, 1, 0,
                transform.c, transform.f, 0, 1,
            })

            local mesh = assert(self.game.meshes[component.meshName])
            love.graphics.draw(mesh)
            love.graphics.setShader(nil)
        end

        for component, _ in pairs(self.particleSystemComponents) do
            love.graphics.setBlendMode("add")
            love.graphics.draw(component.particles)
            love.graphics.setBlendMode("alpha")
        end

        for object, handler in pairs(self.overlayHandlers) do
            handler(object)
        end

        love.graphics.setScissor()
    end
end

function GraphicsSystem:resize(w, h)
    for component, _ in pairs(self.cameraComponents) do
        component.viewportX = 0
        component.viewportY = 0
        component.viewportWidth = w
        component.viewportHeight = h
    end
end

return GraphicsSystem