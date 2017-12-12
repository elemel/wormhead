local Matrix = require("heart.math.Matrix")
local utils = require("heart.utils")

local TransformComponent = {}
TransformComponent.__index = TransformComponent
TransformComponent.objectType = "component"
TransformComponent.componentType = "transform"

function TransformComponent.new(entity, config)
    local component = setmetatable({}, TransformComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    local scaleX = config.scaleX or config.scale or 1
    local scaleY = config.scaleY or config.scale or 1
    local originX = config.originX or 0
    local originY = config.originY or 0
    local shearX = config.shearX or 0
    local shearY = config.shearY or 0
    component.localTransform = Matrix.new()
    component.worldTransform = Matrix.new()
    component.inverseWorldTransform = Matrix.new()
    component.mode = "local"
    component:setParent(component.entity:getAncestorComponent("transform", 1))
    component.localTransform:reset()
    component.localTransform:compose(x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY)
    component.dirty = true
    component.children = {}
    return component
end

function TransformComponent:destroy()
    self:setParent(nil)
    self.entity:removeComponent(self)
end

function TransformComponent:setParent(parent)
    if parent ~= self.parent then
        self:setDirty(false)

        if self.parent then
            self.parent.children[self] = nil
        end

        self.parent = parent

        if self.parent then
            self.parent.children[self] = true
        end

        self.localTransform:reset(self.worldTransform:get())

        if self.parent then
            self.parent:setDirty(false)
            self.localTransform:multiplyRight(self.parent.inverseWorldTransform:get())
        end
    end
end

function TransformComponent:setMode(mode)
    if mode ~= self.mode then
        self:setDirty(false)
        self.mode = mode
    end
end

function TransformComponent:setDirty(dirty)
    if dirty ~= self.dirty then
        if dirty then
            for child, _ in pairs(self.children) do
                child:setDirty(true)
            end
        else
            if self.mode == "local" then
                self.worldTransform:reset(self.localTransform:get())

                if self.parent then
                    self.parent:setDirty(false)
                    self.worldTransform:multiplyRight(self.parent.worldTransform:get())
                end
            else
                self.localTransform:reset(self.worldTransform:get())

                if self.parent then
                    self.parent:setDirty(false)
                    self.localTransform:multiplyRight(self.parent.inverseWorldTransform:get())
                end
            end

            self.inverseWorldTransform:reset(self.worldTransform:get())
            self.inverseWorldTransform:invert()
        end

        self.dirty = dirty
    end
end

return TransformComponent
