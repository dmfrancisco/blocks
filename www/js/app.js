angular.module('logr', ['ionic'])

.config(function($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('app', {
    url: "/app",
    abstract: true,
    templateUrl: "index.html"
  })
  .state('app.logs', {
    url: "/logs",
    views: {
      'main': {
        templateUrl: "logs.html",
        controller: 'LogIndexController'
      }
    }
  })
  .state('app.log', {
    url: "/log/:id",
    views: {
      'main': {
        templateUrl: "log.html",
        controller: 'LogController'
      }
    }
  });

  $urlRouterProvider.otherwise("/app/logs");
})

// The Logs factory handles saving and loading logs from local storage
.factory('Logs', function() {
  return {
    all: function() {
      var logString = window.localStorage['logs'];
      if (logString) {
        return angular.fromJson(logString);
      }
      return [];
    },
    save: function(logs) {
      window.localStorage['logs'] = angular.toJson(logs);
    },
    newLog: function(logTitle) {
      return {
        title: logTitle
      };
    }
  }
})

.controller('LogIndexController', function($scope, $ionicModal, $timeout, Logs) {
  // Load or initialize logs
  $scope.logs = Logs.all();

  // Create and load the Modal
  $ionicModal.fromTemplateUrl('new-log.html', function(modal) {
    $scope.logModal = modal;
  }, {
    scope: $scope,
    animation: 'custom-slide-in-up'
  });

  // Called when the form is submitted
  $scope.createLog = function(log) {
    var newLog = Logs.newLog(log.title);
    $scope.logs.push(newLog);
    $scope.logModal.hide();
    Logs.save($scope.logs);
    log.title = "";
  };

  // Open our new log modal
  $scope.newLog = function() {
    $scope.logModal.show();

    $timeout(function() {
      $scope.$broadcast('scroll.refreshComplete');
    }, 500);
  };

  // Close the new log modal
  $scope.closeNewLog = function() {
    $scope.logModal.hide();
  };

  // Use the lightContent statusbar (light text, for dark backgrounds)
  if (window.StatusBar) {
    StatusBar.styleLightContent();
  }
})

.controller('LogController', function($scope, $stateParams, Logs) {
  $scope.activeLogIndex = $stateParams.id;
  $scope.logs = Logs.all();
  $scope.activeLog = $scope.logs[$scope.activeLogIndex];

  // Use the lightContent statusbar (light text, for dark backgrounds)
  if (window.StatusBar) {
    StatusBar.styleLightContent();
  }
})

// Directive for an underlay for the status bar
.directive('fadeBar', function() {
  return {
    restrict: 'E',
    template: '<div class="fade-bar"></div>',
    replace: true,
    link: function($scope, $element, $attr) { }
  }
})

.run(function($ionicPlatform) {
  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the
    // accessory bar above the keyboard for form inputs)
    if (window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    }
    if (window.StatusBar) {
      StatusBar.styleLightContent();
      StatusBar.show();
    }
  });
});

// Wait for Cordova to load
document.addEventListener("deviceready", function() {
  setTimeout(function() {
    navigator.splashscreen.hide();
  }, 5000);
}, false);
