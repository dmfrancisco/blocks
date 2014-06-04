# Allow scripts to be included in any order
@App ||= angular.module("logr", ["ionic"])


# The Logs factory handles saving and loading logs from local storage
@App.factory "Logs", ->
  obj = {}

  obj.all = ->
    logString = window.localStorage.logs
    return angular.fromJson(logString) if logString
    return []

  obj.save = (logs) ->
    window.localStorage.logs = angular.toJson(logs)
    return

  obj.newLog = (logTitle, logThemeId) ->
    return {
      title:    logTitle
      themeId:  logThemeId
      values:   {}
      maxValue: 0
    }

  obj.getValue = (log, date) ->
    value = log.values[date.toDateString()]
    return -1 if value is undefined
    return value

  obj.setValue = (log, date, value) ->
    if value == -1
      delete log.values[date.toDateString()]
    else
      log.values[date.toDateString()] = value
    updateMaxValue(log)

  updateMaxValue = (log, maxValue = 0) ->
    angular.forEach log.values, (value) ->
      maxValue = Math.max(value or 0, maxValue)
    log.maxValue = maxValue

  return obj
