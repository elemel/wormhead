local BodyComponent = require("heart.physics.BodyComponent")
local CircleFixtureComponent = require("heart.physics.CircleFixtureComponent")
local PhysicsSystem = require("heart.physics.PhysicsSystem")
local PolygonFixtureComponent = require("heart.physics.PolygonFixtureComponent")
local RectangleFixtureComponent = require("heart.physics.RectangleFixtureComponent")
local WheelJointComponent = require("heart.physics.WheelJointComponent")

local physics = {}

physics.newBodyComponent = assert(BodyComponent.new)
physics.newCircleFixtureComponent = assert(CircleFixtureComponent.new)
physics.newPhysicsSystem = assert(PhysicsSystem.new)
physics.newPolygonFixtureComponent = assert(PolygonFixtureComponent.new)
physics.newRectangleFixtureComponent = assert(RectangleFixtureComponent.new)
physics.newWheelJointComponent = assert(WheelJointComponent.new)

return physics
