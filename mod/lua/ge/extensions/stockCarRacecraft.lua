local M = {}

local lanes = {-1.9, 1.9}

function M.offset(lane)
  return lanes[lane]
end

function M.style(number)
  return {
    pace = 0.925 + (number * 13 % 19) * 0.0038,
    aggression = ((number * 7 % 13) - 6) * 0.013,
    headway = 0.36 + (number * 11 % 12) * 0.024,
    patience = 0.35 + (number * 17 % 9) * 0.19,
    draft = 0.5 + (number * 5 % 11) * 0.15
  }
end

local function gap(from, to, length)
  return (to - from + length * 0.5) % length - length * 0.5
end

function M.plan(car, field, length, maximum, time, canMove)
  local style, lane = car.style, car.lane
  local otherLane = 3 - lane
  local freeSpeed = maximum * style.pace
  local leader, frontGap
  local clear = true
  for _, neighbour in ipairs(field) do
    if neighbour.id ~= car.id then
      local distance = gap(car.s, neighbour.s, length)
      local lateral = neighbour.lateral
      local occupiedLane = neighbour.lane
      -- Reserve the requested lane while a car is still moving across.
      if distance > 0 and (occupiedLane == lane or math.abs(lateral - lanes[lane]) < 2.65
        or math.abs(lateral - car.lateral) < 2.35) and (not frontGap or distance < frontGap) then
        leader, frontGap = neighbour, distance
      end
      if occupiedLane == otherLane or math.abs(lateral - lanes[otherLane]) < 2.65 then
        local frontSafe = 11 + math.max(0, car.speed - neighbour.speed) * 1.25
        local rearSafe = 9 + math.max(0, neighbour.speed - car.speed) * 1.6
        if distance >= -rearSafe and distance <= frontSafe then clear = false end
      end
    end
  end

  if not leader or frontGap > math.max(22, car.speed * 1.15) then
    return freeSpeed, lane
  end
  local followingGap = 6.5 + style.headway * car.speed
  local constrained = leader.speed + (frontGap - followingGap) * 0.55
  local draftSpeed = frontGap > followingGap and leader.speed >= 12 and car.straight
    and math.min(maximum, freeSpeed + style.draft) or freeSpeed
  local waiting = car.waiting or time
  local settled = math.abs(car.lateral - lanes[lane]) < 1.25
  if canMove and clear and car.straight and settled and car.speed >= 8 and freeSpeed > leader.speed + 1.2
    and frontGap < followingGap + 8 and time - waiting >= style.patience then
    -- Keep the initial merge speed near the lead car until the overlap clears.
    return math.min(draftSpeed, leader.speed + 2), otherLane
  end
  return math.max(0, math.min(draftSpeed, constrained)), lane, waiting
end

return M
