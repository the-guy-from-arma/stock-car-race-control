local M={}
local original,wrapper,enabled
function M.setEnabled(value)
  if value and not enabled then
    original=damageTracker.setDamage
    local base=original
    wrapper=function(group,name,damage,notifyUI)
      if not enabled then return base(group,name,damage,notifyUI) end
      local previous=damageTracker.getDamage(group,name)
      base(group,name,damage,false)
      if notifyUI and damage~=previous and damage~=false and damage~=0 and damage~=nil then
        guihooks.trigger('DaytonaDamageAlert',{group=group,name=name,value=damage})
      end
    end
    damageTracker.setDamage=wrapper
    enabled=true
  elseif not value and enabled then
    if damageTracker.setDamage==wrapper then damageTracker.setDamage=original end
    enabled=false
  end
end

function M.setGearboxModeQuietly(mode)
  local gearbox = controller.mainController
  if gearbox.gearboxBehavior == mode then return end
  local show = guihooks.messageForSeatedPlayers
  guihooks.messageForSeatedPlayers = function(message, ...)
    if type(message) == "table" and message.category == "vehicle.shiftermode" then return end
    return show(message, ...)
  end
  local ok, err = pcall(gearbox.setGearboxMode, mode)
  guihooks.messageForSeatedPlayers = show
  if not ok then error(err) end
end

M.onExtensionUnloaded=function() M.setEnabled(false) end
return M
