# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic", "pouchdb"])


# The Squares factory has the logic necessary to render the squares for a log
@App.factory "Squares", (Config, Utils, Logs) ->
  obj = {}

  # Initialize the squares with filled dates and binary colors
  obj.init = (totalWeeks = Config.totalWeeks, squares = []) ->
    today = Config.startDate()
    lastDayOfWeek = Config.startDate()
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
    return "" if date > Config.startDate()

    dayOfWeek = date.getDay()
    dayOfMonth = date.getDate()

    template = (text, cssClass = "") ->
      return "<span class='date-ref #{ cssClass }'>#{ text }</span>"

    if dayOfMonth is 1 and date.getMonth() is 0
      return template date.getFullYear()
    else if dayOfMonth is 1
      return template Utils.monthsShort[date.getMonth()]
    else if dayOfWeek is 1 and weekNo is 0
      return template "M"
    else if dayOfWeek is 3 and weekNo is 0
      return template "W"
    else if dayOfWeek is 5 and weekNo is 0
      return template "F"
    else if dayOfWeek is 0
      return template(dayOfMonth, "secondary")
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
    return "" if square.date > Config.startDate()

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
