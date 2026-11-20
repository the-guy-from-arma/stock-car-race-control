local M = {}
local racecraft = require("ge/extensions/stockCarRacecraft")

function M.onInit()
  setExtensionUnloadMode(M, "manual")
end
M.build = "20261120-player-recovery-30"
local racePath = "/gameplay/races/DaytonaGen7Oval.race.json"
local ovalSize = 280
local paceSpeed = 26.8
local raceSpeed = 85
local rowGap = 13
local headGap = 24
local serviceOffset = 5
local clearanceTime = 14
local redClearHold = 5
local cautionHold = 25
local formationHold = 1.5
local paceStallLimit = 30
local paceTimeLimit = 270
local cautionLineupLimit = 60
-- BSC Daytona default spawn, beside the pit wall on the pit-lane side.
local pitBox = {-172.926392, 413.300476, 521.306763}
local pitRadius = 7
local pitSpeed = 55 / 2.236936
-- Pit lane follows the inner side of the Daytona pit wall from turn four to turn one.
local pitRoute = {
  {396, 351, 521.5}, {233, 419, 521.5}, {100, 426, 521.5},
  {-30, 426, 521.5}, {-173, 413, 521.5}, {-292, 382, 521.5}
}
local gridWaypoint = 231
local pitFilter = "daytonaPitOnlyRepairs"
local repairActions = {
  "reset_physics", "reset_all_physics", "recover_vehicle", "recover_vehicle_alt",
  "recover_to_last_road", "loadHome", "reload_vehicle", "reload_all_vehicles"
}
local session
local finish
local broadcastRoster = {
 {24,"William Byron","BYRON","#f2d535"},{21,"Harrison Burton","BURTON","#df303a"},
 {54,"Ty Gibbs","GIBBS","#70ca49"},{12,"Ryan Blaney","BLANEY","#efcd2f"},
 {11,"Denny Hamlin","HAMLIN","#e33c49"},{19,"Martin Truex Jr.","TRUEX JR.","#f1a42d"},
 {1,"Ross Chastain","CHASTAIN","#40b6d5"},{23,"Bubba Wallace","WALLACE","#d7474b"},
 {5,"Kyle Larson","LARSON","#2a96df"},{45,"Tyler Reddick","REDDICK","#e4a72b"},
 {22,"Joey Logano","LOGANO","#f4d42a"},{48,"Alex Bowman","BOWMAN","#5651ad"},
 {99,"Daniel Suarez","SUAREZ","#d43a38"},{6,"Brad Keselowski","KESELOWSKI","#5dbd79"}
}
local notice, noticeId, uiClock = nil, 0, 0
local waypointPrefix = "daytonaOval"
local activeTrack
local trackProfiles = {
  daytonaspeedway = {
    title = "Daytona International Speedway", shortName = "DAYTONA",
    racePath = "/gameplay/races/DaytonaGen7Oval.race.json", prefix = "daytonaOval", size = 280,
    gridAnchor = {550,325,521.7}, gridLabel = "Turn 4 - Pit entrance", gridWaypoint = 231, paceSpeed = 26.8, raceSpeed = 80, aggression = 0.65, launchSeconds = 18, pitLimitMph = 55,
    pitBox = {-172.926392, 413.300476, 521.306763},
    pitRoute = {{396,351,521.5},{233,419,521.5},{100,426,521.5},{-30,426,521.5},{-173,413,521.5},{-292,382,521.5}},
    carConfig = "superspeedway_", carSuffix = "_2026", gridCapacity = 14, pitWidth = 12
  },
  lonestar_speedway = {
    title = "Lonestar Speedway, USA", shortName = "LONE STAR",
    racePath = "/gameplay/races/LonestarOval.race.json", prefix = "lonestarStockOval", size = 242,
    gridWaypoint = 199, paceSpeed = 22.35, raceSpeed = 72, pitLimitMph = 45,
    pitBox = {-255.690033,230.353409,110.053345},
    pitRoute = {{-98.66861,400.622986,110},{-170,329.3,110},{-255.69,230.35,110.05},
      {-323.651581,175.754501,110},{-376.658691,120.504707,110},{-387.015106,90.790558,110},
      {-391.237183,61.305893,109.83}},
    carConfig = "intermediate_", carSuffix = "", gridCapacity = 14, pitWidth = 8
  },
  martinsville = {
    title = "Martinsville Speedway", shortName = "MARTINSVILLE",
    racePath = "/gameplay/races/MartinsvilleStockOval.race.json", prefix = "martinsvilleStockOval", size = 101,
    gridWaypoint = 56, paceSpeed = 13.41, raceSpeed = 35.76, aggression = 0.65, catchupSpeed = 3, keepStartLane = true, pitLimitMph = 30,
    pitBox = {31.1842422, -103.448288, 52.7961349},
    pitRoute = {{-94.302238, -205.216436, 52.8}, {-100.671443, -242.502644, 52.8}, {-87.04006, -263.903912, 52.8}, {-65.12402, -272.848326, 52.8}, {-40.307405, -266.947663, 52.8}, {-18.528806, -234.559462, 52.8}, {-6.814823, -203.402185, 52.8}, {-0.43228, -185.138386, 52.8}, {3.588745, -172.851143, 52.8}, {6.438043, -163.806925, 52.8}, {8.70438, -156.676191, 52.8}, {10.728704, -150.699831, 52.8}, {12.737547, -145.374008, 52.8}, {14.903819, -140.305923, 52.8}, {17.382039, -135.130724, 52.8}, {20.337373, -129.443005, 52.8}, {23.982722, -122.70984, 52.8}, {28.645093, -114.115276, 52.8}, {31.1842422, -103.448288, 52.7961349}, {44.039002, -83.984831, 52.8}, {59.295642, -51.618557, 52.8}, {64.599766, -15.026341, 52.8}, {50.318011, 5.676482, 52.8}, {28.107912, 14.090056, 52.8}, {3.130149, 7.306259, 52.8}, {-18.528806, -27.133232, 52.8}, {-29.91932, -57.526131, 52.8}, {-36.109463, -75.335308, 52.8}, {-39.99751, -87.308303, 52.8}, {-42.745092, -96.112148, 52.8}, {-44.927426, -103.044386, 52.8}},
    carConfig = "shorttrack_low_", carSuffix = "", gridCapacity = 14, pitWidth = 5
  }
}
local expansionTracks = {
  bristolmotorspeedway = {title="Bristol Motor Speedway", shortName="BRISTOL",
    paceSpeed=14, raceSpeed=44, aggression=0.60, pitLimitMph=30,
    launchSeconds=17, launchSpeed=30,
    carConfig="shorttrack_low_", stageFraction=0.25},
  phoenix = {title="Phoenix Raceway", shortName="PHOENIX",
    paceSpeed=18, raceSpeed=55, aggression=0.61, pitLimitMph=40,
    launchSeconds=28, launchSpeed=34,
    carConfig="intermediate_", stageFraction=0.19},
  tbd_newport_speedway_oval = {title="Newport Speedway", shortName="NEWPORT",
    paceSpeed=10, raceSpeed=29.5, aggression=0.58, pitLimitMph=25,
    launchSeconds=12, launchSpeed=22,
    carConfig="shorttrack_low_", stageFraction=0.25}
}
for level, profile in pairs(expansionTracks) do
  profile.racePath = "/gameplay/races/stockcar/" .. level .. ".json"
  profile.surveyed = true
  profile.manualPits = true
  profile.gridCapacity = 14
  profile.serviceOffset = 3.4
  profile.catchupSpeed = 3
  profile.keepStartLane = true
  trackProfiles[level] = profile
end

local function selectTrack()
  local profile = trackProfiles[getCurrentLevelIdentifier()]
  if not profile then return nil end
  if profile.surveyed and not profile.geometry then
    local data = jsonReadFile(profile.racePath)
    if not data or type(data.points) ~= "table" or #data.points < 20
      or type(data.bank) ~= "table" or #data.bank ~= #data.points
      or type(data.pitRoute) ~= "table" or #data.pitRoute < 2 then return nil end
    profile.geometry = data
    profile.size = #data.points
    profile.gridWaypoint = data.gridWaypoint
    profile.pitBox, profile.pitRoute, profile.pitWidth = data.pitBox, data.pitRoute, data.pitWidth
  end
  activeTrack = profile
  racePath, waypointPrefix, ovalSize = profile.racePath, profile.prefix, profile.size
  gridWaypoint, paceSpeed, raceSpeed = profile.gridWaypoint, profile.paceSpeed, profile.raceSpeed
  pitBox, pitRoute, pitSpeed = profile.pitBox, profile.pitRoute, profile.pitLimitMph / 2.236936
  return profile
end

local function announce(message)
  if notice and notice.text == message and uiClock - notice.at < 2 then return end
  noticeId = noticeId + 1
  notice = {id = noticeId, text = message, at = uiClock}
  print("[Daytona] " .. message)
  -- Keep race messages in our bounded HUD instead of spawning vanilla toast cards.
  guihooks.trigger("DaytonaRaceControlNotice", notice)
end

local function vehicle(id)
  return be:getObjectByID(id)
end

local function stockCarCount()
  local count = 0
  for _, car in ipairs(getAllVehicles()) do
    if car:getJBeamFilename() == "cupgen7" then count = count + 1 end
  end
  return count
end

local function blockResetActions(block)
  core_input_actionFilter.setGroup(pitFilter, repairActions)
  core_input_actionFilter.addAction(0, pitFilter, block)
end

local function wrap(distance)
  return distance % session.length
end

local function loadOval()
  local points, along, segments = {}, {}, {}
  local geometry = activeTrack and activeTrack.geometry
  local nav = not geometry and map.getMap()
  for index = 1, ovalSize do
    if geometry then
      points[index] = vec3(geometry.points[index])
    else
      local name = waypointPrefix .. index
      local waypoint = scenetree.findObject(name)
      if not waypoint or not nav then return nil end
      local nodeName = nav.nodeAliases and nav.nodeAliases[name] or name
      if not nav.nodes[nodeName] then return nil end
      points[index] = vec3(waypoint:getPosition())
    end
  end
  local length = 0
  for index, point in ipairs(points) do
    local delta = points[index % ovalSize + 1] - point
    local size = delta:length()
    if size < 0.1 then return nil end
    along[index] = length
    local direction = delta / size
    segments[index] = {direction = direction, size = size, right = vec3(direction.y, -direction.x, 0):normalized()}
    length = length + size
  end
  return {points = points, along = along, segments = segments, length = length, bank = geometry and geometry.bank}
end

local function sample(distance, offset)
  local s = wrap(distance)
  for i = ovalSize, 1, -1 do
    if s >= session.along[i] then
      local segment = session.segments[i]
      local along = s - session.along[i]
      local lateral = segment.right * offset
      if session.bank then
        local bank = session.bank[i]
        local nextBank = session.bank[i % ovalSize + 1]
        lateral.z = offset * (bank + (nextBank - bank) * along / segment.size)
      end
      return session.points[i] + segment.direction * along + lateral, segment.direction
    end
  end
end

local function project(pos)
  local best, nearest, lateral = math.huge, 0, 0
  for i, point in ipairs(session.points) do
    local segment = session.segments[i]
    local dx, dy, dz = pos.x-point.x, pos.y-point.y, pos.z-point.z
    local dir = segment.direction
    local offset = clamp(dx*dir.x + dy*dir.y + dz*dir.z, 0, segment.size)
    local ex, ey, ez = dx-dir.x*offset, dy-dir.y*offset, dz-dir.z*offset
    local errorSq = ex*ex + ey*ey + ez*ez
    if errorSq < best then
      best, nearest = errorSq, session.along[i] + offset
      lateral = dx*segment.right.x + dy*segment.right.y + dz*segment.right.z
    end
  end
  return wrap(nearest), math.sqrt(best), lateral
end

local function updatePosition(entry, car)
  local s, offTrack, lateral = project(car:getPosition())
  if entry.s then
    local travel = wrap(s - entry.s + session.length * 0.5) - session.length * 0.5
    if math.abs(travel) < 35 then entry.distance = entry.distance + travel end
  else
    entry.distance = s > session.length * 0.5 and s - session.length or s
  end
  entry.s, entry.offTrack, entry.lateral = s, offTrack, lateral
end

local function release(car)
  car:queueLuaCommand([[ai.setMode("disabled")
    if extensions.stockOvalAI then extensions.stockOvalAI.cancel() end
    for _, control in ipairs({"steering", "throttle", "brake", "parkingbrake"}) do
      input.event(control, 0, "FILTER_AI", nil, nil, nil, "ai")
    end]])
