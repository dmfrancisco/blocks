# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic"])


@App.controller "LogIndexController", ($scope, $ionicModal, $ionicActionSheet, $timeout, Config, Utils, Logs) ->

  # Load or initialize logs
  $scope.logs = Logs.all()

  # Load themes (for the new form)
  $scope.themes = Config.themes

  # Initialize and load the creation modal
  $ionicModal.fromTemplateUrl("logs/new.html", ((modal) ->
      $scope.newLogModal = modal
    ),
    scope: $scope
    animation: "custom-slide-in-up"
  )

  # Called when the creation form is submitted
  $scope.createLog = (log) ->
    # If the user didn't filled the title, use the placeholder value
    log.title = $scope.randomPlaceholder unless log.title

    # Create the log
    newLog = Logs.newLog(log.title, log.themeId)
    $scope.logs.push newLog
    Logs.save $scope.logs

    # Play a sound and hide the modal
    Config.sounds.created.play()
    $scope.newLogModal.hide()

  # Open the new log modal
  $scope.newLog = ->
    # Display the modal
    $scope.newLogModal.show()

    # Pre-fill the form fields
    $scope.randomPlaceholder = Utils.genRandomPlaceholder(Config.titlePlaceholders)
    $scope.log = { title: null, themeId: Config.themes[0].id }

    # This modal is called by the pull-to-refresh component.
    # To improve the animation, call complete after some delay
    $scope.$broadcast("scroll.refreshComplete")

  # Close the new log modal
  $scope.closeNewLog = ->
    $scope.newLogModal.hide()


  # Initialize and load the creation modal
  $ionicModal.fromTemplateUrl("logs/edit.html", ((modal) ->
      $scope.editLogModal = modal
    ),
    scope: $scope
    animation: "custom-slide-in-up"
  )

  # Called when the edition form is submitted
  $scope.updateLog = (log) ->
    $scope.editLogModal.hide()

  # Edit log
  $scope.editLog = (log) ->
    # Display the modal
    $scope.log = log
    $scope.editLogModal.show()
    Logs.save($scope.logs)

  # Close the new log modal
  $scope.closeEditLog = ->
    $scope.editLogModal.hide()
    Logs.save($scope.logs)


  # Destroy log
  $scope.destroyLog = (log) ->
    $ionicActionSheet.show
      destructiveText: "Remove &nbsp;<strong>#{ Utils.removeEmoji(log.title) or "log" }</strong>"
      cancelText: "Cancel"

      destructiveButtonClicked: ->
        index = $scope.logs.indexOf(log)
        $scope.logs.splice(index, 1)
        Logs.save($scope.logs)

        Config.sounds.destroyed.play()
        return true


  # Use the lightContent statusbar (light text, for dark backgrounds)
  StatusBar.styleLightContent() if window.StatusBar
