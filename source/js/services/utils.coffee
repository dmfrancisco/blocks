# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic"])


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