end

local arcadeGearbox = [[if controller.mainController.gearboxBehavior ~= "arcade" then
  extensions.load("daytonaDamageHud")
  extensions.daytonaDamageHud.setGearboxModeQuietly("arcade")
end]]

local function endCautionAssist()
  if not session then return end
  local player = vehicle(session.playerId)
  if session.cautionAssist and player then
    release(player)
    player:queueLuaCommand([[if daytonaPaceSavedGearbox then
      extensions.load("daytonaDamageHud")
      extensions.daytonaDamageHud.setGearboxModeQuietly(daytonaPaceSavedGearbox)
      daytonaPaceSavedGearbox = nil
    end]])
  end
  session.cautionAssist, session.playerLinedSince = false, nil
end

local function recoverFormation(car, entry, tangent)
  if session.phase ~= "yellow" or entry.engineDisabled or entry.out or entry.inPit then return false end
  local alignment = vec3(car:getDirectionVector()):dot(tangent)
  if not entry.recovery and (entry.sidewaysTime or 0) < 2 then return false end
  if alignment > 0.8 then entry.recovery = nil; entry.sidewaysTime = 0; return false end
  entry.recovery = entry.recovery or {started = session.elapsed, attempts = 0, phaseAt = session.elapsed, phase = "reverse"}
  local r = entry.recovery
  if session.elapsed - r.started > 24 then entry.recoveryFailed = true; entry.recovery = nil; return false end
  local forward = vec3(car:getDirectionVector())
  local right = forward:cross(vec3(car:getDirectionVectorUp()))
  if session.elapsed - r.phaseAt > (r.phase == "reverse" and 2.5 or 4) then
    r.phase = r.phase == "reverse" and "forward" or "reverse"; r.phaseAt = session.elapsed
  end
  local direction = r.phase == "reverse" and -1 or 1
  local clear = true
  -- Keep the maneuver inside the usable oval; never reverse blindly off its edge.
  local proposed = car:getPosition() + forward * (direction * 6)
  local nearS = project(proposed)
  local roadPosition = sample(nearS, 0)
  if (proposed - roadPosition):length() > 16 then clear = false end
  for _, other in ipairs(session.entries) do
    local obstacle = other.id ~= entry.id and vehicle(other.id)
    if obstacle then
      local delta = obstacle:getPosition() - car:getPosition()
      local along = delta:dot(forward) * direction
      if along > -2 and along < 9 and math.abs(delta:dot(right)) < 3 then clear = false end
    end
  end
  local steer = clamp(math.atan2(tangent:dot(right), tangent:dot(forward)), -0.8, 0.8)
  if r.phase == "reverse" then steer = -steer end
  local moving = clear and car:getVelocity():length() < 3
  local throttle = moving and r.phase == "forward" and 0.35 or 0
  local brake = moving and r.phase == "reverse" and 0.35 or 0
  car:queueLuaCommand(string.format('input.event("steering",%g,"FILTER_AI"); input.event("throttle",%g,"FILTER_AI"); input.event("brake",%g,"FILTER_AI"); input.event("parkingbrake",%d,"FILTER_AI")', steer, throttle, brake, clear and 0 or 1))
  return true
end

local function formationControl(car, entry, offset, speed, worldTarget)
  entry.controlTargetSpeed = speed
  local velocity = car:getVelocity():length()
  local target = worldTarget or sample(entry.s + math.max(13, velocity * 0.75), offset)
  local forward = vec3(car:getDirectionVector())
  local right = forward:cross(vec3(car:getDirectionVectorUp()))
  local direction = (target - car:getPosition()):normalized()
  local steer = clamp(math.atan2(direction:dot(right), direction:dot(forward)) * 2.1, -0.8, 0.8)
  if speed <= 0 then steer = 0 end
  local error = speed - velocity
  local throttle = speed > 0 and clamp(0.14 + 0.105 * error, 0, 1) or 0
  local brake = clamp((-error - 0.6) * 0.14, 0, 0.85)
  -- Arcade brake input selects reverse near zero wheel speed. Stop with the
  -- parking brake before that threshold; throttle brakes an already reversing car.
  local signedSpeed = car:getVelocity():dot(forward)
  if signedSpeed < -0.5 then brake = 0; throttle = math.max(throttle, clamp(0.4 - signedSpeed * 0.1, 0, 1)) end
  if velocity < 1.8 then brake = 0 end
  local park = speed < 0.5 and velocity < 3 and 1 or 0
  if park == 1 then throttle, brake = 0, 0 end
  entry.commandedThrottle = throttle
  local signature = string.format("%.3f/%.3f/%.3f/%d", steer, throttle, brake, park)
  if entry.controlSignature == signature and session.elapsed - (entry.controlSentAt or 0) < 0.2 then return end
  entry.controlSignature, entry.controlSentAt = signature, session.elapsed
  car:queueLuaCommand(string.format([[
    input.event("steering", %.4f, "FILTER_AI", nil, nil, nil, "ai")
    input.event("throttle", %.4f, "FILTER_AI", nil, nil, nil, "ai")
    input.event("brake", (electrics.values.smoothShiftLogicAV or 0) > 3 and %.4f or 0, "FILTER_AI", nil, nil, nil, "ai")
    input.event("parkingbrake", %d, "FILTER_AI", nil, nil, nil, "ai")
  ]], steer, throttle, brake, park))
end

