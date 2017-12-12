local CameraComponent = require("heart.graphics.CameraComponent")
local GraphicsSystem = require("heart.graphics.GraphicsSystem")
local MeshComponent = require("heart.graphics.MeshComponent")
local ParticleSystemComponent = require("heart.graphics.ParticleSystemComponent")

local graphics = {}

graphics.newCameraComponent = CameraComponent.new
graphics.newGraphicsSystem = GraphicsSystem.new
graphics.newMeshComponent = MeshComponent.new
graphics.newParticleSystemComponent = ParticleSystemComponent.new

return graphics
