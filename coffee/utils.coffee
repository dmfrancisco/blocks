Utils = ->
  currentPlaceholderIndex = 0

  # This method returns a random placeholder without repeating the values
  genRandomPlaceholder = (placeholders) ->
    if currentPlaceholderIndex is 0
      placeholders.sort(-> 0.5 - Math.random())

    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % placeholders.length
    return placeholders[currentPlaceholderIndex]

  # Get date object given the day of the week and the number of weeks couting from today
  getDate = (dayOfWeek, weekNo) ->
    return moment().day(dayOfWeek - 7 * weekNo)

  return {
    genRandomPlaceholder: genRandomPlaceholder,
    getDate: getDate
  }

window.Utils = new Utils()