local function spawnCar(model, config, pos, rot, label)
  local car = core_vehicles.spawnNewVehicle(model, {
    config = "vehicles/" .. model .. "/" .. config .. ".pc",
    pos = pos,
    rot = rot,
    autoEnterVehicle = false,
    vehicleName = label
  })
  if car then
    session.spawned[#session.spawned + 1] = car:getId()
    return car
  end
end

local supportRoster = {
  {model="van", config="ambulance", label="Race Ambulance", gap=20},
  {model="us_semi", config="tc82s_rollback", label="Race Recovery Truck", gap=33}
}
local function parkSupport(car)
  release(car)
  car:setMeshAlpha(0, "")
  car:setActive(0)
end
local function acquireSupport(spec, pos, rot)
  -- The lateral edge of a banked/elevated track is not at the centerline Z.
  -- Drop from above its static collision surface before resetting pooled nodes.
  if castRayStatic then
    local origin = pos + vec3(0, 0, 12)
    local distance = castRayStatic(origin, vec3(0, 0, -1), 24)
    if distance < 24 then pos = vec3(pos.x, pos.y, origin.z - distance + 0.5) end
  end
  session.supportPool = session.supportPool or {}
  local key = spec.model .. "/" .. spec.config
  local id = session.supportPool[key]
  local car = id and vehicle(id)
  if car then
    car:applyClusterVelocityScaleAdd(car:getRefNodeId(), 0, 0, 0, 0)
    -- Reuse the exact surveyed track elevation; safe-spawn searches can put
    -- a pooled vehicle on terrain beneath an elevated track.
    local rotation = quat(0, 0, 1, 0) * rot
    car:setActive(1)
    car:setPosRot(pos.x, pos.y, pos.z, rotation.x, rotation.y, rotation.z, rotation.w)
    car:resetBrokenFlexMesh()
    car:setMeshAlpha(1, "")
  else
    car = spawnCar(spec.model, spec.config, pos, rot, spec.label)
    if car then session.supportPool[key] = car:getId() end
  end
  if car then car:queueLuaCommand(arcadeGearbox) end
  return car
end
local function paceSpec()
  if FS:fileExists("/vehicles/flanje_durango/Durango Pursuit.pc") then
    return {model="flanje_durango", config="Durango Pursuit", label="Race Pace Car"}
  end
  return {model="legran", config="police", label="Race Pace Car"}
end
local function prewarmServices()
  local pos, dir = sample(0, 0)
  for i, spec in ipairs(supportRoster) do
    local car = acquireSupport(spec, session.pitPosition + vec3(i*15,0,1), quatFromDir(dir,vec3(0,0,1)))
    if car then parkSupport(car) end
  end
end

local function removeSpawned(id)
  local car = vehicle(id)
  if car and session.supportPool then
    for _, pooledId in pairs(session.supportPool) do
      if pooledId == id then parkSupport(car); return end
    end
  end
  if car then car:delete() end
  for index, spawnedId in ipairs(session.spawned) do
    if spawnedId == id then
      table.remove(session.spawned, index)
      return
    end
  end
end

local function removePaceCar()
  if session.pace then
    removeSpawned(session.pace.id)
    session.pace = nil
  end
end

local function distanceAhead(from, to)
  return wrap(to - from)
end

local function incidentStatus()
  local blocked = false
  local active = false
  for _, center in pairs(session.incidents) do
    local inner, middle, outer = false, false, false
    for _, wreck in pairs(session.incidents) do
      local separation = math.min(distanceAhead(center.s, wreck.s), distanceAhead(wreck.s, center.s))
      if separation < 25 then
        inner = inner or wreck.lateral - wreck.width <= -4
        middle = middle or math.abs(wreck.lateral) <= wreck.width
        outer = outer or wreck.lateral + wreck.width >= 4
      end
    end
    active = true
    blocked = blocked or (inner and middle and outer)
  end
  return blocked
end

local function compactOval()
  return session.track.surveyed and session.length < 1100
end

local function cautionLane(entry, desired)
  local hazards, nearest = {}, nil
  for _, wreck in pairs(session.incidents) do
    local ahead, behind = distanceAhead(entry.s, wreck.s), distanceAhead(wreck.s, entry.s)
    if wreck.id ~= entry.id and (ahead < 110 or behind < 12) then
      hazards[#hazards + 1] = wreck
      nearest = math.min(nearest or 110, ahead < 110 and ahead or 0)
    end
  end
  -- A deployed pace car can be behind the frozen field. Pass it in a clear
  -- lane before collecting the lineup, instead of driving into its rear.
  if session.pace and entry.id == session.pace.id then
    for _, other in ipairs(session.order) do
      local ahead = distanceAhead(entry.s, other.s)
      local behind = distanceAhead(other.s, entry.s)
      local car = vehicle(other.id)
      local nearby = ahead < 65 or behind < 15
      if compactOval() then nearby = car and car:getVelocity():length() < 1.5 and (ahead < 26 or behind < 7) end
      if nearby then
        hazards[#hazards + 1] = {lateral = other.lateral or 0, width = 1.2}
        nearest = math.min(nearest or 65, ahead < 65 and ahead or 0)
      end
    end
  end
  -- Off-line stopped cars and recovery trucks are obstacles even before
  -- incident classification. Ordinary queued cars remain follow targets.
  for _, other in ipairs(session.entries) do
    local car = other.id ~= entry.id and vehicle(other.id)
    if car and other.s and (other.out or (car:getVelocity():length() < 2 and math.abs(other.lateral or 0) > 1.6)) then
      local ahead, behind = distanceAhead(entry.s, other.s), distanceAhead(other.s, entry.s)
      if ahead < 65 or behind < 12 then
        hazards[#hazards + 1] = {lateral = other.lateral or 0, width = 1.2}
        nearest = math.min(nearest or 65, ahead < 65 and ahead or 0)
      end
    end
  end
  for _, unit in ipairs(session.response and session.response.units or {}) do
    if unit.id ~= entry.id and unit.s and unit.lateral then
      local ahead, behind = distanceAhead(entry.s, unit.s), distanceAhead(unit.s, entry.s)
      if ahead < 65 or behind < 12 then
        hazards[#hazards + 1] = {lateral = unit.lateral, width = 1.5}
        nearest = math.min(nearest or 65, ahead < 65 and ahead or 0)
      end
    end
  end
  if #hazards == 0 then return desired end
  for _, offset in ipairs({entry.avoidanceOffset or desired, desired, 4.8, -4.8, 2.4, -2.4, 0}) do
    local clear = true
    for _, wreck in ipairs(hazards) do
      if math.abs(offset - wreck.lateral) < wreck.width + 1.9 then clear = false; break end
    end
    if clear then return offset, nearest end
  end
  return nil, nearest
end

local function dispatchService(wreck)
  local units = {}
  for index, spec in ipairs(supportRoster) do
    local target = wrap(wreck.s - spec.gap)
    for extra = 0, 100, 20 do
      local pos, dir = sample(target - 38 - (index - 1) * 16 - extra, session.track.serviceOffset or serviceOffset)
      local clear = true
      for _, other in ipairs(getAllVehicles()) do
        if other:getActive() and (other:getPosition() - pos):squaredLength() < 144 then
          clear = false
          break
        end
      end
      if clear then
        local car = acquireSupport(spec, pos + vec3(0, 0, 0.4),
          quatFromDir(dir, vec3(0, 0, 1)))
        if car then
          local unit = {id = car:getId(), target = target}
          updatePosition(unit, car)
          units[#units + 1] = unit
          car:queueLuaCommand('electrics.set_lightbar_signal(1)')
          break
        end
      end
    end
  end
  return units
end

local function updateIncidentResponse()
  local wreck
  for id, incident in pairs(session.incidents) do
    if not vehicle(id) then
      session.incidents[id] = nil
    elseif incident.disabled and id ~= session.playerId and session.elapsed - incident.detectedAt >= 60 then
      -- Clear every aged disabled wreck in a multi-car crash; do not make
      -- the entire field wait for a separate 52-second service per car.
      removeSpawned(id)
      session.incidents[id] = nil
      session.clearSince = session.elapsed
    else
      local needsTow = id == session.playerId and (session.playerWantsTow or session.allAI and incident.disabled)
        or id ~= session.playerId and incident.disabled
      if needsTow and (not wreck or incident.detectedAt < wreck.detectedAt) then wreck = incident end
    end
  end
  local response = session.response
  if response and not session.incidents[response.wreckId] then
    for _, unit in ipairs(response.units) do removeSpawned(unit.id) end
    if response.wreckId == session.playerId then session.playerWantsTow = nil end
    session.response = nil
    response = nil
  end
  if not response and wreck then
    response = {wreckId = wreck.id, units = dispatchService(wreck), dispatchedAt = session.elapsed}
    session.response = response
    announce("Emergency crews dispatched. Hold position behind the pace car.")
  end
  if not response then return end

  local allArrived = #response.units > 0
  for _, unit in ipairs(response.units) do
    local car = vehicle(unit.id)
    if car then
      updatePosition(unit, car)
      local gap = distanceAhead(unit.s, unit.target)
      if gap > session.length * 0.5 then gap = 0 end
      formationControl(car, unit, session.track.serviceOffset or serviceOffset, clamp((gap - 2) * 0.65, 0, 11))
      allArrived = allArrived and gap < 6 and car:getVelocity():length() < 2
    else
      allArrived = false
    end
  end
  if allArrived then
    response.arrivedAt = response.arrivedAt or session.elapsed
  else
    response.arrivedAt = nil
  end
  local serviced = response.arrivedAt and session.elapsed - response.arrivedAt >= clearanceTime
  local timedOut = session.elapsed - response.dispatchedAt >= 52
  if response.wreckId == session.playerId then
    local car = vehicle(session.playerId)
    if not (session.playerWantsTow or session.allAI) or not (serviced or timedOut)
      or not car or car:getVelocity():length() > 1 then return end
    local entry = session.entries[1]
    endCautionAssist()
    session.pitResetUntil = session.elapsed + 2
    local pitProgress = project(session.pitPosition)
    local _, heading = sample(pitProgress, 0)
    spawn.safeTeleport(car, session.pitPosition, quatFromDir(heading, vec3(0, 0, 1)),
      nil, nil, nil, false, false)
    entry.out = true
    entry.s, entry.lateral = pitProgress, nil
    entry.distance = entry.distance - session.length
    session.playerAwaitingRepair = true
    session.playerWantsTow = nil
  end
  if serviced or timedOut then
    local isPlayer = response.wreckId == session.playerId
    if not isPlayer then removeSpawned(response.wreckId) end
    session.incidents[response.wreckId] = nil
    for _, unit in ipairs(response.units) do removeSpawned(unit.id) end
    session.response = nil
    session.clearSince = session.elapsed
    if isPlayer then
      announce("Towed to pit road | One lap lost. Request repairs in the pit box.")
    else
      announce(serviced and "Recovery complete. Keep the field in order." or "Race control cleared the disabled car.")
    end
  end
end

local function pacePlacement(leader, collecting)
  local compact = compactOval()
  local gap = collecting and (compact and headGap + 18 or 300) or headGap + 10
  local search = compact and math.max(0, session.length * 0.42 - gap) or 250
  local clearance = compact and 13 or 30
  local pos, dir
  for extra = 0, search, compact and 7 or 25 do
    local candidate, direction = sample(leader.s + gap + extra, 0)
    local clear = true
    for _, entry in ipairs(session.entries) do
      local racer = vehicle(entry.id)
      if racer and (racer:getPosition() - candidate):squaredLength() < clearance * clearance then
        clear = false
        break
      end
    end
    if clear then
      pos, dir = candidate, direction
      break
    end
  end
  return pos, dir
end

local function paceCarAhead(leader)
  if session.pace and vehicle(session.pace.id) then return true end
  local pos, dir = pacePlacement(leader, session.phase == "green")
  if not pos then return false end
  local spawnPos = pos + vec3(0, 0, 0.4)
  local rotation = quatFromDir(dir, vec3(0, 0, 1))
  local car = acquireSupport(paceSpec(), spawnPos, rotation)
  if not car then return false end
  session.pace = {id = car:getId()}
  updatePosition(session.pace, car)
  car:queueLuaCommand('electrics.set_lightbar_signal(1)')
  return true
end

local function beginCautionAssist(opening)
  if session.allAI or session.cautionAssist then return end
  for _, entry in ipairs(session.entries) do
    if entry.id == session.playerId and not entry.inPit then
      local car = vehicle(entry.id)
      if not car then return end
      release(car)
      car:queueLuaCommand("daytonaPaceSavedGearbox = controller.mainController.gearboxBehavior\n" .. arcadeGearbox)
      session.cautionAssist = true
      announce(opening and "Opening pace lap | AI driving. Control returns at green." or "Caution AI engaged. Control returns at green.")
      return
    end
  end
end

local function assignFormation(phase, order)
  session.playerLinedSince = nil
  for _, entry in ipairs(session.entries) do
    local car = vehicle(entry.id)
    if car and (entry.id ~= session.playerId or session.allAI or session.cautionAssist) and not entry.spinUntil then
      release(car)
      car:queueLuaCommand(arcadeGearbox)
    end
  end
  session.phase = phase
  session.order = {}
  for _, entry in ipairs(order) do
    if not entry.inPit then session.order[#session.order + 1] = entry end
  end
  session.phaseAt = session.elapsed
  session.formedSince, session.formedAt = nil, nil
end

local function checkCautionHandoff(entry, car, rolling, gap, desiredGap, offset, ahead)
  if session.allAI or session.cautionAssist or session.phase == "pace" or session.pitPlan then return end
  if not rolling or session.blocked or session.manualPitApproach or session.playerWantsTow or session.incidents[entry.id]
    or not car or entry.inPit or entry.out then
    session.playerLinedSince = nil
    return
  end
  local aheadCar = vehicle(ahead.id)
  local spacing = distanceAhead(entry.s, ahead.s)
  local _, tangent = sample(entry.s, 0)
  local forward = car:getVelocity():dot(tangent)
  local pace = vehicle(session.pace.id)
  local targetSpeed = aheadCar and aheadCar:getVelocity():length() or 0
  local lined = gap >= 8 and math.abs(gap - desiredGap) <= 12 and spacing >= 7 and spacing <= 45
    and math.abs(entry.lateral - offset) <= 1.6 and pace and pace:getVelocity():length() >= 2
    and (session.phase ~= "yellow" or math.abs(entry.lateral - (ahead.lateral or 0)) <= 2)
    and car:getDirectionVector():dot(tangent) >= 0.9 and car:getDirectionVectorUp().z > 0.55
    and forward >= 3 and targetSpeed >= 2 and math.abs(forward - targetSpeed) <= 5
  if not lined then
    session.playerLinedSince = nil
    return
  end
  session.playerLinedSince = session.playerLinedSince or session.elapsed
  if session.elapsed - session.playerLinedSince >= 1.0 then
    beginCautionAssist()
    entry.controlSignature = nil
  end
end

local function standings()
  local order = {}
  for _, entry in ipairs(session.entries) do
    if vehicle(entry.id) and not entry.out then order[#order + 1] = entry end
  end
  table.sort(order, function(a, b)
    local ad, bd = a.distance or a.s or 0, b.distance or b.s or 0
    if ad == bd then return a.id < b.id end
    return ad > bd
  end)
  return order
end

local function displayOrder()
  if session.phase == "green" then return standings() end
  if session.phase == "finished" then return session.results end
  if session.phase ~= "checkered" then return session.order end
  local order = {}
  for _, entry in ipairs(session.results) do order[#order + 1] = entry end
  for _, entry in ipairs(standings()) do
    if not entry.finished then order[#order + 1] = entry end
  end
  return order
end

local function updateFormation()
  local pace = session.pace
  local paceVehicle = pace and vehicle(pace.id)
  if not paceVehicle then return end
  updatePosition(pace, paceVehicle)
  local surviving = {}
  for _, entry in ipairs(session.order) do
    if vehicle(entry.id) and not entry.out and not entry.inPit then surviving[#surviving + 1] = entry end
  end
  -- Recovered cars rejoin at the rear instead of trying to cross the queue
  -- to reclaim a slot ahead of traffic.
  local queued, recovering = {}, {}
  for _, entry in ipairs(surviving) do
    local list = entry.recovery and recovering or queued
    list[#list + 1] = entry
  end
  for _, entry in ipairs(recovering) do queued[#queued + 1] = entry end
  session.order = queued
  local rolling = session.elapsed >= session.holdUntil
  local ready = rolling
  local leader = session.order[1]
  local signedLeadGap = leader and (wrap(pace.s - leader.s + session.length * 0.5) - session.length * 0.5) or headGap
  local compact = compactOval()
  pace.collectionStall = (signedLeadGap < headGap or compact) and paceVehicle:getVelocity():length() < 1
    and pace.collectionS and math.abs(pace.s - pace.collectionS) < 0.2
    and ((pace.collectionStall or 0) + 0.1) or 0
  pace.collectionS = pace.s
  if leader and rolling and not session.blocked and pace.collectionStall > 8
    and session.elapsed >= (pace.nextCollectionAttempt or 0) then
    pace.nextCollectionAttempt = session.elapsed + 10
    local pos, dir
    if compact then
      pos, dir = pacePlacement(leader, true)
    else
      pos, dir = sample(leader.s + headGap + 20, 0)
    end
    if pos and (pos - paceVehicle:getPosition()):length() > 18 then
      local rot = quat(0, 0, 1, 0) * quatFromDir(dir, vec3(0, 0, 1))
      paceVehicle:applyClusterVelocityScaleAdd(paceVehicle:getRefNodeId(), 0, 0, 0, 0)
      paceVehicle:setPosRot(pos.x, pos.y, pos.z + 0.55, rot.x, rot.y, rot.z, rot.w)
      pace.s, pace.distance = nil, nil
      updatePosition(pace, paceVehicle)
      pace.collectionStall = 0
      session.greenTarget = nil
    end
  end
  local leadGap = leader and wrap(pace.s - leader.s) or headGap
  local targetPace = leadGap > headGap + 20 and math.min(18, paceSpeed) or paceSpeed
  if leadGap > 75 and leadGap < session.length * 0.5 then targetPace = math.min(12, paceSpeed * 0.75) end
  local paceOffset, approach = cautionLane(pace, 0)
  if approach then
    targetPace = paceOffset and math.min(targetPace, math.max(3, math.min(12, approach * 0.25))) or 0
  end
  if compact and paceOffset then
    for _, entry in ipairs(session.order) do
      local obstacle = vehicle(entry.id)
      local spacing = wrap(entry.s - pace.s)
      if obstacle and spacing < 30 and math.abs((entry.lateral or 0) - paceOffset) < 2.9 then
        targetPace = math.min(targetPace, math.max(0, obstacle:getVelocity():length() + (spacing - 8) * 0.6))
      end
    end
  end
  if session.blocked then targetPace = 0 end
  session.targetPace = rolling and targetPace or 0
  pace.avoidanceOffset = paceOffset
  formationControl(paceVehicle, pace, paceOffset or 0, session.targetPace)
  local doubleFile = session.phase ~= "yellow"
  for index, entry in ipairs(session.order) do
    local row = doubleFile and math.floor((index - 1) / 2) or index - 1
    local offset = doubleFile and (index % 2 == 1 and -1.9 or 1.9) or 0
    local predecessor = not doubleFile and session.order[index-1]
    local mergeSpacing
    if predecessor then
      mergeSpacing = wrap(predecessor.s-entry.s+session.length*0.5)-session.length*0.5
      if mergeSpacing < 12 and (not compact or mergeSpacing >= 0) then
        offset = clamp(entry.lateral or 0, -4.8, 4.8)
      end
    end
    if doubleFile then entry.formationOffset = offset end
    local car = vehicle(entry.id)
    local gap = wrap(pace.s - entry.s + session.length * 0.5) - session.length * 0.5
    local desiredGap = headGap + row * rowGap
    if car and (math.abs(gap - desiredGap) > 10 or math.abs(entry.lateral - offset) > 1.5) then
      ready = false
    end
    if entry.id == session.playerId then
      session.playerGap = gap - desiredGap
      if session.cautionAssist and entry.inPit and not session.pitPlan then endCautionAssist() end
      local follow = session.order[index - (doubleFile and 2 or 1)] or pace
      checkCautionHandoff(entry, car, rolling, gap, desiredGap, offset, follow)
    end
    if car and (entry.id ~= session.playerId or session.allAI or session.cautionAssist) and not (entry.id==session.playerId and session.pitPlan and session.pitPlan.phase~="queued") and (not entry.spinUntil or session.blocked) then
      local followGap = compact and wrap(pace.s - entry.s) or gap
      local limit = clamp(paceVehicle:getVelocity():length() + (followGap - desiredGap) * 0.55, 0, paceSpeed + (session.track.catchupSpeed or 9))
      if predecessor and mergeSpacing and mergeSpacing < 12 and (not compact or mergeSpacing >= 0) then
        local previousCar=vehicle(predecessor.id)
        if previousCar then limit=math.min(limit,math.max(0,previousCar:getVelocity():length()+(mergeSpacing-12)*0.8)) end
      end
      if session.blocked then limit = 0 end
      local ahead = session.order[index - (doubleFile and 2 or 1)]
      local aheadCar = ahead and vehicle(ahead.id)
      if aheadCar then
        local spacing = wrap(ahead.s - entry.s)
        if spacing < 35 then
          local followLimit = aheadCar:getVelocity():length() + (spacing - 9) * 0.65
          limit = math.min(limit, math.max(0, followLimit))
        end
      end
      local safeOffset, approach = cautionLane(entry, offset)
      if approach then limit = safeOffset and math.min(limit, math.max(3, math.min(12, approach * 0.25))) or 0 end
      -- Respect physical cars, including adjacent rows still merging into
      -- single file, rather than only the assigned predecessor.
      local _, tangent = sample(entry.s, 0)
      local right = vec3(tangent.y, -tangent.x, 0)
      local position = car:getPosition()
      for _, other in ipairs(session.entries) do
        local obstacle = other.id ~= entry.id and vehicle(other.id)
        if obstacle then
          local delta = obstacle:getPosition() - position
          local longitudinal = delta:dot(tangent)
          local lateral = math.abs(delta:dot(right))
          if longitudinal > 0 and longitudinal < 28 and lateral < 2.8 then
            limit = math.min(limit, math.max(0, obstacle:getVelocity():length() + (longitudinal - 10) * 0.65))
          end
        end
      end
      entry.avoidanceOffset = safeOffset
      if entry.recovery and (session.blocked or not rolling) then
        entry.recovery.started = session.elapsed
        entry.recovery.phaseAt = session.elapsed
      end
      if session.blocked or not rolling or not recoverFormation(car, entry, tangent) then
        formationControl(car, entry, safeOffset or offset, rolling and limit or 0)
      end
    end
  end
  return ready
end

local function firstRaceNode(progress)
  for i = 1, ovalSize do
    if session.along[i] > progress then return i end
  end
  return 1
end

local function raceLanePoints(lane)
  session.raceLanes = session.raceLanes or {}
  if session.raceLanes[lane] then return session.raceLanes[lane] end
  local coords = {}
  local offset = racecraft.offset(lane)
  for i, point in ipairs(session.points) do
    local target = point + session.segments[i].right * offset
    if session.bank then target.z = target.z + offset * session.bank[i] end
    coords[i] = {target.x, target.y, target.z}
  end
  session.raceLanes[lane] = serialize(coords)
  return session.raceLanes[lane]
end

local function startRaceAI(entry, speed)
  local car = vehicle(entry.id)
  if not car then return end
  local style = entry.raceStyle or racecraft.style(entry.driver and entry.driver[1] or entry.number or entry.id)
  local lane = (entry.launchOffset or entry.lateral or 0) > 0 and 2 or 1
  entry.raceStyle, entry.raceLane, entry.raceBaseLane = style, lane, lane
  entry.raceWaiting, entry.raceMergeUntil = nil, nil
  local maximum = speed or raceSpeed * style.pace
  entry.raceTargetSpeed = maximum
  local first = firstRaceNode(entry.s + 2)
  local path = {}
  for step = 0, ovalSize do
    path[#path + 1] = "stockRaceOval" .. ((first + step - 1) % ovalSize + 1)
  end
  local aggression = clamp((session.track.aggression or 0.86) + style.aggression - 0.078, 0.35, 0.88)
  car:queueLuaCommand(string.format(
    'extensions.load("stockOvalAI"); extensions.stockOvalAI.start(%s,%s,%g,%g,%s)',
    raceLanePoints(lane), serialize(path), maximum, aggression, raceLanePoints(3 - lane)))
end

local function updateRacecraft()
  if session.launchUntil or session.elapsed < (session.racecraftAt or 0) then return end
  session.racecraftAt = session.elapsed + 0.34
  local field = {}
  for _, entry in ipairs(session.entries) do
    local car = vehicle(entry.id)
    if car and entry.s and not entry.inPit and (entry.offTrack or 0) < 9 then
      field[#field+1] = {entry=entry, car=car, id=entry.id, s=entry.s, speed=car:getVelocity():length(),
        lateral=entry.lateral, lane=not entry.out and entry.raceLane or nil, style=entry.raceStyle, waiting=entry.raceWaiting}
    end
  end
  local moveAvailable = true
  for _, observation in ipairs(field) do
    local entry, car = observation.entry, observation.car
    if observation.lane and (entry.id ~= session.playerId or session.allAI and not session.pitPlan) then
      local _, before = sample(entry.s - 12, 0)
      local _, after = sample(entry.s + math.max(24, observation.speed * 0.85), 0)
      observation.straight = before:dot(after) > 0.986
      local canMove = moveAvailable and session.elapsed >= (entry.raceMergeUntil or 0)
      local target, lane, waiting = racecraft.plan(observation, field, session.length, raceSpeed, session.elapsed, canMove)
      entry.raceWaiting = waiting
      if lane ~= entry.raceLane then
        local progress = wrap(entry.s + math.max(9, observation.speed * 0.42))
        car:queueLuaCommand(string.format('if extensions.stockOvalAI then extensions.stockOvalAI.changeLane(%d,%s,%g) end',
          firstRaceNode(progress), tostring(lane ~= entry.raceBaseLane), target))
        observation.lane, entry.raceLane, entry.raceTargetSpeed = lane, lane, target
        entry.raceMergeUntil = session.elapsed + 5
        moveAvailable = false
      elseif math.abs(target - entry.raceTargetSpeed) >= 0.75 then
        car:queueLuaCommand(string.format('if extensions.stockOvalAI then extensions.stockOvalAI.setTargetSpeed(%g) end', target))
        entry.raceTargetSpeed = target
      end
    end
  end
end

local function coolDownAI(entry)
  if entry.id == session.playerId and not session.allAI then return end
  if session.launchUntil then return startRaceAI(entry, paceSpeed) end
  vehicle(entry.id):queueLuaCommand(string.format('ai.setSpeedMode("limit"); ai.setSpeed(%g)', paceSpeed))
end

local function updateGreenLaunch()
  if not session.launchUntil then return end
  local elapsed = session.elapsed - session.phaseAt
  local launchSpeed = session.track.launchSpeed or raceSpeed
  for index, entry in ipairs(session.order) do
    local car = vehicle(entry.id)
    if car and not entry.out and (entry.id ~= session.playerId or session.allAI) and not (entry.id==session.playerId and session.pitPlan) then
      if session.elapsed >= session.launchUntil then
        startRaceAI(entry)
      else
        local offset = entry.launchOffset or (index % 2 == 1 and -1.9 or 1.9)
        local target = math.min(launchSpeed, paceSpeed + math.max(0,elapsed - math.floor((index-1)/2)*0.65)*2.2)
        local position = car:getPosition()
        local _, tangent = sample(entry.s,0)
        local right = vec3(tangent.y,-tangent.x,0)
        for _, other in ipairs(session.entries) do
          local ahead = other.id~=entry.id and vehicle(other.id)
          if ahead then
            local delta = ahead:getPosition()-position
            local gap = delta:dot(tangent)
            if gap>0 and gap<35 and math.abs(delta:dot(right))<2.7 then
              target=math.min(target,math.max(0,ahead:getVelocity():length()+(gap-11)*0.6))
            end
          end
        end
        formationControl(car,entry,offset,target)
      end
    end
  end
  if session.elapsed>=session.launchUntil then session.launchUntil=nil end
end

local function setPitLimiter(car, active)
  if not car then return end
  car:queueLuaCommand(string.format([[
    if controller.mainController.setTopSpeedLimitTemporary then
      controller.mainController.setTopSpeedLimitTemporary(%g)
      controller.mainController.setTopSpeedLimitTemporaryActive(%s)
    end
  ]], pitSpeed, tostring(active)))
end

function M.stop()
  if extensions and extensions.daytonaPaceCamera then extensions.daytonaPaceCamera.stop() end
  if not session then return end
  endCautionAssist()
  for _, id in ipairs(session.spawned) do
    local car = vehicle(id)
    if car then car:delete() end
  end
  local player = vehicle(session.playerId)
  if player then player:queueLuaCommand('if extensions.daytonaDamageHud then extensions.daytonaDamageHud.setEnabled(false) end') end
  if player and session.allAI then release(player) end
  setPitLimiter(player, false)
  session = nil
  blockResetActions(false)
  announce("Race control stopped.")
end

function M.start(count, laps, training)
  if session then return announce("Stop the current race session first.") end
  local profile = selectTrack()
  if not profile then return announce("Unsupported track. Choose an oval from Stock Car Career or Freeroam.") end
  if gameplay_missions_missionManager.getForegroundMissionId() then return announce("Exit the active mission before starting.") end
  local player = be:getPlayerVehicle(0)
  if not player or player:getJBeamFilename() ~= "cupgen7" then return announce("Select a BSC Gen 7 stock car first.") end
  if stockCarCount() ~= 1 then return announce("Begin with one Gen 7 stock car. Parked map props may remain.") end
  local oval = loadOval()
  local race = jsonReadFile(racePath)
  if not oval or not race or (not profile.surveyed and not race.startPositions) then
    return announce("Oval route unavailable for " .. profile.title .. ". Reload the map with the race-control route installed.")
  end
  if gameplay_traffic and gameplay_traffic.deleteVehicles then gameplay_traffic.deleteVehicles() end
  count = clamp(math.floor(tonumber(count) or 5), training and 0 or 1, math.min(13, (profile.gridCapacity or 14) - 1))
  session = oval
  session.level = getCurrentLevelIdentifier()
  session.track = profile
  session.entries = {}
  session.spawned = {}
  session.playerId = player:getId()
  session.elapsed = 0
  session.holdUntil = 4
  session.auto = true
  session.laps = clamp(math.floor(tonumber(laps) or 10), 2, 200)
  session.phaseAt = 0
  session.results = {}
  session.incidents = {}
  session.clearSince = 0
  session.pitPosition = vec3(pitBox)
  session.gridProgress = profile.gridAnchor and project(vec3(profile.gridAnchor)) or session.along[gridWaypoint]
  local grid = {}
  for index = 1, count + 1 do
    local row = math.floor((index - 1) / 2)
    local offset = index % 2 == 1 and -1.9 or 1.9
    local pos, dir = sample(session.gridProgress - row * rowGap, offset)
    if profile.surveyed and castRayStatic then
      local function pavementHeight(point)
        local origin = point + vec3(0, 0, 4)
        local distance = castRayStatic(origin, vec3(0, 0, -1), 8)
        return math.abs(distance - 4) <= 1.45 and origin.z - distance or nil
      end
      local height = pavementHeight(pos)
      local rowDistance = session.gridProgress - row * rowGap
      local supported = height ~= nil
      for _, fore in ipairs({-2.2, 2.2}) do
        for _, side in ipairs({-1.05, 1.05}) do
          local corner = sample(rowDistance + fore, offset + side)
          supported = supported and pavementHeight(corner) ~= nil
        end
      end
      if not supported then
        session = nil
        return announce(string.format("%s grid slot %d is off the surveyed pavement. Check the installed map version.", profile.shortName, index))
      end
      pos.z = height
    end
    local across = vec3(dir.y, -dir.x, 0):normalized()
    if session.bank then
      local left = sample(session.gridProgress - row * rowGap, -1.9)
      local right = sample(session.gridProgress - row * rowGap, 1.9)
      across = (right - left):normalized()
    end
    grid[index] = {position = pos + vec3(0, 0, 0.4), rotation = quatFromDir(dir, across:cross(dir):normalized())}
  end
  -- Always return the original car to its driver before staging a new grid.
  release(player)
  local fieldRoster = {}
  for i, driver in ipairs(broadcastRoster) do fieldRoster[i] = driver end
  local bundle = core_vehicle_manager and core_vehicle_manager.getVehicleData(player:getId())
  local parts = bundle and bundle.config and bundle.config.parts or {}
  for _, part in pairs(parts) do
    if type(part) == "string" then
      local number = tonumber(part:match("_scheme_%d+_(%d+)"))
      for i, driver in ipairs(fieldRoster) do
        if driver[1] == number then fieldRoster[1], fieldRoster[i] = fieldRoster[i], fieldRoster[1]; break end
      end
      if number then break end
    end
  end
  for index = 1, count + 1 do
    local slot = grid[index]
    local car = player
    if index > 1 then
      car = spawnCar("cupgen7", "drc_" .. profile.carConfig .. fieldRoster[index][1], slot.position, slot.rotation, profile.shortName .. " " .. index)
    end
    if not car then
      M.stop()
      return announce("Could not spawn the Gen 7 field. Check the expansion and vehicle limit.")
    end
    car:queueLuaCommand("mapmgr.requestMap()")
    local entry = {id = car:getId(), number = index, driver = fieldRoster[index]}
    updatePosition(entry, car)
    session.entries[index] = entry
  end
  spawn.safeTeleport(player, grid[1].position, grid[1].rotation)
  local leader = session.entries[1]
  leader.s = nil
  updatePosition(leader, player)
  if not paceCarAhead(leader) then
    M.stop()
    return announce("Could not spawn the pace car.")
  end
  prewarmServices()
  assignFormation("pace", session.entries)
  session.openingPace=true
  beginCautionAssist(true)
  if extensions and extensions.load then
    extensions.load("daytonaPaceCamera")
    if extensions.daytonaPaceCamera then extensions.daytonaPaceCamera.start(session.playerId, profile.surveyed and profile.raceSpeed < 45) end
  end
  blockResetActions(true)
  announce(string.format("%s | %d laps | %d cars. Follow the pace car two-wide. Green at the line.",
    profile.shortName, session.laps, #session.entries))
end

local function completedLaps(leader)
  return math.max(0, math.floor(leader.distance / session.length) - session.startLine)
end

function M.yellow()
  if not session or session.phase ~= "green" then return end
  local order = standings()
  local leader = order[1] or (session.incidents[session.playerId] and session.entries[1])
  if not leader then return end
  if session.startLine and completedLaps(leader) >= session.laps - 1 then
    -- The leader has reached the white flag under green. The next flag
    -- ends the race, and scoring freezes at the caution.
    session.results = order
    for _, entry in ipairs(order) do
      entry.finished = true
      coolDownAI(entry)
    end
    session.launchUntil = nil
    return finish("Finish under caution. Slow down and hold your line.")
  end
  if not paceCarAhead(leader) then
    if not session.paceUnavailable then announce("Could not deploy the pace car. Hold position.") end
    session.paceUnavailable = true
    return
  end
  session.paceUnavailable = nil
  assignFormation("yellow", order)
  announce(string.format("YELLOW. Slow to %d mph. Hold your position and form a single line.", math.floor(paceSpeed * 2.236936 + 0.5)))
end

local function armGreen()
  local pace = session.pace
  if not pace then return end
  local remaining = wrap(-pace.s)
  local minimum = session.phase == "pace" and session.length * 0.65 or math.min(260, session.length * 0.35)
  if remaining < minimum then remaining = remaining + session.length end
  session.greenTarget = {
    distance = pace.distance + remaining - 3,
    progress = pace.distance,
    movingAt = session.elapsed
  }
end

function M.restart()
  if not session or session.phase ~= "yellow" then return end
  if session.blocked or next(session.incidents) or session.response then
    return announce("Hold your position. The emergency crew is still clearing the track.")
  end
  session.phase = "restart"
  session.phaseAt = session.elapsed
  session.formedSince, session.formedAt = nil, nil
  armGreen()
  announce("ONE TO GREEN. Form two-wide in the frozen order. Odd positions inside.")
end

local function releaseGreen(automatic)
  if not session or (session.phase ~= "pace" and session.phase ~= "restart") then return end
  if session.blocked or next(session.incidents) or session.response then return announce("Track is still blocked.") end
  if not automatic and session.phase == "restart" and not session.formedAt then
    return announce("Hold your lane and close the gap before green.")
  end
  local leader = session.order[1] or standings()[1]
  if not leader then return end
  local restart = session.startLine ~= nil
  local greenLine = math.floor((leader.distance + 65) / session.length)
  if not restart then session.startLine = greenLine end
  if session.overtime then
    session.laps = greenLine - session.startLine + 2
    session.overtime = false
  end
  if extensions and extensions.daytonaPaceCamera then extensions.daytonaPaceCamera.stop() end
  session.openingPace=false
  if not session.pitPlan then endCautionAssist() end
  removePaceCar()
  local stages = session.stages
  if stages and stages.breakActive then
    -- Short races can consume their next stage boundary while lining up.
    -- Give the new stage at least one lap after the actual restart.
    local nextLap = greenLine - session.startLine + 1
    if stages.ends[stages.index] then
      stages.ends[stages.index] = math.max(stages.ends[stages.index], nextLap)
      session.laps = math.max(session.laps, stages.ends[stages.index] + 1)
    else
      session.laps = math.max(session.laps, nextLap)
    end
    stages.breakActive = false
  end
  session.phase = "green"
  session.phaseAt = session.elapsed
  session.manualPitApproach = nil
  session.greenTarget = nil
  session.launchUntil = session.elapsed + (session.track.launchSeconds or 8)

  for _, entry in ipairs(standings()) do
    entry.slow = 0
    entry.spinTime = 0
    local data = map.objects[entry.id]
    entry.lastDamage = data and (data.damage or 0) or 0
    if (entry.id ~= session.playerId or session.allAI) and not (entry.id==session.playerId and session.pitPlan) then
      release(vehicle(entry.id))
      entry.controlSignature = nil
      entry.launchOffset = entry.formationOffset or ((entry.number or 1)%2==1 and -1.9 or 1.9)
      vehicle(entry.id):queueLuaCommand(arcadeGearbox)
      formationControl(vehicle(entry.id),entry,entry.launchOffset,paceSpeed)
    end
  end
  announce(restart and "GREEN FLAG | Restart" or "GREEN FLAG | Lap 1")
end

function M.green()
  return releaseGreen(false)
end

function M.autoYellow(enabled)
  if not session then return end
  session.auto = enabled == true
  announce(session.auto and "Automatic cautions enabled." or "Manual cautions only.")
end

function M.status()
  if not session then return announce("No active race session.") end
  if session.phase == "finished" then return announce(session.summary) end
  if session.phase == "checkered" then
    for place, entry in ipairs(session.results) do
      if entry.id == session.playerId then
        return announce(string.format("CHECKERED | P%d of %d", place, #session.entries))
      end
    end
    return announce("CHECKERED | Cross the line to finish.")
  end
  local order = session.phase == "green" and standings() or session.order
  for index, entry in ipairs(order) do
    if entry.id == session.playerId then
      local lane = session.phase == "yellow" and "single file" or (index % 2 == 1 and "inside" or "outside")
      return announce(string.format("%s | Lap %d/%d | P%d of %d%s", session.phase:upper(),
        math.min(session.laps, (session.leaderLap or 0) + 1), session.laps, index, #session.entries,
        session.phase == "green" and "" or " | " .. lane))
    end
  end
  announce("Player car is out of the lineup.")
end

local function pitLocation(car)
  local pos = vec3(car:getPosition())
  local inBox = (pos - session.pitPosition):length() <= (session.track.manualPits and 2.5 or pitRadius)
  for index = 1, #pitRoute - 1 do
    local first, last = vec3(pitRoute[index]), vec3(pitRoute[index + 1])
    local delta = last - first
    local fraction = (pos - first):dot(delta) / delta:squaredLength()
    if fraction >= 0 and fraction <= 1 then
      local nearest = first + delta * fraction
      if math.abs(pos.z - nearest.z) < 5 and (pos - nearest):length() < session.track.pitWidth then
        return true, inBox
      end
    end
  end
  return inBox, inBox
end

function M.pitService(kind)
  if not session or session.phase == "finished" or session.phase == "checkered" then return end
  if kind ~= "repair" and kind ~= "fuel" and kind ~= "penalty" then return end
  if kind == "penalty" and not session.pitSpeedPenalty then return end
  local car = vehicle(session.playerId)
  if not car or session.resetPenalty or session.pitService then return end
  local _, inBox = pitLocation(car)
  if not inBox or car:getVelocity():length() >= 0.6 then
    return announce("Stop inside the marked pit box for service.")
  end
  local baseTime = kind == "repair" and 18 or (kind == "fuel" and 7 or 0)
  local serviceTime = baseTime + (session.pitSpeedPenalty and 5 or 0)
  session.pitService = {kind = kind, doneAt = session.elapsed + serviceTime}
  announce(kind == "repair" and "Pit crew repairing the car. Hold the brakes."
    or (kind == "fuel" and "Refueling. Hold the brakes." or "Serving black flag | Hold stopped for five seconds."))
end

local function playerTowIncident()
  if not session or session.phase ~= "yellow" or session.allAI or session.resetPenalty then return end
  return session.incidents[session.playerId]
end

function M.dismissTow()
  local incident = playerTowIncident()
  if incident and not session.playerWantsTow then incident.towDismissed = true end
end

function M.requestTow()
  if not playerTowIncident() or session.playerWantsTow then return end
  endCautionAssist()
  session.pitPlan = nil
  session.playerWantsTow = true
  announce("Tow requested. Stop and wait for the recovery crew.")
end

function M.cancelPit()
  if session and session.pitService then
    session.pitService = nil
    announce("Pit service canceled.")
  end
end

function M.requestPitRepair()
  if not session or session.phase~="yellow" or session.pitPlan or session.resetPenalty then return end
  if session.incidents[session.playerId] then return announce("Recover the car yourself or request a tow.") end
  if session.track.manualPits then
    if session.allAI then return end
    if session.blocked then return announce("Wait for the red flag to clear before entering pit road.") end
    endCautionAssist()
    session.manualPitApproach = true
    return announce("Drive to the marked pit box and stop for service.")
  end
  local entry=session.entries[1]
  local car=vehicle(session.playerId)
  if not car then return end
  local inPit=pitLocation(car)
  session.pitPlan={phase=inPit and "driving" or "queued",node=1,stops=session.pitStops or 0,requestedAt=session.elapsed}
  beginCautionAssist()
  announce(session.blocked and "Pit repair queued. AI waits for red to clear." or "Pit repair requested. AI will enter pit road and stop at your box.")
end

local function updateAIPitPlan()
  local plan=session.pitPlan
  if not plan then return end
  local entry=session.entries[1]
  local car=vehicle(session.playerId)
  if not car then session.pitPlan=nil;return end
  if session.blocked then formationControl(car,entry,0,0);return end
  local inPit,inBox=pitLocation(car)
  if plan.phase=="queued" then
    local entrance=project(vec3(pitRoute[1]))
    local remaining=distanceAhead(entry.s,entrance)
    if not inPit and remaining>55 then
      if session.phase=="green" then formationControl(car,entry,0,paceSpeed) end
      return
    end
    plan.phase="driving"
    release(car);entry.controlSignature=nil
    car:queueLuaCommand(arcadeGearbox)
    if inPit then
      local nearest,best=1,math.huge
      for i,point in ipairs(pitRoute) do local d=(car:getPosition()-vec3(point)):squaredLength();if d<best then best=d;nearest=i end end
      plan.node=nearest
    end
    announce("AI entering pit road. Repairs at your marked box.")
  end
  if plan.phase=="servicing" then
    formationControl(car,entry,0,0)
    if not session.pitService and (session.pitStops or 0)>plan.stops then
      session.pitPlan=nil;endCautionAssist();announce("Repairs complete. You have control. Check traffic before pit exit.")
    elseif not session.pitService and inBox and car:getVelocity():length()<0.6 then M.pitService("repair") end
    return
  end
  if inBox and car:getVelocity():length()<0.6 then
    formationControl(car,entry,0,0)
    M.pitService("repair")
    if session.pitService then plan.phase="servicing" end
    return
  end
  local point=vec3(pitRoute[plan.node] or session.pitPosition)
  local toBox=(point-session.pitPosition):length()<18
  if not toBox and (point-car:getPosition()):length()<14 then plan.node=plan.node+1;point=vec3(pitRoute[plan.node] or session.pitPosition) end
  -- Stop at the box rather than following pit exit nodes beyond it.
  if plan.node>=#pitRoute or (point-session.pitPosition):length()<18 then point=session.pitPosition;toBox=true end
  local distance=(point-car:getPosition()):length()
  local speed=math.min(pitSpeed*0.7,12,toBox and math.max(0,(distance-1.5)*0.65) or 12)
  if toBox and inBox then speed=0 end
  formationControl(car,entry,0,speed,point)
end

local function addToTail(entry)
  if session.phase == "yellow" or session.phase == "restart" or session.phase == "pace" then
    session.order[#session.order + 1] = entry
    session.formedSince, session.formedAt = nil, nil
  end
end

local function updatePit(entry, car)
  local inPit, inBox = pitLocation(car)
  if inPit ~= entry.inPit then
    if inPit then
      if not session.pitPlan then endCautionAssist() end
      session.manualPitApproach, session.playerWantsTow = nil, nil
      session.incidents[entry.id] = nil
      for index, racer in ipairs(session.order) do
        if racer.id == entry.id then table.remove(session.order, index); break end
      end
      session.formedSince, session.formedAt = nil, nil
    elseif entry.inPit and not entry.out then
      addToTail(entry)
      if session.phase == "yellow" or session.phase == "restart" then
        announce("Pit exit | Join the back of the field.")
      end
    end
    entry.inPit = inPit
    setPitLimiter(car, inPit)
    session.limiterActive = inPit
    if not inPit then entry.pitViolationThisVisit = nil end
  end
  local speed = car:getVelocity():length()
  if inPit and speed > pitSpeed + 0.5 then
    if not entry.pitViolationThisVisit then
      entry.pitViolationThisVisit = true
      session.pitSpeedPenalty = true
      announce("BLACK FLAG | Pit speed violation. Serve a five-second stop in your pit box.")
    end
    -- Enforce the cap immediately at entry, including when coasting or braking downhill.
    car:applyClusterVelocityScaleAdd(car:getRefNodeId(), pitSpeed / speed, 0, 0, 0)
  end
  local service = session.pitService
  if not service then return end
  if not inBox or speed >= 0.6 then return M.cancelPit() end
  if session.elapsed < service.doneAt then return end

  session.pitService = nil
  session.pitSpeedPenalty = nil
  if service.kind == "repair" then
    session.pitResetUntil = session.elapsed + 2
    local pos = car:getPosition()
    local rot = quatFromDir(vec3(car:getDirectionVector()), vec3(0, 0, 1))
    spawn.safeTeleport(car, pos, rot)
    setPitLimiter(car, true)
    if not session.resetPenalty then
      entry.out = false
      session.playerAwaitingRepair = nil
      entry.slow = 0
      session.incidents[entry.id] = nil
      session.clearSince = session.elapsed
    end
  elseif service.kind == "fuel" then
    car:queueLuaCommand([[for _, tank in pairs(energyStorage.getStorages()) do
      if tank.type == "fuelTank" then tank:setRemainingRatio(1) end
    end]])
  end
  session.pitStops = (session.pitStops or 0) + 1
  announce(service.kind == "repair" and "Repairs complete. Check traffic on pit exit."
    or (service.kind == "fuel" and "Refueling complete." or "Black flag cleared | Penalty served."))
end

local function onVehicleResetted(id)
  if not session or id ~= session.playerId or not session.phase or session.phase == "finished" then return end
  if session.elapsed < 2 or session.elapsed <= (session.pitResetUntil or -1) then return end
  if session.resetPenalty then return end
  session.resetPenalty = true
  session.playerWantsTow = nil
  session.playerAwaitingRepair = nil
  local entry = session.entries[1]
  entry.out = true
  session.incidents[id] = nil
  session.clearSince = session.elapsed
  for index, racer in ipairs(session.order) do
    if racer.id == id then table.remove(session.order, index); break end
  end
  session.formedSince, session.formedAt = nil, nil
  M.cancelPit()
  announce("DNF | Repairs during a race must be done by your pit crew.")
end

function M.hudState()
  local state = {
    build = M.build,
    available = trackProfiles[getCurrentLevelIdentifier()] ~= nil,
    trackName = trackProfiles[getCurrentLevelIdentifier()] and trackProfiles[getCurrentLevelIdentifier()].title,
    level = getCurrentLevelIdentifier(),
    unsupportedReason = "Load an oval from the Stock Car Career calendar.",
    phase = "idle",
    notice = notice and uiClock - notice.at < 6 and notice or nil
  }
  local player = be:getPlayerVehicle(0)
  state.ready = state.available and player and player:getJBeamFilename() == "cupgen7"
    and not gameplay_missions_missionManager.getForegroundMissionId()
    and (session ~= nil or stockCarCount() == 1) or false
  if not session then return state end
  state.phase = session.phase
  state.laps = session.laps
  local stages = session.stages
  if stages then
    state.stage = stages.index
    state.stageEnd = stages.ends[stages.index] or session.laps
    state.stageWinner = stages.winner
    state.stageBreak = stages.breakActive == true
    state.stagePoints = stages.points[session.playerId] or 0
  end
  state.lap = math.min(session.laps, (session.leaderLap or 0) + 1)
  state.field = #session.entries
  state.result = session.summary
  state.blocked = session.blocked == true
  state.responding = session.response ~= nil or next(session.incidents) ~= nil
  state.formed = session.formedAt ~= nil
  local playerIncident = session.incidents[session.playerId]
  state.canTow = playerTowIncident() ~= nil
  state.towPending = session.playerWantsTow == true
  state.towOffer = state.canTow and not state.towPending and not playerIncident.towDismissed and playerIncident.reason or nil
  state.manualPits = session.track.manualPits == true
  state.canRequestPitRepair = session.phase=="yellow" and not session.pitPlan and not session.resetPenalty
    and not playerIncident and (not state.manualPits or session.cautionAssist and not session.allAI)
  state.pitRepairRequested = session.pitPlan~=nil
  state.pitPlanPhase = session.pitPlan and session.pitPlan.phase or nil
  state.cautionAssist = session.cautionAssist == true
  state.playerManualCaution = not state.cautionAssist and not session.allAI and not playerIncident
    and (session.phase == "yellow" or session.phase == "restart") and not state.towPending
    and not session.entries[1].inPit and not session.manualPitApproach and not session.pitPlan
  state.openingPace = session.openingPace == true
  state.cameraShot = extensions and extensions.daytonaPaceCamera and extensions.daytonaPaceCamera.getShot() or nil
  if (session.phase == "restart" or session.phase == "pace") and session.greenTarget and session.pace and not session.blocked then
    local seconds = (session.greenTarget.distance - session.pace.distance) / math.max(session.targetPace or paceSpeed, 1)
    if seconds >= 0 and seconds <= 3 then state.restartCountdown = math.ceil(seconds) end
  end
  state.allAI = session.allAI == true
  state.stagedIncidents = session.stagedIncidents == true
  state.stagedCount = session.stagedCount or 0
  state.launchActive = session.launchUntil ~= nil
  state.lastStagedIncident = session.lastStagedIncident
  state.incidentTargets = {}
  for place, entry in ipairs(standings()) do
    if entry.id ~= session.playerId and not entry.finished and not entry.stagedFailure then
      state.incidentTargets[#state.incidentTargets + 1] = {id = entry.id, label = "P" .. place .. " · Car " .. entry.id}
    end
  end
  state.canStageIncident = session.phase == "green" and not session.blocked and not next(session.incidents)
  state.paceMph = math.floor((session.targetPace or 0) * 2.23694 + 0.5)
  state.slotGap = session.playerGap
  local playerCar = vehicle(session.playerId)
  if playerCar then
    state.inPit, state.inBox = pitLocation(playerCar)
    state.pitReady = state.inBox and playerCar:getVelocity():length() < 0.6 and not session.resetPenalty
    state.pitStops = session.pitStops or 0
    state.pitPenalty = session.pitSpeedPenalty == true
    state.resetPenalty = session.resetPenalty == true
    state.blackFlag = session.resetPenalty == true or session.pitSpeedPenalty == true
    state.blackFlagReason = session.resetPenalty and "Illegal repair · DNF"
      or (session.pitSpeedPenalty and "Pit speeding · Serve 5 seconds in your pit box" or nil)
    state.pitLimiter = state.inPit == true
    state.pitLimitMph = session.track.pitLimitMph
    if session.pitService then
      state.pitCountdown = math.ceil(session.pitService.doneAt - session.elapsed)
    end
  end
  local raceOrder = displayOrder()
  state.broadcast = {}
  state.raceClock = session.elapsed
  local leader=raceOrder[1]
  for place,entry in ipairs(raceOrder) do
    local driver=entry.driver or broadcastRoster[(entry.number or place)] or {entry.number or place,"Driver","DRIVER","#999999"}
    local mark=entry.timingCheckpoint
    local interval=leader and mark and entry.crossings and leader.crossings and entry.crossings[mark] and leader.crossings[mark] and math.max(0,entry.crossings[mark]-leader.crossings[mark]) or nil
    local lapsDown=leader and math.max(0,math.floor(((leader.distance or 0)-(entry.distance or 0))/session.length)) or 0
    state.broadcast[#state.broadcast+1]={id=entry.id,position=place,number=driver[1],name=driver[2],shortName=driver[3],color=driver[4],player=entry.id==session.playerId,interval=place==1 and 0 or interval,lapsDown=lapsDown,lastLap=entry.lastLap,bestLap=entry.bestLap}
    if entry.id==session.playerId then
      state.driverName,state.carNumber=driver[2],driver[1]
      state.currentLapTime=entry.lapStartedAt and session.elapsed-entry.lapStartedAt or nil
      state.lastLap,state.bestLap=entry.lastLap,entry.bestLap
    end
  end
  state.running = #raceOrder
  state.relative = {}
  local playerRank
  for place, entry in ipairs(raceOrder) do if entry.id == session.playerId then playerRank = place end end
  if playerRank then
    local pe = raceOrder[playerRank]
    local speed = playerCar and playerCar:getVelocity():length() or 0
    for place = math.max(1, playerRank - 2), math.min(#raceOrder, playerRank + 2) do
      local e = raceOrder[place]
      local gap = (pe.distance or 0) - (e.distance or 0)
      state.relative[#state.relative + 1] = {position=place, number=e.number or place,
        player=e.id==session.playerId, gap=math.abs(gap), interval=math.abs(gap)/math.max(speed,10)}
    end
    local left, right = false, false
    for _, e in ipairs(raceOrder) do
      local delta = wrap((e.s or 0) - (pe.s or 0) + session.length*0.5) - session.length*0.5
      local lateral = (e.lateral or 0) - (pe.lateral or 0)
      if e.id~=pe.id and math.abs(delta)<7 then
        left = left or (lateral < -1.3 and lateral > -7)
        right = right or (lateral > 1.3 and lateral < 7)
      end
    end
    state.spotter = left and right and "THREE WIDE - HOLD YOUR LINE" or left and "CAR INSIDE" or right and "CAR OUTSIDE" or "CLEAR"
  end
  state.controlOwner = "PLAYER"
  if session.cautionAssist or session.allAI then state.controlOwner = "AI" end
  state.gridLocation = session.track.gridLabel or "Pit entrance - Turn 4"
  state.position = playerRank
  if playerRank and (session.phase == "yellow" or session.phase == "pace" or session.phase == "restart") then
    local singleFile = session.phase == "yellow"
    state.row = singleFile and playerRank or math.floor((playerRank - 1) / 2) + 1
    local follow = raceOrder[playerRank - (singleFile and 1 or 2)]
    state.followNumber = follow and follow.driver and follow.driver[1] or nil
    state.lane = singleFile and "Single file" or (playerRank % 2 == 1 and "Inside" or "Outside")
  end
  return state
end

function M.setDamagePopups(enabled)
  for _,car in ipairs(getAllVehicles()) do
    car:queueLuaCommand('if extensions.daytonaDamageHud then extensions.daytonaDamageHud.setEnabled(false) end')
  end
  local car=be:getPlayerVehicle(0)
  if enabled and session and car then
    car:queueLuaCommand('extensions.load("daytonaDamageHud");extensions.daytonaDamageHud.setEnabled(true);damageTracker.sendNow()')
  end
end

function M.publishHud()
  guihooks.trigger("DaytonaRaceControlState", M.hudState())
end

function M.startFromHud(opponents, laps, allAI, stagedIncidents, stages)
  if session and session.phase == "finished" then M.stop() end
  if session then return announce("Stop the current race session first.") end
  M.start(opponents, laps)
  if not session then return end
  if stages == true and session.laps >= 6 then
    local fraction = session.track.stageFraction or (session.track.shortName == "MARTINSVILLE" and 0.26 or 0.325)
    session.stages = {
      index = 1,
      ends = {math.floor(session.laps * fraction + 0.5), math.floor(session.laps * fraction * 2 + 0.5)},
      points = {},
      results = {}
    }
  end
  session.allAI = allAI == true
  if session.allAI then
    local car = vehicle(session.playerId)
    release(car)
    car:queueLuaCommand(arcadeGearbox)
  end
  session.stagedIncidents = stagedIncidents == true
  session.stagedCount = 0
  session.greenRunningTime = 0
  session.nextStagedAt = 45
end

function M.setStagedIncidents(enabled)
  if not session then return end
  session.stagedIncidents = enabled == true
  session.nextStagedAt = (session.greenRunningTime or 0) + 45
end

function M.stageIncident(kind, targetId)
  if not session or session.phase ~= "green" or next(session.incidents) or session.blocked then
    return announce("Wait for a clear green track before staging an incident.")
  end
  if kind ~= "tire" and kind ~= "spin" and kind ~= "engine" then return end
  local candidates = {}
  for _, entry in ipairs(standings()) do
    local car = vehicle(entry.id)
    if entry.id ~= session.playerId and not entry.finished and not entry.stagedFailure
      and not entry.inPit and entry.offTrack < 18 and car and car:getVelocity():length() >= 15
      and (not targetId or entry.id == targetId) then
      candidates[#candidates + 1] = entry
    end
  end
  if #candidates == 0 then return announce("Wait for an eligible AI car to reach racing speed.") end
  local entry = candidates[math.random(#candidates)]
  local car = vehicle(entry.id)
  entry.stagedFailure = kind
  entry.hazardUntil = session.elapsed + 4
  if kind == "tire" then
    car:queueLuaCommand([[for id, wheel in pairs(wheels.wheels) do
      if wheel.name == "RR" then beamstate.deflateTire(id); break end
    end]])
    entry.hazardReason = "Staged right-rear tire blowout"
  elseif kind == "engine" then
    car:queueLuaCommand([[local engine = powertrain.getDevice("mainEngine")
      if engine then engine:lockUp(); damageTracker.setDamage("engine", "engineLockedUp", true) end]])
    entry.hazardReason = "Staged engine failure"
  else
    release(car)
    local heading = vec3(car:getDirectionVector())
    local lateral = heading:cross(vec3(car:getDirectionVectorUp())) * 8
    car:applyClusterVelocityScaleAdd(car:getRefNodeId(), 1, lateral.x, lateral.y, lateral.z)
    car:queueLuaCommand([[input.event("steering", 0.85, "FILTER_AI", nil, nil, nil, "ai")
      input.event("parkingbrake", 1, "FILTER_AI", nil, nil, nil, "ai")]])
    entry.spinUntil = session.elapsed + 1.2
    entry.hazardReason = "Staged spin"
  end
  session.stagedCount = (session.stagedCount or 0) + 1
  session.lastStagedIncident = entry.hazardReason .. " · Car " .. entry.id
  session.nextStagedAt = (session.greenRunningTime or 0) + 90 + math.random(60)
  announce(session.lastStagedIncident)
  return true
end

local function updateStagedIncidents(dt)
  for _, entry in ipairs(session.entries) do
    if entry.spinUntil and session.elapsed >= entry.spinUntil then
      entry.spinUntil = nil
      local car = vehicle(entry.id)
      if car then
        release(car)
        if session.phase == "green" and not entry.out then startRaceAI(entry) end
      end
    end
  end
  if session.phase ~= "green" then return end
  session.greenRunningTime = (session.greenRunningTime or 0) + dt
  if session.stagedIncidents and (session.stagedCount or 0) < 3
    and session.greenRunningTime >= (session.nextStagedAt or 45) and not next(session.incidents) then
    local kinds = {"tire", "spin", "engine"}
    if not M.stageIncident(kinds[math.random(#kinds)]) then
      session.nextStagedAt = session.greenRunningTime + 10
    end
  end
end

local careerPath = "settings/stockCarCareer.json"
local calendar = {
  {level = "daytonaspeedway", laps = 10},
  {level = "lonestar_speedway", laps = 10},
  {level = "martinsville", laps = 20},
  {level = "bristolmotorspeedway", laps = 20},
  {level = "tbd_newport_speedway_oval", laps = 20},
  {level = "phoenix", laps = 20}
}
local career, careerLaunch

local function careerData()
  if not career then
    local saved = jsonReadFile(careerPath)
    career = type(saved) == "table" and saved.version == 1 and saved or
      {version = 1, round = 1, credits = 0, events = {}, training = {}}
  end
  return career
end

function M.careerState()
  local data = careerData()
  local rounds = {}
  for i, event in ipairs(calendar) do
    rounds[i] = {track = trackProfiles[event.level].title, laps = event.laps, result = data.events[tostring(i)]}
  end
  return {round = data.round, credits = data.credits, sponsor = data.sponsor,
    sponsorAvailable = next(data.training) ~= nil, rounds = rounds, busy = careerLaunch ~= nil or session ~= nil}
end

function M.signCareerSponsor()
  local data = careerData()
  if next(data.training) and not data.sponsor and not session and not careerLaunch then
    data.sponsor = "Apex Toolworks"
    jsonWriteFile(careerPath, data, true)
  end
  return M.careerState()
end

function M.launchCareer(training)
  local data = careerData()
  if session or careerLaunch then return "A session is already active." end
  local event = calendar[data.round]
  if not event then return "Season complete." end
  careerLaunch = {event = event, round = data.round, training = training == true, wait = 0}
  if getCurrentLevelIdentifier() ~= event.level then
    if not core_levels.getLevelByName(event.level) then
      careerLaunch = nil
      return "Install the map for this round first."
    end
    local profile = trackProfiles[event.level]
    freeroam_freeroamConfigurator.startFreeroam({
      levelName = event.level,
      vehicle = {model = "cupgen7", config = "vehicles/cupgen7/drc_" .. profile.carConfig .. "24.pc"}
    })
  end
  return ""
end

local function updateCareerLaunch(dt)
  local launch = careerLaunch
  if not launch or getCurrentLevelIdentifier() ~= launch.event.level then return end
  local player = be:getPlayerVehicle(0)
  if not player or gameplay_missions_missionManager.getForegroundMissionId() then return end
  launch.wait = launch.wait + dt
  if launch.wait < 2 then return end
  if player:getJBeamFilename() ~= "cupgen7" then
    local profile = trackProfiles[launch.event.level]
    if not launch.replaced then
      launch.replaced = true
      core_vehicles.replaceVehicle("cupgen7", {config = "vehicles/cupgen7/drc_" .. profile.carConfig .. "24.pc"})
    elseif launch.wait > 15 then
      careerLaunch = nil
      announce("Select a Gen 7 car and return to the career board.")
    end
    return
  end
  careerLaunch = nil
  if launch.training then
    M.start(0, 2, true)
  else
    M.startFromHud(7, launch.event.laps, false, false, true)
  end
  if session then session.career = launch end
end

local function recordCareerResult(place)
  local launch = session.career
  if not launch then return end
  local data = careerData()
  if launch.training then
    if place then data.training[launch.event.level] = true end
  elseif data.round == launch.round then
    local payout = place and (500 + (place <= 5 and data.sponsor and 250 or 0)) or 0
    data.credits = data.credits + payout
    data.events[tostring(launch.round)] = {place = place or 0, credits = payout}
    data.round = data.round + 1
  end
  jsonWriteFile(careerPath, data, true)
end

finish = function(finalNotice)
  endCautionAssist()
  session.phase = "finished"
  local player = vehicle(session.playerId)
  if player then player:queueLuaCommand('if extensions.daytonaDamageHud then extensions.daytonaDamageHud.setEnabled(false) end') end
  if player and session.allAI and not session.entries[1].finished then release(player) end
  blockResetActions(false)
  local playerPlace
  for place, entry in ipairs(session.results) do
    if entry.id == session.playerId then playerPlace = place; break end
  end
  recordCareerResult(playerPlace)
  local result = playerPlace and string.format("P%d of %d", playerPlace, #session.entries) or "DNF"
  session.summary = string.format("%s RESULT | %s | %d laps", session.track.shortName, result, session.laps)
  removePaceCar()
  announce(session.summary .. " | " .. (finalNotice or "Press Ctrl+Alt+F6 to race again."))
end

local function scoreCheckered(running)
  local finishLine = (session.startLine + session.laps) * session.length
  for _, entry in ipairs(running) do
    if not entry.finished and entry.distance >= finishLine then
      entry.finished = true
      session.results[#session.results + 1] = entry
      coolDownAI(entry)
    end
  end
  if #session.results >= #running or session.elapsed - session.phaseAt >= 105 then finish() end
end

local function scoreRace()
  if not session.startLine or session.phase == "finished" then return end
  local running = standings()
  if session.phase == "checkered" then return scoreCheckered(running) end
  local leader = running[1]
  if not leader then
    if session.incidents[session.playerId] or session.playerAwaitingRepair then return end
    return finish()
  end
  local complete = completedLaps(leader)
  local stages = session.stages
  if stages and stages.breakActive then
    session.leaderLap = math.max(session.leaderLap or 0, complete)
    return
  end
  if stages and stages.ends[stages.index] and complete >= stages.ends[stages.index] then
    if session.phase == "green" then
      M.yellow()
      if session.phase ~= "yellow" then return end
    end
    local result = {}
    for place = 1, math.min(10, #running) do
      local entry = running[place]
      local points = 11 - place
      stages.points[entry.id] = (stages.points[entry.id] or 0) + points
      result[place] = {id = entry.id, points = points}
    end
    stages.results[stages.index] = result
    stages.winner = leader.driver and leader.driver[3] or "LEADER"
    stages.index = stages.index + 1
    stages.breakActive = true
    session.leaderLap = math.max(session.leaderLap or 0, complete)
    announce(string.format("STAGE %d COMPLETE | %s WINS", stages.index - 1, stages.winner))
    return
  end
  if complete >= session.laps then
    if session.phase == "green" then
      session.phase, session.phaseAt = "checkered", session.elapsed
      announce("CHECKERED FLAG | Race to the line for your finishing position.")
      return scoreCheckered(running)
    end
    if not session.overtime then
      session.overtime = true
      announce("OVERTIME | Two laps after the restart.")
    end
    return
  end
  if complete > (session.leaderLap or 0) then
    session.leaderLap = complete
    if complete == session.laps - 1 and session.phase == "green" then
      announce("WHITE FLAG | Final lap")
    else
      announce(string.format("%s | Lap %d/%d", session.track.shortName, complete + 1, session.laps))
    end
  end
end

function M.toggle()
  if session then
    if session.phase ~= "finished" then return M.stop() end
    M.stop()
  end
  M.start(7, 10)
end

local function updateRedFlag()
  if incidentStatus() then
    if not session.blocked then
      session.blocked = true
      session.formedSince, session.formedAt = nil, nil
      announce("RED FLAG | Track blocked. Stop behind the pace car.")
    end
    session.redClearSince = nil
  elseif session.blocked then
    session.redClearSince = session.redClearSince or session.elapsed
    if session.elapsed - session.redClearSince >= redClearHold then
      session.blocked = false
      session.redClearSince = nil
      session.phaseAt = session.elapsed
      session.clearSince = session.elapsed
      session.formedSince, session.formedAt = nil, nil
      announce("YELLOW FLAG | Track clear. Roll single-file behind the pace car.")
    end
  end
end

local function advancePaceLap()
  if not session.greenTarget then armGreen() end
  local pace, target = session.pace, session.greenTarget
  if not pace or not target or not vehicle(pace.id) then return releaseGreen(true) end
  if pace.distance > target.progress + 8 then
    target.progress = pace.distance
    target.movingAt = session.elapsed
  end
  local compactRestart = compactOval() and session.phase == "restart"
  local canRestart = true
  if compactRestart then
    local leader = session.order[1]
    local leaderCar = leader and vehicle(leader.id)
    local paceCar = vehicle(pace.id)
    local gap = leader and wrap(pace.s - leader.s) or 0
    canRestart = leaderCar and paceCar and gap >= 7 and gap <= headGap + 28
      and leaderCar:getVelocity():length() >= 2.5 and paceCar:getVelocity():length() >= 2.5
  end
  if pace.distance >= target.distance then
    if canRestart then return releaseGreen(true) end
    armGreen()
  elseif session.elapsed - target.movingAt >= paceStallLimit or session.elapsed - session.phaseAt >= paceTimeLimit then
    if compactRestart then
      session.phase = "yellow"
      session.phaseAt, session.clearSince = session.elapsed, session.elapsed
      session.greenTarget, session.formedAt, session.formedSince = nil, nil, nil
      return announce("Restart waved off. Catch the pace car and hold your line.")
    end
    announce("Pace car unable to complete the lap. Releasing the field.")
    releaseGreen(true)
  end
end

function M.reportVehicleState(id, engineDisabled, throttle)
  if not session then return end
  for _, entry in ipairs(session.entries) do
    if entry.id == id then
      entry.engineDisabled, entry.reportedThrottle = engineDisabled == true, tonumber(throttle) or 0
      return
    end
  end
end

local function updateIncident(entry, car, dt)
  local isPlayer = entry.id == session.playerId
  local towAccepted = isPlayer and session.playerWantsTow
  local velocity = vec3(car:getVelocity())
  local speed = velocity:length()
  local data = map.objects[entry.id]
  local damage = data and (data.damage or 0) or 0
  local hit = entry.lastDamage and damage - entry.lastDamage or 0
  entry.lastDamage = damage
  local overturned = car:getDirectionVectorUp().z < 0.45
  local plannedStop = session.phase ~= "green" and entry.controlTargetSpeed ~= nil and entry.controlTargetSpeed < 0.5 and not session.incidents[entry.id]
  if speed < 4 and session.elapsed >= (entry.nextHealthAt or 0) then
    entry.nextHealthAt = session.elapsed + 1
    car:queueLuaCommand([[local engine = powertrain.getDevice("mainEngine")
      obj:queueGameEngineLua("extensions.daytonaRaceControl.reportVehicleState(" .. obj:getID() .. "," ..
        tostring(engine and (engine.isDisabled or engine.isBroken) or false) .. "," .. tostring(electrics.values.throttle or 0) .. ")")]])
  end
  local attempting = session.phase == "green" and (entry.reportedThrottle or 0) > 0.4
    or session.phase ~= "green" and (entry.commandedThrottle or 0) > 0.4 and (entry.controlTargetSpeed or 0) >= 3
  entry.driveStall = speed < 1 and damage > 1500 and attempting and not plannedStop and ((entry.driveStall or 0) + dt) or 0
  local disabled = speed < 4 and (entry.engineDisabled == true or (entry.driveStall > 30 and not entry.recovery) or overturned
    or entry.stagedFailure == "tire" or entry.stagedFailure == "engine")

  local _, tangent = sample(entry.s, 0)
  local heading = vec3(car:getDirectionVector())
  local alignment = heading:dot(tangent)
  local progress = velocity:dot(tangent)
  local spinning = speed > 4 and (alignment < 0.48 or progress < speed * 0.42)
  local sidewaysStopped = speed <= 4 and alignment < 0.55
  entry.spinTime = spinning and ((entry.spinTime or 0) + dt) or 0
  entry.sidewaysTime = sidewaysStopped and speed < 1 and ((entry.sidewaysTime or 0) + dt) or 0
  if entry.recoveryFailed then disabled = true end
  entry.slow = disabled and ((entry.slow or 0) + dt) or 0

  -- The AI route is near the middle of the oval. Include the uphill outside lane.
  local onSurface = not entry.inPit and math.abs(entry.lateral) <= 18 and entry.offTrack <= 25
  local issue = session.incidents[entry.id]
  if not onSurface and not (towAccepted and issue) then
    if issue then
      session.incidents[entry.id] = nil
      session.clearSince = session.elapsed
    end
    return false
  end

  if not issue and (entry.finished or (entry.out and entry.id ~= session.playerId)) then return false end
  local reason
  if entry.slow > 1.5 then reason = "Disabled car"
  elseif overturned then reason = "Overturned car"
  elseif hit >= 450 then reason = "Collision"
  elseif entry.spinTime >= 0.30 then reason = "Spin on the racing surface"
  elseif entry.hazardUntil and session.elapsed < entry.hazardUntil then reason = entry.hazardReason end

  local newIncident = not issue and reason ~= nil
  if newIncident then
    issue = {id = entry.id, detectedAt = session.elapsed, reason = reason}
    session.incidents[entry.id] = issue
    if isPlayer and not session.allAI then
      endCautionAssist()
      session.pitPlan, session.manualPitApproach = nil, nil
    end
    announce(reason .. " | Car " .. entry.id)
  end
  if not issue then return false end

  if entry.slow > 1.5 then
    if not issue.disabled then
      issue.reason, issue.towDismissed = "Disabled car", nil
      if isPlayer and not session.allAI then endCautionAssist() end
    end
    issue.disabled = true
    if not entry.out then
      entry.out = true
      if entry.id ~= session.playerId then release(car) end
    end
  end
  if not reason and not spinning and not sidewaysStopped and not disabled and not towAccepted then
    issue.clearAt = issue.clearAt or math.max(session.elapsed + 2, isPlayer and issue.detectedAt + 6 or 0)
    if session.elapsed >= issue.clearAt and (not issue.disabled or entry.id == session.playerId) then
      session.incidents[entry.id] = nil
      session.clearSince = session.elapsed
      if isPlayer and issue.disabled and entry.out and not session.resetPenalty then
        -- A driver who got the car running can rejoin at the back.
        entry.out = false
        addToTail(entry)
      end
      return false
    end
  else
    issue.clearAt = nil
  end
  local across = math.abs(heading:dot(vec3(tangent.y, -tangent.x, 0)))
  issue.s, issue.lateral, issue.width = entry.s, entry.lateral, 1.2 + 1.65 * across
  return newIncident
end

local function onUpdate(dtReal, dtSim)
  uiClock = uiClock + ((dtReal and dtReal > 0) and dtReal or math.max(dtSim or 0, 0))
  if dtSim > 0 then updateCareerLaunch(dtSim) end
  if not session or dtSim <= 0 then return end
  if getCurrentLevelIdentifier() ~= session.level or not vehicle(session.playerId) then M.stop(); return end
  if session.phase == "finished" then
    if session.limiterActive then
      setPitLimiter(vehicle(session.playerId), false)
      session.limiterActive = false
    end
    return
  end
  local currentCar = vehicle(session.playerId)
  if debugDrawer and currentCar and not session.openingPace and (currentCar:getPosition() - session.pitPosition):squaredLength() < 180 * 180 then
    debugDrawer:drawTextAdvanced(session.pitPosition + vec3(0, 0, 1.7), session.track.shortName .. " PIT BOX",
      ColorF(1, 0.78, 0.22, 1), true, false, ColorI(15, 20, 28, 220))
  end
  session.tick = (session.tick or 0) + dtSim
  if session.tick < 0.05 then return end
  local dt = session.tick
  session.tick = 0
  session.elapsed = session.elapsed + dt
  updateStagedIncidents(dt)
  local newIncident = false
  for _, entry in ipairs(session.entries) do
    local car = vehicle(entry.id)
    if car then
      local previousDistance = entry.distance
      updatePosition(entry, car)
      if session.startLine then
        local timingLap=math.floor(entry.distance/session.length)
        if entry.timingLap and timingLap>entry.timingLap then
          if entry.lapStartedAt then
            entry.lastLap=session.elapsed-entry.lapStartedAt
            if not entry.lapHadCaution then entry.bestLap=math.min(entry.bestLap or math.huge,entry.lastLap) end
          end
          entry.lapStartedAt=session.elapsed;entry.lapHadCaution=false
        end
        entry.timingLap=timingLap
        if session.phase~="green" then entry.lapHadCaution=true end
        local checkpoint=math.floor(entry.distance/100)
        if entry.timingCheckpoint and checkpoint>entry.timingCheckpoint and checkpoint-entry.timingCheckpoint<4 then
          entry.crossings=entry.crossings or {}
          for mark=entry.timingCheckpoint+1,checkpoint do
            local fraction=previousDistance and clamp((entry.distance-mark*100)/math.max(entry.distance-previousDistance,0.001),0,1) or 0
            entry.crossings[mark]=session.elapsed-dt*fraction
          end
          entry.crossings[checkpoint-50]=nil
        end
        entry.timingCheckpoint=checkpoint
      end
      if entry.id == session.playerId and session.phase ~= "checkered" then updatePit(entry, car) end
      local racing = session.phase == "green" or session.phase == "yellow" or session.phase == "restart"
      if racing and updateIncident(entry, car, dt) then newIncident = true end
    end
  end
  if session.cautionAssist then
    for _, entry in ipairs(session.entries) do
      if entry.id == session.playerId and entry.inPit and not session.pitPlan then
        endCautionAssist()
        break
      end
    end
  end
  if session.phase == "green" and session.auto and (newIncident or session.paceUnavailable) then
    if session.elapsed >= (session.retryPaceAt or 0) then
      session.retryPaceAt = session.elapsed + 3
      M.yellow()
    end
  end
  if newIncident and session.phase == "restart" then
    assignFormation("yellow", standings())
    announce("YELLOW | Restart waved off for a new incident.")
  elseif newIncident and session.phase == "yellow" then
    local surviving = {}
    for _, entry in ipairs(session.order) do
      if not entry.out then surviving[#surviving + 1] = entry end
    end
    session.order = surviving
    session.formedSince, session.formedAt = nil, nil
  end

  scoreRace()
  if session.phase == "finished" then
    if session.limiterActive then
      setPitLimiter(vehicle(session.playerId), false)
      session.limiterActive = false
    end
    return
  end
  if session.phase == "checkered" then return end
  if session.phase == "green" then updateGreenLaunch();updateRacecraft();updateAIPitPlan(); return end
  if session.phase == "yellow" then
    updateIncidentResponse()
    updateRedFlag()
  end
  local ready = updateFormation()
  for _, entry in ipairs(session.entries) do
    local car = vehicle(entry.id)
    if car and ((session.blocked and (entry.id ~= session.playerId or session.allAI or session.cautionAssist))
      or (session.cautionAssist and entry.id == session.playerId and entry.out)) then
      formationControl(car, entry, 0, 0)
    end
  end
  updateAIPitPlan()
  if ready and not session.blocked then
    session.formedSince = session.formedSince or session.elapsed
    if session.elapsed - session.formedSince >= formationHold then session.formedAt = session.elapsed end
  else
    session.formedSince, session.formedAt = nil, nil
  end
  local phaseTime = session.elapsed - session.phaseAt
  if session.phase == "yellow" and not session.blocked and not next(session.incidents) and not session.response
    and session.elapsed - session.clearSince >= 5
    and ((session.formedAt and phaseTime >= cautionHold) or phaseTime >= cautionLineupLimit) then
    M.restart()
  elseif session.phase == "pace" or session.phase == "restart" then
    advancePaceLap()
  end
end

function M.flag()
  if not session then return announce("Start a race session first.") end
  if session.phase == "green" then return M.yellow() end
  if session.phase == "yellow" then return M.restart() end
  return M.green()
end

M.onUpdate = onUpdate
M.onVehicleResetted = onVehicleResetted
M.onClientEndMission = M.stop
M.onExtensionUnloaded = M.stop
return M
