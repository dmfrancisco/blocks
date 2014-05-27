# The Logs factory handles saving and loading logs from local storage
Application.factory "Logs", ->
  all: ->
    logString = window.localStorage.logs
    return angular.fromJson(logString) if logString
    return []

  save: (logs) ->
    window.localStorage.logs = angular.toJson(logs)
    return

  newLog: (logTitle, logThemeId, maxValue = 0, logValues = {}) ->
    return {
      title:    logTitle
      themeId:  logThemeId
      maxValue: maxValue
      values:   logValues
    }

  getValue: (log, date) ->
    value = log.values[date]
    return -1 if value is undefined
    return value

  getMaxValue: (log, maxValue = 0) ->
    _.each log.values, (value) ->
      maxValue = Math.max(value or 0, maxValue)
    return maxValue

  setValue: (log, date, value) ->
    if value == -1
      delete log.values[date]
    else
      log.values[date] = value
