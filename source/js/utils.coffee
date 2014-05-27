Utils = ->
  currentPlaceholderIndex = 0

  # This method returns a random placeholder without repeating the values
  genRandomPlaceholder = (placeholders) ->
    if currentPlaceholderIndex is 0
      placeholders.sort(-> 0.5 - Math.random())

    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % placeholders.length
    return placeholders[currentPlaceholderIndex]

  return {
    genRandomPlaceholder: genRandomPlaceholder
  }

window.Utils = new Utils()
