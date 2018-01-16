local physics_engine = require "physics_engine"

function love.load()
  --function pe.add_rigidbody(type, uuid, x,y,z, rx,ry,rz, sx,sy,sz, mode)
  --These uuid's aren't correct, but can still be used for debugging the engine.
  physics_engine.add_rigidbody("cube", "cube1", 0,3,0, 0,45,0, 1,1,1, "static") --type, uuid, position, rotation, scale, mode
  physics_engine.add_rigidbody("sphere", "sphere1", 0,3,1, 0,0,0, 1,0,0, "dynamic") --type, uuid, position, rotation, scale, mode
end

function love.draw()
  physics_engine.debug_draw(0,0,-5, 0,0,0)
end
