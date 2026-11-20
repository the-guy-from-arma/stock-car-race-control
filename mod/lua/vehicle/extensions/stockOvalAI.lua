local M = {}
local pending, active

function M.start(points, path, speed, aggression, alternate)
  pending = {points=points, path=path, speed=speed, aggression=aggression, elapsed=0, alternate=alternate}
  mapmgr.requestMap()
end

local function registerLane(raceMap, points, prefix)
  for i, p in ipairs(points) do
    raceMap:setPointPositionRadius(prefix .. i, vec3(p[1],p[2],p[3]), 5)
  end
  for i = 1, #points do
    local a, b = prefix .. i, prefix .. (i % #points + 1)
    raceMap:uniEdge(a, b, raceMap.positions[a]:distance(raceMap.positions[b]), 1, 100, nil, false)
  end
end

local function drive(path, speed, aggression)
  ai.driveUsingPath{path=path,noOfLaps=1000,avoidCars="on",aggression=aggression,routeSpeedMode="limit",routeSpeed=speed}
end

function M.updateGFX(dt)
  if not pending then return end
  pending.elapsed = pending.elapsed + dt
  local raceMap = mapmgr.mapData
  if not raceMap then
    if pending.elapsed > 1 then mapmgr.requestMap(); pending.elapsed = 0 end
    return
  end
  local route = pending
  pending = nil
  registerLane(raceMap, route.points, "stockRaceOval")
  active = {map=raceMap, count=#route.points, alternate=route.alternate, aggression=route.aggression}
  drive(route.path, route.speed, route.aggression)
  if route.change then
    M.changeLane(route.change.first, route.change.alternate, route.speed)
  end
end

function M.setTargetSpeed(speed)
  if pending then pending.speed = speed end
  if active then ai.setSpeed(speed) end
end

function M.changeLane(first, alternate, speed)
  if pending then
    pending.change, pending.speed = {first=first, alternate=alternate}, speed
    return
  end
  if not active or active.map ~= mapmgr.mapData or not active.alternate and alternate then return end
  local prefix = alternate and "stockRacePassOval" or "stockRaceOval"
  if alternate and not active.alternateRegistered then
    registerLane(active.map, active.alternate, prefix)
    active.alternateRegistered = true
  end
  local path = {}
  for step = 0, active.count do
    path[#path + 1] = prefix .. ((first + step - 1) % active.count + 1)
  end
  drive(path, speed, active.aggression)
end

function M.cancel() pending, active = nil, nil end
M.onReset = M.cancel
return M
