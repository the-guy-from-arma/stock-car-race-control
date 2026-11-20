angular.module('beamng.apps').directive('daytonaRaceControl', ['$interval', function ($interval) {

  return {

    restrict: 'EA',

    scope: true,

    templateUrl: '/ui/modules/apps/DaytonaRaceControl/app.html',

    link: function (scope) {

      var extension = 'local race = extensions.daytonaRaceControl; if not race then extensions.load("daytonaRaceControl"); race = extensions.daytonaRaceControl end; ' +

        'if not race then guihooks.trigger("DaytonaRaceControlUnavailable"); return end; '

      var flags = {

        idle: 'STANDBY', pace: 'PACE LAP', green: '', yellow: '',

        restart: 'ONE TO GREEN', checkered: 'CHECKERED', finished: 'RESULTS'

      }

      scope.state = { phase: 'idle' }

      scope.options = { laps: 10, opponents: 7 }

      scope.lapChoices = [2, 5, 10, 20, 50, 100, 200]

      scope.fieldChoices = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

      scope.flags = flags

      scope.settings = [

        { key: 'laps', label: 'Laps', values: scope.lapChoices },

        { key: 'opponents', label: 'AI cars', values: scope.fieldChoices }

      ]

      scope.atEnd = function (setting, change) {

        var next = setting.values.indexOf(scope.options[setting.key]) + change

        return next < 0 || next >= setting.values.length

      }

      scope.step = function (setting, change) {

        if (scope.atEnd(setting, change)) return

        var next = setting.values.indexOf(scope.options[setting.key]) + change

        scope.options[setting.key] = setting.values[next]

      }



      var streams = ['electrics', 'sensors', 'wheelThermalData', 'wheelInfo']

      StreamsManager.add(streams)

      scope.telemetry = {}

      scope.damage = {}

      scope.corners = ['FL', 'FR', 'RL', 'RR']

      scope.zones = ['FL', 'FR', 'ML', 'MR', 'RL', 'RR']

      scope.brakes = {}

      scope.format = function (value, digits) {

        return typeof value === 'number' && isFinite(value) ? value.toFixed(digits || 0) : '—'

      }

      scope.damageColor = function (zone) {

        var value = scope.damage.body && scope.damage.body[zone]

        if (typeof value !== 'number') return '#536171'

        return value > 0.15 ? '#ff5a50' : value > 0.015 ? '#ffc34c' : '#53ce9c'

      }

      scope.tireDamaged = function (corner) {

        return !!(scope.damage.wheels && scope.damage.wheels['tire' + corner])

      }

      scope.conditionTab = 'overview'
      scope.damageAlerts = []
      scope.conditionSystems = []
      var seenDamage = {}, alertTimes = {}, popupOwner = false
      scope.isRacing = function () { return scope.state.phase !== 'idle' && scope.state.phase !== 'finished' }
      function humanize(value) { return String(value).replace(/([a-z])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').replace(/^./, function (c) { return c.toUpperCase() }) }
      var cornerNames = {FL:'Front left',FR:'Front right',ML:'Left side',MR:'Right side',RL:'Rear left',RR:'Rear right'}
      function severity(group, name, value) {
        if (group === 'body') return typeof value === 'number' ? value > 0.15 ? 2 : value > 0.015 ? 1 : 0 : 0
        if (!value) return 0
        return /disabled|locked|melted|hydrolocked|tire|spindle|wheelaxle|driveshaft|critical|starved/i.test(name) ? 2 : 1
      }
      function alertDamage(group, name, value) {
        var level = severity(group,name,value), key = group + '.' + name, now = Date.now()
        if (!scope.isRacing() || !level || now - (alertTimes[key] || -100000) < 4000) return
        alertTimes[key] = now
        scope.damageAlerts = scope.damageAlerts.filter(function (a) { return now-a.at<6500 && a.key!==key })
        scope.damageAlerts.unshift({key:key,at:now,critical:level===2,title:group==='body' ? cornerNames[name] + ' body damage' : humanize(name),detail:group==='body' ? (level===2?'Heavy structural damage reported':'Body impact detected') : humanize(group) + ' system warning',action:level===2?'REDUCE SPEED · PIT FOR INSPECTION':'MONITOR CONDITION · PLAN PIT SERVICE'})
        scope.damageAlerts = scope.damageAlerts.slice(0,3)
      }
      function refreshCondition(data) {
        var groups = [
          {name:'Engine',source:'engine',filter:function(k){return !/oil|coolant|radiator/i.test(k)}},
          {name:'Cooling',source:'engine',filter:function(k){return /coolant|radiator|headGasket/i.test(k)}},
          {name:'Lubrication',source:'engine',filter:function(k){return /oil|bearing/i.test(k)}},
          {name:'Drivetrain',source:'powertrain',filter:function(k){return !/spindle|wheelaxle|torsion/i.test(k)}},
          {name:'Transmission',source:'gearbox'},
          {name:'Suspension / axles',source:'powertrain',filter:function(k){return /spindle|wheelaxle|torsion/i.test(k)}},
          {name:'Fuel / storage',source:'energyStorage'}
        ]
        scope.conditionSystems = groups.map(function(g){
          var source=data[g.source], keys=source ? Object.keys(source).filter(function(k){return !g.filter||g.filter(k)}) : []
          var faults=keys.filter(function(k){return severity(g.source,k,source[k])>0})
          var level=faults.reduce(function(max,k){return Math.max(max,severity(g.source,k,source[k]))},0)
          return {name:g.name,status:!keys.length?'NOT REPORTED':level===2?'CRITICAL':level===1?'WARNING':'NO FAULTS',level:level,known:keys.length>0,detail:faults.length?faults.map(humanize).join(' · '):keys.length?'No active faults reported':'Vehicle has not supplied this data'}
        })
      }
      scope.cornerCondition = function(corner) {
        var p=scope.damage.powertrain||{},w=scope.damage.wheels||{}
        return p['spindle'+corner]||p['wheelaxle'+corner]||w['wheel'+corner] ? 'AXLE / HUB DAMAGE' : scope.tireDamaged(corner) ? 'TIRE FAILURE' : Object.prototype.hasOwnProperty.call(w,'tire'+corner) ? 'NO TIRE FAULT' : 'NOT REPORTED'
      }
      scope.bodyStatus = function(zone) {
        var value=scope.damage.body&&scope.damage.body[zone]
        return typeof value!=='number'?'NO DATA':value>0.15?'HEAVY':value>0.015?'MINOR':'NO DAMAGE'
      }
      scope.$on('DaytonaDamageAlert',function(_,event){ if(event) scope.$evalAsync(function(){alertDamage(event.group,event.name,event.value)}) })
      scope.$on('DamageData', function (_, data) {
        scope.$evalAsync(function () {
          scope.damage=data||{}
          var nextSeen = {}
          Object.keys(scope.damage).forEach(function(group){
            Object.keys(scope.damage[group]||{}).forEach(function(name){
              var key=group+'.'+name, value=scope.damage[group][name], level=severity(group,name,value)
              if(level>(seenDamage[key]||0)) alertDamage(group,name,value)
              nextSeen[key]=level
            })
          })
          seenDamage=nextSeen
          refreshCondition(scope.damage)
        })
      })

      function resetTelemetry() {
        nextTelemetryAt = 0

        scope.$evalAsync(function () {

          scope.telemetry = {}

          scope.damage = {}

          scope.brakes = {}
          seenDamage = {}; alertTimes = {}; scope.damageAlerts = []; refreshCondition({})

        })

        bngApi.activeObjectLua('damageTracker.sendNow()')
        if(popupOwner) command('race.setDamagePopups(true)')

      }

      scope.$on('VehicleReset', resetTelemetry)

      scope.$on('VehicleFocusChanged', function(){ resetTelemetry(); if(popupOwner) command('race.setDamagePopups(true)') })

      var nextTelemetryAt = 0
      scope.$on('streamsUpdate', function (_, data) {
        var now = Date.now()
        if (now < nextTelemetryAt) return
        nextTelemetryAt = now + 100


        scope.$evalAsync(function () {

          scope.damageAlerts = scope.damageAlerts.filter(function(a){return Date.now()-a.at<6500})
          var e = data.electrics || {}

          var sensor = data.sensors || {}

          var thermal = data.wheelThermalData && data.wheelThermalData.wheels || {}

          scope.brakes = thermal

          var slips = Object.keys(data.wheelInfo || {}).map(function (key) {

            return Math.abs(data.wheelInfo[key][5] || 0)

          })

          scope.telemetry = {

            speed: typeof e.wheelspeed === 'number' ? e.wheelspeed * 2.236936 : undefined,

            rpm: e.rpm, gear: e.gear, fuel: typeof e.fuel === 'number' ? e.fuel * 100 : undefined,

            water: e.watertemp, oil: e.oiltemp,

            throttle: Math.round((e.throttle || 0) * 100),

            brake: Math.round((e.brake || 0) * 100),

            steering: e.steering,

            lateral: typeof sensor.gx2 === 'number' ? sensor.gx2 / 9.81 : undefined,

            longitudinal: typeof sensor.gy2 === 'number' ? sensor.gy2 / 9.81 : undefined,

            slip: slips.length ? Math.max.apply(null, slips) : undefined,

            hot: e.watertemp >= 115 || e.oiltemp >= 140

          }

        })

      })

      bngApi.activeObjectLua('damageTracker.sendNow()')



      var light = document.createElement('div')
      light.className = 'daytona-track-signal'
      light.hidden = true
      light.setAttribute('role', 'img')
      ;['amber', 'center', 'amber'].forEach(function (lamp) {
        var lens = document.createElement('span')
        lens.className = lamp + '-lamp'
        var flash = document.createElement('i')
        flash.className = 'signal-emitter'
        lens.appendChild(flash)
        light.appendChild(lens)
      })
      var label = document.createElement('b')
      label.className = 'signal-label'
      light.appendChild(label)
      document.body.appendChild(light)

      var cue = document.createElement('div')
      cue.className = 'daytona-restart-cue'
      cue.hidden = true
      cue.setAttribute('role', 'status')
      var cueTitle = document.createElement('strong')
      var cueDetail = document.createElement('span')
      cue.appendChild(cueTitle)
      cue.appendChild(cueDetail)
      document.body.appendChild(cue)
      var previousPhase, previousColor, greenUntil = 0

      function updateSignal(state) {
        var colors = { pace: 'amber', yellow: 'amber', restart: 'amber', green: 'green', checkered: 'white', finished: 'white' }
        var color = state.blocked ? 'red' : colors[state.phase]
        light.hidden = !color || !state.available
        if (color !== previousColor) {
          light.className = 'daytona-track-signal ' + (color || '')
          previousColor = color
        }
        label.textContent = state.blocked ? 'TRACK BLOCKED' : state.phase === 'green' ? 'TRACK GREEN' : state.phase === 'restart' ? 'ONE TO GREEN' : state.phase === 'pace' ? 'PACE LAP' : state.phase === 'yellow' ? 'CAUTION' : 'CHECKERED'
        light.setAttribute('aria-label', label.textContent)
        if (state.phase === 'green' && (previousPhase === 'pace' || previousPhase === 'restart' || previousPhase === 'yellow')) {
          greenUntil = Date.now() + 3500
          cue.className = 'daytona-restart-cue green-release'
          cueTitle.textContent = 'GREEN FLAG'
          cueDetail.textContent = state.allAI ? 'RACE UNDERWAY' : 'YOU HAVE CONTROL'
        }
        var greenCue = state.phase === 'green' && Date.now() < greenUntil
        if (!greenCue && state.restartCountdown) {
          cue.className = 'daytona-restart-cue countdown'
          cueTitle.textContent = String(state.restartCountdown)
          cueDetail.textContent = state.cautionAssist ? 'GET READY TO DRIVE' : 'GREEN APPROACHING'
        }
        cue.hidden = !(greenCue || state.restartCountdown) || !state.available || state.blocked
        previousPhase = state.phase
      }

      scope.lapTime = function (seconds) {
        if (typeof seconds !== 'number' || !isFinite(seconds)) return '—'
        var mins = Math.floor(seconds / 60)
        var value = (seconds % 60).toFixed(3)
        return mins ? mins + ':' + (seconds % 60 < 10 ? '0' : '') + value : value
      }
      scope.raceTime = function (seconds) {
        if (typeof seconds !== 'number') return '00:00'
        return Math.floor(seconds / 60) + ':' + ('0' + Math.floor(seconds % 60)).slice(-2)
      }
      scope.broadcastGap = function (car) {
        if (car.position === 1) return 'LEADER'
        if (car.lapsDown) return '+' + car.lapsDown + ' LAP'
        return typeof car.interval === 'number' ? '+' + car.interval.toFixed(3) : '—'
      }
      scope.formationHint = function () {

        if (scope.state.cautionAssist) return 'AI pacing · Control returns to you at green.'
        if (scope.state.formed) return scope.state.phase === 'yellow' ? 'Hold formation.' : 'Hold formation. Green when the pace car clears.'

        if (scope.state.slotGap > 8) return 'Close the gap to your row.'

        if (scope.state.slotGap < -8) return 'Ease back to your row.'

        if (scope.state.phase === 'pace' || scope.state.phase === 'restart') return 'Hold your lane. The pace car releases the field.'

        return 'Hold your assigned lane.'

      }



      scope.tickerDrivers = []
      scope.towerDrivers = []
      var nextBroadcastAt = 0
      function updateBroadcast(state) {
        var drivers = state.broadcast || []
        if (!drivers.length) { scope.tickerDrivers = []; scope.towerDrivers = []; nextBroadcastAt = 0; return }
        if (Date.now() < nextBroadcastAt && scope.tickerDrivers.length === drivers.length) return
        nextBroadcastAt = Date.now() + 1000
        var byId = {}
        drivers.forEach(function (driver) { byId[driver.id] = driver })
        var stable = scope.tickerDrivers.filter(function (driver) { return byId[driver.id] })
        stable.forEach(function (driver) { Object.assign(driver, byId[driver.id]); delete byId[driver.id] })
        drivers.forEach(function (driver) { if (byId[driver.id]) { stable.push(Object.assign({}, driver)); delete byId[driver.id] } })
        scope.tickerDrivers = stable
        scope.towerDrivers = drivers
      }
      scope.$on('DaytonaRaceControlState', function (_, state) {

        if (state && Object.prototype.hasOwnProperty.call(flags, state.phase)) {

          scope.$evalAsync(function () { scope.state = state; updateSignal(state); updateBroadcast(state)
            var active=scope.isRacing()
            if(active!==popupOwner){popupOwner=active;command('race.setDamagePopups('+String(active)+')')}
            if(!active) scope.damageAlerts=[] })

        }

      })



      scope.$on("DaytonaRaceControlUnavailable", function () {

        scope.$evalAsync(function () {

          scope.unavailable = true

          scope.state = { phase: "idle" }

          light.hidden = true

        })

      })



      function read() {

        if (scope.unavailable) return

        bngApi.engineLua(extension + 'race.publishHud()')

      }



      function command(action) {

        if (scope.unavailable) return

        bngApi.engineLua(extension + action + '; race.publishHud()')

      }



      scope.startRace = function () {

        var laps = scope.options.laps

        var opponents = scope.options.opponents

        if (scope.lapChoices.indexOf(laps) < 0 || scope.fieldChoices.indexOf(opponents) < 0) return

        command('race.startFromHud(' + opponents + ',' + laps + ',false,true,' + (laps >= 6 && scope.options.stages === true) + ')')

      }



      scope.stopRace = function () { command('race.stop()') }

      scope.repair = function () { command('race.pitService("repair")') }
      scope.requestPitRepair = function () { command('race.requestPitRepair()') }

      scope.servePenalty = function () { command('race.pitService("penalty")') }
      scope.refuel = function () { command('race.pitService("fuel")') }

      scope.cancelPit = function () { command('race.cancelPit()') }

      scope.requestTow = function () { command('race.requestTow()') }
      scope.dismissTow = function () { command('race.dismissTow()') }

      read()

      var timer = $interval(read, 350, 0, false)

      scope.$on('$destroy', function () {

        command('race.setDamagePopups(false)')
        $interval.cancel(timer)

        StreamsManager.remove(streams)

        light.remove()
        cue.remove()

      })

    }

  }

}])
