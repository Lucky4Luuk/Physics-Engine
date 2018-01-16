local pe = {} --library table
local maf = require "maf"

local objects = {}

function pe.getRotation(rx,ry,rz)
  return maf.rotation():angleAxis(rx,1,0,0):angleAxis(rz,0,0,1):angleAxis(ry,0,1,0)
end

function pe.add_rigidbody(type, uuid, x,y,z, rx,ry,rz, sx,sy,sz, mode)
  local bbox = {min=maf.vec3(-1,-1,-1),max=maf.vec3(1,1,1)}
  local object = {type=type, uuid=uuid, vertices={}, faces={}, pos=maf.vec3(x,y,z), rot=pe.getRotation(rx,ry,rz), scale=maf.vec3(sx,sy,sz), mode=mode}
  if type == "sphere" then
    bbox.min = maf.vec3(-rx-0.25,-rx-0.25,-rx-0.25)
    bbox.max = maf.vec3(rx+0.25,rx+0.25,rx+0.25)
  elseif type == "cube" then
    object.vertices = {
      maf.vec3(-1,-1,-1),
      maf.vec3( 1,-1,-1),
      maf.vec3( 1, 1,-1),
      maf.vec3(-1, 1,-1),

      maf.vec3(-1,-1, 1),
      maf.vec3( 1,-1, 1),
      maf.vec3( 1, 1, 1),
      maf.vec3(-1, 1, 1)
    }
    object.faces = {
      {1,2,3},--Front
      {2,3,4},--Front

      {5,6,7},--Back
      {6,7,8},--Back

      {2,6,3},--Right
      {6,3,7},--Right

      {1,5,8},--Left
      {8,4,1},--Left

      {4,3,8},--Top
      {4,8,7},--Top

      {1,2,6},--Bottom
      {6,5,1} --Bottom
    }
    for i=1, #object.vertices do
      object.vertices[i] = object.vertices[i]:rotate(object.rot)
    end
    bbox.min = object.vertices[1]
    bbox.max = object.vertices[1]
    for i=2, #object.vertices do
      local vx, vy, vz = object.vertices[i]:unpack()
      local minx, miny, minz = bbox.min:unpack()
      local maxx, maxy, maxz = bbox.max:unpack()
      bbox.min = maf.vec3(math.min(minx, vx), math.min(miny, vy), math.min(minz, vz))
      bbox.max = maf.vec3(math.max(maxx, vx), math.max(maxy, vy), math.max(maxz, vz))
    end
  end
  table.insert(objects, object)
end

function pe.debug_draw(x,y,z, rx,ry,rz) --The camera position and rotation
  local cp = maf.vec3(x,y,z)
  local cr = maf.rotation(0,0,0,0)
  cr = cr:angleAxis(rx, 1,0,0)
  cr = cr:angleAxis(rz, 0,0,1)
  cr = cr:angleAxis(ry, 0,1,0)
  for i=1, #objects do
    local o = objects[i]
    for j=1, #o.faces do
      local points = {}
      for k=1, #o.faces[j] do
        local x,y,z = o.vertices[o.faces[j][k]]:unpack()
        local v = maf.vec3(x,y,z) - cp --By unpacking and creating a new vector3, we avoid changing the object's actual data.
        v = v:rotate(cr)
        local vx,vy,vz = v:unpack()
        if vz > 0 then
          vx = vx * 50
          vy = vy * 50
          vz = vz / 5
          table.insert(points, vx / vz + love.graphics.getWidth()/2)
          table.insert(points, vy / vz + love.graphics.getHeight()/2)
        end
      end
      love.graphics.line(points)
    end
  end
end

return pe
