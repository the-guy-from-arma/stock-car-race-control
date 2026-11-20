local M = {}
local active, actorId, elapsed, previousCamera, shotIndex, cameraPosition
local shortOval
local shots={"HELICOPTER","BLIMP","HIGH TRACKING"}
function M.start(id, compactOval)
  if active then M.stop() end
  if not core_camera or not commands then return end
  shortOval = compactOval == true
  actorId=id;elapsed=0;shotIndex=nil;cameraPosition=nil
  previousCamera=core_camera.getActiveCamName(0)
  if not previousCamera or previousCamera=='free' then previousCamera='orbit' end
  active=true
  if core_camera.setContextCamera and core_camera.getContextIdForPlayer then
    core_camera.setContextCamera(core_camera.getContextIdForPlayer(0), "free")
  else
    commands.setFreeCamera(0)
  end
end
function M.stop()
  if not active then return end
  active=false
  if core_camera.setContextCamera and core_camera.getContextIdForPlayer then
    core_camera.setContextCamera(core_camera.getContextIdForPlayer(0), previousCamera or "orbit")
  else
    commands.setGameCamera(0)
    core_camera.setByName(0,previousCamera or "orbit",false)
  end
  actorId=nil;cameraPosition=nil;shotIndex=nil
end
function M.getShot() return active and shots[shotIndex or 1] or nil end
function M.onUpdate(dtReal,dtSim)
  if not active then return end
  local car=be:getObjectByID(actorId)
  if not car then return M.stop() end
  elapsed=elapsed+(dtSim or 0)
  local index=math.floor(elapsed/12)%3+1
  local focus=car:getPosition()
  local forward=car:getDirectionVector()
  local right=forward:cross(vec3(0,0,1))
  local target,fov
  if index==1 then target=focus-forward*25+right*(shortOval and -35 or 48)+vec3(0,0,55);fov=58
  elseif index==2 then target=focus-forward*65+right*(shortOval and -30 or 85)+vec3(0,0,160);fov=57
  else target=focus+forward*32-right*(shortOval and 28 or 40)+vec3(0,0,38);fov=62 end
  if index~=shotIndex or not cameraPosition then cameraPosition=vec3(target);shotIndex=index;core_camera.setFOV(0,fov)
  else cameraPosition=cameraPosition+(target-cameraPosition)*math.min(1,math.max(0,dtReal or dtSim or 0)*3.5) end
  local look=focus+forward*12+vec3(0,0,1)
  local rotation=quatFromDir((look-cameraPosition):normalized(),vec3(0,0,1))
  core_camera.setPosRot(0,cameraPosition.x,cameraPosition.y,cameraPosition.z,rotation.x,rotation.y,rotation.z,rotation.w)
end
M.onClientEndMission=M.stop
M.onExtensionUnloaded=M.stop
return M
