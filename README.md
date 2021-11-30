# fivem-triplaser
Trip lasers for FiveM.

# video
[![Video](https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png)](https://streamable.com/87jgp9)

## example
```lua


RegisterCommand('testlaser',function()
  local ped = PlayerPedId()
  local fwd,right,up,pos = GetEntityMatrix(ped)

  local v1 = pos + fwd + (right*5) - (up)
  local v2 = pos + fwd - (right*5) - (up)

  local v3 = pos + (fwd*2) + (right*5) + (up*2)
  local v4 = pos + (fwd*2) - (right*5) + (up*2)

  local v5 = pos + (fwd*3) + (right*5) - (up)
  local v6 = pos + (fwd*3) - (right*5) - (up)


  local v7 = pos + fwd - (right*1.5) - (up*5)
  local v8 = pos + fwd - (right*1.5) + (up*5)

  local v9  = pos + (fwd*3) - (up*5)
  local v10 = pos + (fwd*3) + (up*5)

  local v11 = pos + fwd + (right*1.5) - (up*5)
  local v12 = pos + fwd + (right*1.5) + (up*5)

  local flatFwd = norm(vector3(fwd.x,fwd.y,0))

  local myTripLasers = {
    {
      name = "laser_1",
      v1 = v1,
      v2 = v2,
      moveDirections = {
        {
          dir = vector3(0,0,1),
          speed = 0.5,
          maxDist = 3.0,
        }
      }
    },
    {
      name = "laser_2",
      v1 = v3,
      v2 = v4,
      moveDirections = {
        {
          dir = vector3(0,0,-1),
          speed = 0.5,
          maxDist = 2.0,
        }
      }
    },
    {
      name = "laser_3",
      v1 = v5,
      v2 = v6,
      moveDirections = {
        {
          dir = vector3(0,0,1),
          speed = 1,
          maxDist = 3.0,
        }
      }
    },
    {
      name = "laser_4",
      v1 = v7,
      v2 = v8,
      moveDirections = {
        {
          dir = flatFwd,
          speed = 0.5,
          maxDist = 2.0,
        }
      }
    },
    {
      name = "laser_5",
      v1 = v9,
      v2 = v10,
      moveDirections = {
        {
          dir = -flatFwd,
          speed = 0.5,
          maxDist = 2.0,
        }
      }
    },
    {
      name = "laser_6",
      v1 = v11,
      v2 = v12,
      moveDirections = {
        {
          dir = flatFwd,
          speed = 0.5,
          maxDist = 2.0,
        }
      }
    },
  }

  local cols = {
    active = {
      r = 255,
      g = 255,
      b = 255,
      a = 255,
    },
    disabled = {
      r = 255,
      g = 255,
      b = 255,
      a = 100,
    },
    tripped = {
      r = 255,
      g = 0,
      b = 0,
      a = 255,          
    },
  }

  local group = LaserGroup(myTripLasers,function(tripped,laser,ent)
    if tripped then
      print("Laser " .. laser.name .. " tripped by " .. ent)
    else
      print("Laser " .. laser.name .. " untripped")
    end
  end,cols)

  while true do
    group:render()
    Wait(0)
  end
end)
```

## how to use
- clone this repository into your `resources` folder.
- add `start fivem-triplaser` to your `server.cfg` file.
- no method of implementation has been provided, how you choose to use this is entirely up to you.
