local physics_engine = require "physics_engine"

local total_time = 0
local timestep = 1/60

local speed = 0.001

function love.load()
  physics_engine.load()
  --function pe.add_rigidbody(type, uuid, x,y,z, rx,ry,rz, sx,sy,sz, mode)
  --These uuid's aren't correct, but can still be used for debugging the engine.
  physics_engine.add_rigidbody("cube", "cube1", 0,3,0, 0,45,0, 1,1,1, "dynamic") --type, uuid, position, rotation, scale, mode
  physics_engine.add_rigidbody("cube", "cube2", 0,0,1, 0,0,0, 1,0,0, "static") --type, uuid, position, rotation, scale, mode
end

function love.update(dt)
  total_time = total_time + dt * speed
  while total_time > timestep * speed do
    physics_engine.update(timestep * speed)
    total_time = total_time - timestep * speed
  end
end

function love.draw()
  physics_engine.debug_draw(0,0,-5, 0,0,0)
  love.graphics.print(math.floor(love.timer.getFPS()))
end
