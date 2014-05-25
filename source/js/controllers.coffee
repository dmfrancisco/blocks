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

  $scope.setValue = (dayOfWeek, weekNo) ->
    date = Utils.getDate(dayOfWeek, weekNo).format("YYYY-MM-DD")

    $scope.log.values[date] = $scope.log.values[date] or 0
    $scope.log.values[date] = ($scope.log.values[date] + 1) % 6
    Logs.save($scope.logs)

  $scope.dateTip = (dayOfWeek, weekNo) ->
    date = Utils.getDate(dayOfWeek, weekNo)

    if date.format("D") is "1" and date.format("M") is "1"
      return date.format("YYYY")
    else if date.format("D") is "1"
      return date.format("MMM")
    else if date.day() is 1 and weekNo is 0
      return "M"
    else if date.day() is 3 and weekNo is 0
      return "W"
    else if date.day() is 5 and weekNo is 0
      return "F"

  $scope.getColor = (dayOfWeek, weekNo) ->
    date = Utils.getDate(dayOfWeek, weekNo)
    return "" if date > moment()

    date = date.format("YYYY-MM-DD")
    return "color-#{ $scope.log.values[date] or 0 }"

  $scope.weeks = [ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ]
  $scope.weekdays = [ 0,1,2,3,4,5,6 ]
  $scope.hasMoreData = true

  $scope.loadMore = ->
    for i in [0..16]
      $scope.weeks.push($scope.weeks.length)

    if $scope.weeks.length >= 336
      $scope.hasMoreData = false

    $scope.$broadcast("scroll.infiniteScrollComplete")

  # Use the lightContent statusbar (light text, for dark backgrounds)
  if window.StatusBar
    if Config.lightThemeIds.indexOf($scope.log.themeId) == -1
      StatusBar.styleLightContent()
    else
      $timeout(StatusBar.styleDefault, 400)
