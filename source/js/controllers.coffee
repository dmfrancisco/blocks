Application.controller "LogIndexController", ($scope, $ionicModal, $ionicActionSheet, $timeout, Logs) ->
  # Load or initialize logs
  $scope.logs = Logs.all()

  # Load themes (for the new form)
  $scope.themes = Config.themes

  # Create and load the modal
  $ionicModal.fromTemplateUrl("logs/new.html", ((modal) ->
      $scope.logModal = modal
    ),
    scope: $scope
    animation: "custom-slide-in-up"
  )

  # Called when the form is submitted
  $scope.createLog = (log) ->
    # If the user didn't filled the title, use the placeholder value
    log.title = $scope.randomPlaceholder unless log.title

    # Create the log
    newLog = Logs.newLog(log.title, log.themeId)
    $scope.logs.push newLog
    Logs.save $scope.logs

    # Play a sound and hide the modal
    Config.sounds.created.play()
    $scope.logModal.hide()

  # Open the new log modal
  $scope.newLog = ->
    # Display the modal
    $scope.logModal.show()

    # Pre-fill the form fields
    $scope.randomPlaceholder = Utils.genRandomPlaceholder(Config.titlePlaceholders)
    $scope.log = { title: null, themeId: Config.themes[0].id }

    # This modal is called by the pull-to-refresh component.
    # To improve the animation, call complete after some delay
    $timeout (-> $scope.$broadcast("scroll.refreshComplete")), 500

  # Edit log
  $scope.updateLog = (log) ->
    # TODO

  # Destroy log
  $scope.destroyLog = (log) ->
    $ionicActionSheet.show
      destructiveText: "Remove &nbsp;<strong>#{ log.title.toLowerCase() }</strong>"
      cancelText: "Cancel"

      destructiveButtonClicked: ->
        index = $scope.logs.indexOf(log)
        $scope.logs.splice(index, 1)
        Logs.save($scope.logs)

        Config.sounds.destroyed.play()
        return true

  # Close the new log modal
  $scope.closeNewLog = ->
    $scope.logModal.hide()

  # Use the lightContent statusbar (light text, for dark backgrounds)
  StatusBar.styleLightContent() if window.StatusBar


Application.controller "LogController", ($scope, $ionicModal, $stateParams, $timeout, Logs) ->
  $scope.logIndex = $stateParams.id
  $scope.logs = Logs.all()
  $scope.log = $scope.logs[$scope.logIndex]

  $scope.hasMoreData = true
  $scope.weeks = [ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ]

  $scope.weekdays = (weekNo) ->
    dates = []
    for dayOfWeek in [0..6]
      dates.push moment().day(dayOfWeek - 7 * weekNo).format("YYYY-MM-DD")
    return dates

  $scope.loadMore = ->
    for i in [0..16]
      $scope.weeks.push($scope.weeks.length)

    if $scope.weeks.length >= 336
      $scope.hasMoreData = false

    $scope.$broadcast("scroll.infiniteScrollComplete")

  $scope.dateTip = (date, weekNo) ->
    date = moment(date)

    if date.format("D") is "1" and date.month() is 0
      return date.year()
    else if date.format("D") is "1"
      return date.format("MMM")
    else if date.day() is 1 and weekNo is 0
      return "M"
    else if date.day() is 3 and weekNo is 0
      return "W"
    else if date.day() is 5 and weekNo is 0
      return "F"

  $scope.getColor = (date) ->
    return "" if moment(date) > moment()

    value = Logs.getValue($scope.log, date)
    return "color-1" if value == 0
    return "color-0" if value < 0

    color = Math.ceil(value * 4 / $scope.log.maxValue) + 1
    color = Math.min(color, 5) # Happens when the maxValue is not yet updated
    return "color-#{ color }" # color will be 2, 3, 4 or 5

  $scope.displayCounter = (e, $scope) ->
    date = $scope.date
    return if moment(date) > moment()

    # Disable scroll
    e.gesture.srcEvent.preventDefault()

    # Event values
    radius  = e.gesture.distance
    centerX = e.gesture.startEvent.center.pageX
    centerY = e.gesture.startEvent.center.pageY
    screenW = window.innerWidth
    screenH = window.innerHeight

    x0 = 10
    x1 = 0.8 * Math.sqrt(Math.pow(screenW, 2) + Math.pow(screenH, 2)) / 2
    maxValue = 100

    if radius < 25
      value = -1
    else if radius > x1
      value = maxValue
    else
      a = maxValue / Math.pow(x1 - x0, 3)
      value = Math.round(a * Math.pow(radius - x0, 3))

    # Save the counter value (will be persisted after the release event)
    if Config.dirty.counterValue == null
      Config.dirty.counterValue = Logs.getValue($scope.log, date)
    Logs.setValue($scope.log, date, value)

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

    clearTimeout(Config.dirty.timeout)
    Config.dirty.shouldSave = false

    Config.dirty.timeout = setTimeout(->
      counter.addClass("stable")
      Config.dirty.shouldSave = true
    , 500)

    counter
      .html(content)
      .removeClass("stable")
      .css({
        display: "block",
        top:    "#{ counterTop  }px",
        left:   "#{ counterLeft }px",
        width:  "#{ counterSize }px",
        height: "#{ counterSize }px",
        "font-size":     "#{ fontSize      }px",
        "line-height":   "#{ counterSize   }px",
        "border-radius": "#{ counterRadius }px"
      })

  $scope.hideCounter = (e, $scope) ->
    date = $scope.date

    # Save the counter value
    if Config.dirty.shouldSave != true
      Logs.setValue($scope.log, date, Config.dirty.counterValue)

    # Save the max counter value
    maxValue = Logs.getMaxValue($scope.log)
    $scope.log.maxValue = Logs.getMaxValue($scope.log)
    Logs.save($scope.logs)

    # Clear dirty attributes
    Config.dirty.counterValue = null
    clearTimeout(Config.dirty.timeout)
    Config.dirty.shouldSave = false

    # Hide the circle with the counter
    angular.element(document.getElementById("counter")).css(display: "none")


  # Use the lightContent statusbar (light text, for dark backgrounds)
  if window.StatusBar
    if Config.lightThemeIds.indexOf($scope.log.themeId) == -1
      StatusBar.styleLightContent()
    else
      $timeout(StatusBar.styleDefault, 400)
