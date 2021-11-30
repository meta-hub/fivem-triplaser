local frameTime

Citizen.CreateThread(function()
  while true do
    frameTime = GetFrameTime()
    Wait(0)
  end
end)

local function findCenterPoint(points)
  local point = vector3(0,0,0)

  for i=1,#points do
    point = point + points[i]
  end

  return (point / #points)
end

local function awaitRaycast(...)
  local ray = StartExpensiveSynchronousShapeTestLosProbe(...)
  local retval,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(ray)
  return retval,hit,endCoords,surfaceNormal,entityHit
end

local laserMt = {}

function laserMt:incrimentMovements()
  for i=1,#self.moveDirections do
    local d = self.moveDirections[i]
    local speed = d.speed * frameTime

    if d.incriment then
      self.v1 = self.v1 + (d.dir * speed)
      self.v2 = self.v2 + (d.dir * speed)

      if #(self.v1 - self._v1) > d.maxDist then
        d.incriment = false
      end
    else
      self.v1 = self.v1 - (d.dir * speed)
      self.v2 = self.v2 - (d.dir * speed)

      if #(self.v1 - self._v1) <= 0.5 then
        d.incriment = true
      end
    end
  end
end

function laserMt:tripped(tripped,...)
  self.isTripped = tripped

  if self.onTripped then
    local vargs = {...}

    Citizen.CreateThread(function()
      self.onTripped(tripped,self,table.unpack(vargs))
    end)
  end
end

function laserMt:checkTripped()
  local retval,hit,endCoords,surfaceNormal,entityHit = awaitRaycast(
    self.v1.x,self.v1.y,self.v1.z,
    self.v2.x,self.v2.y,self.v2.z,
    4,
    0,
    4
  )

  if entityHit > 0 then
    if not self.isTripped then
      self:tripped(true,entityHit)
    end
  else
    if self.isTripped then
      self:tripped(false)
    end
  end
end

function laserMt:renderLine()
  local col

  if self.isActive then
    if self.isTripped then
      col = self.cols.tripped
    else
      col = self.cols.active
    end
  else
    col = self.cols.disabled
  end

  DrawLine(
    self.v1.x,self.v1.y,self.v1.z,
    self.v2.x,self.v2.y,self.v2.z,
    col.r,
    col.g,
    col.b,
    col.a
  )
end

function laserMt:onRender()
  self:incrimentMovements()
  self:checkTripped()
  self:renderLine()
end

function laserMt:setActive(e)
  self.isActive = e
end

function Laser(data,onTripped)
  local formatted = {
    name  = data.name or '',

    isTripped = false,
    isActive  = true,

    v1    = data.v1 or vector3(0,0,0),
    v2    = data.v2 or vector3(0,0,0),
    _v1   = data.v1 or vector3(0,0,0),
    _v2   = data.v2 or vector3(0,0,0),

    moveDirections = data.moveDirections or {},

    cols = {
      active = data.cols and data.cols.active or {
        r = 255,
        g = 255,
        b = 255,
        a = 255,
      },
      disabled = data.cols and data.cols.disabled or {
        r = 255,
        g = 255,
        b = 255,
        a = 100,
      },
      tripped = data.cols and data.cols.tripped or {
        r = 255,
        g = 0,
        b = 0,
        a = 255,          
      },
    },
  }

  local mt = setmetatable(formatted,{__index = laserMt})
  mt.onTripped = onTripped

  return mt
end

local laserGroupMt = {}

function laserGroupMt:render()
  for i=1,#self.lasers do
    self.lasers[i]:onRender()
  end
end

function LaserGroup(lasers,onTripped,cols)
  if type(lasers) ~= "table" then
    return error('no args passed',2)
  end

  local formatted = {
    lasers = {}
  }

  for i=1,#lasers do
    local v = lasers[i]

    local laserData = {
      name = v.name or 'name not set',
      v1 = v.v1,
      v2 = v.v2,
      cols = cols,
      moveDirections = {},
    }

    for j=1,#v.moveDirections do
      local val = v.moveDirections[j]

      table.insert(laserData.moveDirections,{
        dir     = val.dir,
        speed   = val.speed,
        maxDist = val.maxDist
      })
    end

    local laser = Laser(laserData,onTripped)

    table.insert(formatted.lasers,laser)
  end

  return setmetatable(formatted,{__index = laserGroupMt})
end