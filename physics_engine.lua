local pe = {} --library table
local maf = require "maf"

local gravity = maf.vec3(0,-9.8,0)

local world_size = 8
local chunk_size = 64

local chunks = {}

function pe.load()
  for x=-world_size/2, world_size/2 do
    for z=-world_size/2, world_size/2 do
      local index = (x + z * world_size) + 1
      table.insert(chunks, {x,z,objects={}})
    end
  end
end

function pe.getRotation(rx,ry,rz)
  return maf.rotation():angleAxis(rx,1,0,0):angleAxis(rz,0,0,1):angleAxis(ry,0,1,0)
end

function pe.SPHEREvSPHERE(a, b)
  local d = a.pos:distance(b.pos)
  return d < a.scale + b.scale
end

function pe.BBOXvBBOX(a, b)
  local min_ax, min_ay, min_az = (a.bbox.min+a.pos):unpack()
  local max_ax, max_ay, max_az = (a.bbox.max+a.pos):unpack()
  local min_bx, min_by, min_bz = (b.bbox.min+b.pos):unpack()
  local max_bx, max_by, max_bz = (b.bbox.max+b.pos):unpack()
  return min_ax < max_bx and min_ay < max_by and min_az < max_bz and max_ax > min_bx and max_ay > min_by and max_az > min_bz
end

function pe.add_rigidbody(type, uuid, x,y,z, rx,ry,rz, sx,sy,sz, mode)
  local chunk_x = math.floor(x / (world_size * chunk_size))
  local chunk_z = math.floor(z / (world_size * chunk_size))
  local index = (chunk_x + chunk_z * world_size) + 1
  local chunk = chunks[index]
  local bbox = {min=maf.vec3(-1,-1,-1),max=maf.vec3(1,1,1)}
  local object = {type=type, bbox=bbox, uuid=uuid, vertices={}, faces={}, pos=maf.vec3(x,y,z), rot=pe.getRotation(rx,ry,rz), scale=maf.vec3(sx,sy,sz), vel=maf.vec3(0,0,0), rotvel=maf.vec3(0,0,0), mode=mode}
  if type == "sphere" then
    bbox.min = maf.vec3(-sx,-sx,-sx)
    bbox.max = maf.vec3(sx,sx,sx)
    object.scale = sx
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
    object.bbox = bbox
  end
  table.insert(chunk.objects, object)
end

function pe.update(dt)
  for j=1, #chunks do
    local c = chunks[j]
    for i=1, #c.objects do
      local o = c.objects[i]
      --Apply gravity
      if o.mode == "dynamic" then o.vel = o.vel + gravity * dt end

      --Check collisions and shit
      for i2=1, #c.objects do
        if i ~= i2 then
          local o2 = c.objects[i2]
          --Check bbox
          if pe.BBOXvBBOX(o, o2) then
            --Do stuff?

          end
        end
      end

      --Apply velocity
      if o.mode == "dynamic" then o.pos = o.pos + o.vel end
    end
  end
end

function pe.debug_draw(x,y,z, rx,ry,rz) --The camera position and rotation
  local cp = maf.vec3(x,y,z)
  local cr = maf.rotation(0,0,0,0)
  cr = cr:angleAxis(rx, 1,0,0)
  cr = cr:angleAxis(rz, 0,0,1)
  cr = cr:angleAxis(ry, 0,1,0)
  for _=1, #chunks do
    local c = chunks[_]
    for i=1, #c.objects do
      local o = c.objects[i]
      for j=1, #o.faces do
        local points = {}
        for k=1, #o.faces[j] do
          local x,y,z = (o.vertices[o.faces[j][k]] + o.pos):unpack()
          local v = maf.vec3(x,y,z) - cp --By unpacking and creating a new vector3, we avoid changing the object's actual data.
          v = v:rotate(cr)
          local vx,vy,vz = v:unpack()
          if vz > 0 then
            vx = vx * 50
            vy = vy * 50
            vz = vz / 5
            table.insert(points, vx / vz + love.graphics.getWidth()/2)
            table.insert(points, love.graphics.getHeight() - (vy / vz + love.graphics.getHeight()/2))
          end
        end
        love.graphics.line(points)
      end
    end
  end
end

return pe
