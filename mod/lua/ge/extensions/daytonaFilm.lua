-- Internal capture assistant. No HUD or incident buttons.
local M = {}
local elapsed, phase, actor, file = 0, 'idle', nil, nil
local function save(extra)
  jsonWriteFile('/settings/daytona-film-take.json', {phase=phase, elapsed=elapsed, actor=actor, replay=file, details=extra}, true)
end
function M.start()
  extensions.daytonaRaceControl.startFromHud(3, 10, true, false)
  elapsed=0;phase='grid';actor=nil;save()
end
function M.onUpdate(dtReal,dtSim)
  if phase=='idle' or phase=='done' then return end
  elapsed=elapsed+(dtSim or dtReal)
  local race=extensions.daytonaRaceControl
  if phase=='grid' and elapsed>5 then
    local state=race.hudState()
    actor=state.incidentTargets and state.incidentTargets[1] and state.incidentTargets[1].id
    if actor then be:enterVehicle(0,be:getObjectByID(actor)) end
    core_camera.setByName(0,'orbit',false)
    -- Replay capture begins after green removes the pace car.
    file=core_replay.state.loadedFile
    phase='pace';save()
  elseif phase=='pace' and elapsed>20 then
    race.green();race.autoYellow(false);phase='green';save()
  elseif phase=='green' and elapsed>23 then
    core_replay.startRecording();phase='capture';save()
  elseif phase=='capture' and elapsed>38 then
    race.stageIncident('spin',actor);phase='incident';save()
  elseif phase=='incident' and elapsed>47 then
    file=core_replay.state.loadedFile or file
    core_replay.stopRecording({autoplayAfterStopping=false})
    phase='done';save();ui_visibility.set(true)
  end
end
return M
