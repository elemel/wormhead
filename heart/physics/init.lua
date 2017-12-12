local BodyComponent = require("heart.physics.BodyComponent")
local CircleFixtureComponent = require("heart.physics.CircleFixtureComponent")
local PhysicsSystem = require("heart.physics.PhysicsSystem")
local RectangleFixtureComponent = require("heart.physics.RectangleFixtureComponent")
local WheelJointComponent = require("heart.physics.WheelJointComponent")

local physics = {}

physics.newBodyComponent = BodyComponent.new
physics.newCircleFixtureComponent = CircleFixtureComponent.new
physics.newPhysicsSystem = PhysicsSystem.new
physics.newRectangleFixtureComponent = RectangleFixtureComponent.new
physics.newWheelJointComponent = WheelJointComponent.new

return physics
