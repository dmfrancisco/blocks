# The Logs factory handles saving and loading logs from local storage
Application.factory "Logs", ->
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

Application.factory "Squares", (Logs) ->
  obj = {}

  # Initialize the squares with filled dates and binary colors
  obj.init = (squares = []) ->
    today = new Date()
    lastDayOfWeek = new Date()
    lastDayOfWeek.setDate(today.getDate() - today.getDay() + 6)
    currentDay = lastDayOfWeek

    for weekNo in [0..Config.totalWeeks]
      squares[weekNo] = []

      for dayOfWeek in [6..0]
        squares[weekNo][dayOfWeek] = {
          date:    new Date currentDay.getTime()
          color:   if currentDay > today then "" else "color-0"
          dateRef: getDateRef(currentDay, weekNo)
        }
        currentDay.setDate(currentDay.getDate() - 1)

    return squares

  getDateRef = (date, weekNo) ->
    dayOfWeek = date.getDay()
    dayOfMonth = date.getDate()

    if dayOfMonth is 1 and date.getMonth() is 0
      return date.getFullYear()
    else if dayOfMonth is 1
      return Utils.monthsShort[date.getMonth()]
    else if dayOfWeek is 1 and weekNo is 0
      return "M"
    else if dayOfWeek is 3 and weekNo is 0
      return "W"
    else if dayOfWeek is 5 and weekNo is 0
      return "F"
    return ""

  # Fill the squares with additional data: date refs, log values and colors
  obj.setProperties = (log, squares, from, to) ->
    for weekNo in [from..to]
      rowOfSquares = squares[weekNo]
      for square in rowOfSquares
        setSquare(log, square, weekNo)

  getValue = (log, square) ->
    Logs.getValue(log, square.date)

  getColor = (log, square) ->
    return "" if square.date > new Date()

    value = square.value
    return "color-1" if value == 0
    return "color-0" if value < 0

    color = Math.ceil(value * 4 / log.maxValue) + 1
    color = Math.min(color, 5) # Happens when the maxValue is not yet updated
    return "color-#{ color }" # color will be 2, 3, 4 or 5

  setSquare = (log, square, weekNo) ->
    square.value = getValue(log, square)
    square.color = getColor(log, square)

  return obj
