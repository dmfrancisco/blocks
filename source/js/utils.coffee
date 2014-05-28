Utils = ->
  currentPlaceholderIndex = 0

  # This method returns a random placeholder without repeating the values
  genRandomPlaceholder = (placeholders) ->
    if currentPlaceholderIndex is 0
      placeholders.sort(-> 0.5 - Math.random())

    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % placeholders.length
    return placeholders[currentPlaceholderIndex]

  monthsShort = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ]

  return {
    genRandomPlaceholder: genRandomPlaceholder,
    monthsShort: monthsShort
  }

window.Utils = new Utils()
