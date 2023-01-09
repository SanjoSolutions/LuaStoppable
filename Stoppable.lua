local addOnName, AddOn = ...
Stoppable = Stoppable or {}

--- @class Stoppable.Stoppable: Resolvable.Resolvable
Stoppable.Stoppable = {}
setmetatable(Stoppable.Stoppable, { __index = Resolvable.Resolvable })

function Stoppable.Stoppable:new()
  --- @class Stoppable.Stoppable: Resolvable.Resolvable
  local stoppable, resolvableInternal = Resolvable.Resolvable:new()
  stoppable._hasBeenRequestToStop = false
  stoppable._hasStopped = false
  stoppable._onStop = Hook.Hook:new()
  stoppable._onStop.runCallbacks = Function.once(stoppable._onStop.runCallbacks)
  stoppable._afterStop = Hook.Hook:new()
  stoppable._afterStop.runCallbacks = Function.once(stoppable._afterStop.runCallbacks)
  stoppable._alsoToStop = {}
  setmetatable(stoppable, { __index = Stoppable.Stoppable })
  local stoppableInternal = {
    resolve = Function.once(function(...)
      if stoppable:_haveAllStoppablesAlsoToStopBeenStopped() then
        stoppable:_registerAsStopped()
      else
        local stillRunningStoppables = Array.filter(stoppable._alsoToStop, function(stoppable)
          return stoppable:isRunning()
        end)
        local numberOfStillRunningStoppables = Array.length(stillRunningStoppables)
        Array.forEach(stillRunningStoppables, function(stoppable)
          stoppable:afterStop(function()
            numberOfStillRunningStoppables = numberOfStillRunningStoppables - 1
            if numberOfStillRunningStoppables == 0 then
              stoppable:_registerAsStopped()
            end
          end)
        end)
      end
      resolvableInternal:resolve(...)
    end)
  }
  return stoppable, stoppableInternal
end

function Stoppable.Stoppable:hasBeenRequestedToStop()
  return self._hasBeenRequestToStop
end

function Stoppable.Stoppable:isRunning()
  return not self._hasStopped
end

function Stoppable.Stoppable:hasStopped()
  return self._hasStopped
end

function Stoppable.Stoppable:stop()
  local resolvable, resolvableInternal = Resolvable.Resolvable:new()
  self._afterStop:registerCallbackForRunningOnce(function(...)
    resolvableInternal:resolve(...)
  end)

  self._hasBeenRequestToStop = true
  Array.forEach(self._alsoToStop, function(stoppable)
    stoppable:stop()
  end)
  self._onStop:runCallbacks()

  return resolvable
end

function Stoppable.Stoppable:alsoStop(stoppable)
  table.insert(self._alsoToStop, stoppable)
  return self
end

function Stoppable.Stoppable:onStop(callback)
  self._onStop:registerCallback(callback)
  return self
end

function Stoppable.Stoppable:afterStop(callback)
  self._afterStop:registerCallback(callback)
  return self
end

function Stoppable.Stoppable:_haveAllStoppablesAlsoToStopBeenStopped()
  return Array.all(self._alsoToStop, function(stoppable)
    return stoppable:hasStopped()
  end)
end

function Stoppable.Stoppable:_registerAsStopped()
  self._hasStopped = true
  self._afterStop:runCallbacks()
end
