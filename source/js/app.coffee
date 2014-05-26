window.Application = angular.module("logr", ["ionic"])


# Configure routes
Application.config ($stateProvider, $urlRouterProvider) ->

  $stateProvider.state "app",
    url: "/app"
    abstract: true
    templateUrl: "index.html"

  $stateProvider.state "app.logs",
    url: "/logs"
    views:
      main:
        templateUrl: "logs/index.html"
        controller: "LogIndexController"

  $stateProvider.state "app.log",
    url: "/log/:id"
    views:
      main:
        templateUrl: "logs/show.html"
        controller: "LogController"

  $urlRouterProvider.otherwise("/app/logs")


# Run the application
Application.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    # Hide the accessory bar by default (remove this to show the
    # accessory bar above the keyboard for form inputs)
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if window.StatusBar
      StatusBar.styleLightContent()
      StatusBar.show()


# Wait for Cordova to load
document.addEventListener("deviceready", (->
  setTimeout(navigator.splashscreen.hide, 5000)
), false)
