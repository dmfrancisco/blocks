# Allow scripts to be included in any order
@App ||= angular.module("logr", ["ionic"])


# Configurations used across the application
@App.factory "Config", ->
  obj = {}

  genericColorClasses = [
    "color-bgd"
    "color-1"
    "color-2"
    "color-3"
    "color-4"
    "color-5"
  ]

  # Property to save temporary dirty properties
  obj.dirty = {}

  # Available themes (color palettes)
  obj.themes = [{
    id: "ruby"
    colorClasses: genericColorClasses
  }, {
    id: "purple"
    colorClasses: genericColorClasses
  }, {
    id: "sulek"
    colorClasses: genericColorClasses
  }, {
    id: "octocat"
    colorClasses: genericColorClasses
  }]

  # If the theme has a light background, a dark status bar will be used (iOS 7)
  obj.lightThemeIds = [
    "octocat"
  ]

  # A list of placeholders to show in the log title input
  obj.titlePlaceholders = [
    "exercise"
    "running"
    "read"
    "journal"
    "writing"
    "blog post"
    "drawing"
    "painting"
    "flossing"
    "inbox zero"
    "empty inbox"
    "homework"
    "steps"
    "gym"
    "workout"
    "social"
    "meditation"
    "sleep time"
    "hours slept"
    "bed early"
    "vitamins"
    "pomodoros"
    "focus"
    "cash spent"
    "water cups"
    "new skill"
    "drinking"
    "gas"
    "calories"
    "cake intake"
    "eat fruits"
    "hours worked"
    "commits"
    "joy levels"
    "breaks"
    "sodas today"
    "coffees"
    "coffees ☕️"
    "chocolate"
    "chocolate 🍫"
    "cookies"
    "cookies 🍪"
    "walk 🐶"
    "expenses 💰"
    "practice 🎵"
    "23pm 🌙"
    "6am 😴"
  ]

  # Sounds used in the application
  obj.sounds = {
    created:   new Audio("sounds/qurazy_quoin.mp3")
    destroyed: new Audio("sounds/friend_exits.mp3")
  }

  # Number of weeks the app displays
  if window.innerHeight <= 480
    obj.initialWeeks = 9
    obj.totalWeeks = 26
  else
    obj.initialWeeks = 12
    obj.totalWeeks = 52

  return obj


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


# Utility methods
@App.factory "Utils", ->
  obj = {}

  currentPlaceholderIndex = 0

  # This method returns a random placeholder without repeating the values
  obj.genRandomPlaceholder = (placeholders) ->
    if currentPlaceholderIndex is 0
      placeholders.sort(-> 0.5 - Math.random())

    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % placeholders.length
    return placeholders[currentPlaceholderIndex]

  # List of abbreviated month names
  obj.monthsShort = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ]

  # Remove emoji characters (more info at: stackoverflow.com/a/10999907/543293)
  obj.removeEmoji = (str) ->
    str.replace(/([\uE000-\uF8FF]|\uD83C[\uDF00-\uDFFF]|\uD83D[\uDC00-\uDE4F]|\uD83D[\uDE80-\uDEFF])/g, '')

  return obj


# The Squares factory has the logic necessary to render the squares for a log
@App.factory "Squares", (Config, Utils, Logs) ->
  obj = {}

  # Initialize the squares with filled dates and binary colors
  obj.init = (totalWeeks = Config.totalWeeks, squares = []) ->
    today = new Date()
    lastDayOfWeek = new Date()
    lastDayOfWeek.setDate(today.getDate() - today.getDay() + 6)
    currentDay = lastDayOfWeek

    for weekNo in [0..totalWeeks]
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
    return "" if date > new Date()

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
