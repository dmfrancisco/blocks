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
