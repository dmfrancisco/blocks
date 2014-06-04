# Allow scripts to be included in any order
@App ||= angular.module("logr", ["ionic"])


@App.controller "LogController", ($scope, $ionicModal, $ionicPopup, $stateParams, $timeout, $animate, Config, Logs, Squares) ->

  # Load or initialize logs and squares
  $scope.logs = Logs.all()
  $scope.log = $scope.logs[$stateParams.id]
  $scope.squares = Squares.init(Config.initialWeeks)
  $scope.hasMoreData = true

  # Update the squares asynchronously
  $timeout ->
    Squares.setProperties($scope.log, $scope.squares, 0, Config.initialWeeks)

  loadMore = ->
    $timeout ->
      $scope.squares = Squares.init(Config.totalWeeks)
      Squares.setProperties($scope.log, $scope.squares, 0, Config.totalWeeks)
      $scope.hasMoreData = false
    , 2000

  loadMore()

  setValue = (date, value) ->
    Logs.setValue($scope.log, date, value)
    Squares.setProperties($scope.log, $scope.squares, 0, Config.totalWeeks)

  $scope.displayCounter = (e, $scope) ->
    date = $scope.square.date
    return if date > new Date() or $scope.hasMoreData

    # Disable scroll
    e.gesture.srcEvent.preventDefault()

    # Event values
    radius  = e.gesture.distance
    centerX = e.gesture.startEvent.center.pageX
    centerY = e.gesture.startEvent.center.pageY
    screenW = window.innerWidth
    screenH = window.innerHeight

    x0 = 30
    x1 = 0.8 * Math.sqrt(Math.pow(screenW, 2) + Math.pow(screenH, 2)) / 2
    maxValue = 100

    if radius == 0 and e.type == "hold"
      value = $scope.square.value
    else if radius < 40
      value = -1
    else if radius > x1
      value = maxValue
    else
      a = maxValue / Math.pow(x1 - x0, 3)
      value = Math.round(a * Math.pow(radius - x0, 3))

    # Save the counter value (will be persisted after the release event)
    if Config.dirty.counterValue == null
      Config.dirty.counterValue = $scope.square.value
    setValue(date, value)

    # Calculate the size and position of the circle input
    minRadius     = 50
    counterRadius = Math.round Math.max(minRadius, radius)
    counterSize   = counterRadius * 2
    counterTop    = Math.round(e.gesture.startEvent.center.pageY - counterRadius)
    counterLeft   = Math.round(centerX - counterRadius)

    # Calculate the font-size
    offRight      = screenW - (counterSize + counterLeft)
    offBottom     = screenH - (counterSize + counterTop)
    minCoord      = Math.min(0, counterLeft, counterTop, offRight, offBottom)
    visibleSize   = Math.max(minRadius, (counterRadius + minCoord) * 2)
    fontSize      = Math.round(visibleSize / 3.5)

    if value < 0
      content = ""
    else
      content = "#{ value }<sub> / #{ $scope.log.maxValue }</sub>"

    # Display a circle around the point where the dragging started
    counter = angular.element(document.getElementById("counter"))

    if Math.abs(Config.dirty.lastRadius - radius) < 10
      Config.dirty.timeout = setTimeout(->
        Config.dirty.shouldSave = true
        counter.addClass("stable")
      , 500)
    else
      clearTimeout(Config.dirty.timeout)
      Config.dirty.shouldSave = false
      counter.removeClass("stable")

    Config.dirty.lastRadius = radius

    counter
      .addClass("zoom-in")
      .html(content)
      .css({
        display: "block",
        top:    "#{ counterTop  }px",
        left:   "#{ counterLeft }px",
        width:  "#{ counterSize }px",
        height: "#{ counterSize }px",
        "margin-top":    "0",
        "margin-left":   "0",
        "font-size":     "#{ fontSize      }px",
        "line-height":   "#{ counterSize   }px",
        "border-radius": "#{ counterRadius }px"
      })

  $scope.hideCounter = (e, $scope) ->
    date = $scope.square.date

    # Save the counter value
    if Config.dirty.shouldSave == false and Config.dirty.counterValue != null
      setValue(date, Config.dirty.counterValue)
    else
      Logs.save($scope.logs)

    # Clear dirty attributes
    Config.dirty.counterValue = null
    clearTimeout(Config.dirty.timeout)
    Config.dirty.shouldSave = false

    # Hide the circle with the counter
    counter = angular.element(document.getElementById("counter"))
    counter.removeClass("zoom-in")
    $animate.addClass counter, "zoom-out", ->
      counter.css(display: "none").removeClass("zoom-out")

  $scope.displayCounting = (square) ->
    value = square.value

    if value < 0
      # Show help
      $ionicPopup.show
        title: "Hold & drag to score a day"
        buttons: [ { text: "OK", type: "button-clear button-positive" } ]
      return

    content = "#{ value }<sub> / #{ $scope.log.maxValue }</sub>"
    counter = angular.element(document.getElementById("counter"))

    clearTimeout(Config.dirty.timeout)

    Config.dirty.timeout = setTimeout(->
      $animate.addClass counter, "zoom-out", ->
        counter.css(display: "none").removeClass("zoom-out")
    , 1000)

    $animate.addClass counter, "bounce", -> counter.removeClass("bounce")

    counter
      .html(content)
      .addClass("stable")
      .css({
        display: "block",
        top:    "50%",
        left:   "50%",
        width:  "220px",
        height: "220px",
        "margin-top":    "-110px",
        "margin-left":   "-110px",
        "font-size":     "60px",
        "line-height":   "220px",
        "border-radius": "110px"
      })
    return


  # Use the lightContent statusbar (light text, for dark backgrounds)
  if window.StatusBar
    if Config.lightThemeIds.indexOf($scope.log.themeId) == -1
      StatusBar.styleLightContent()
    else
      $timeout(StatusBar.styleDefault, 400)
