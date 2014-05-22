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
    newLog: function(logTitle, logPaletteId) {
      return {
        title: logTitle,
        paletteId: logPaletteId
      };
    }
  }
})

.controller('LogIndexController', function($scope, $ionicModal, $timeout, Logs) {
  // Load or initialize logs
  $scope.logs = Logs.all();

  // Load palettes (for the new form)
  $scope.palettes = Config.palettes;

  // Create and load the modal
  $ionicModal.fromTemplateUrl('new-log.html', function(modal) {
    $scope.logModal = modal;
  }, {
    scope: $scope,
    animation: 'custom-slide-in-up'
  });

  // Called when the form is submitted
  $scope.createLog = function(log) {
    // If the user didn't filled the title, use the placeholder value
    if (!log.title) log.title = $scope.randomPlaceholder;

    // Create the log
    var newLog = Logs.newLog(log.title, log.paletteId);
    $scope.logs.push(newLog);
    Logs.save($scope.logs);

    // Hide the modal
    $scope.logModal.hide();
  };

  // Open the new log modal
  $scope.newLog = function() {
    // Display the modal
    $scope.logModal.show();

    // Pre-fill the form fields
    $scope.randomPlaceholder = Config.genRandomPlaceholder();
    $scope.log = { title: null, paletteId: Config.palettes[0].id }

    // This modal is called by the pull-to-refresh component.
    // To improve the animation, call complete after some delay
    $timeout(function() {
      $scope.$broadcast('scroll.refreshComplete');
    }, 500);
  };

  // Edit log
  $scope.updateLog = function(log) {
    // TODO
  };

  // Destroy log
  $scope.destroyLog = function(log) {
    var index = $scope.logs.indexOf(log);
    $scope.logs.splice(index, 1);
    Logs.save($scope.logs);
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


// Configuration data
window.Config = (function () {
  var genericColorClasses = [
    "color-1",
    "color-2",
    "color-3",
    "color-4",
    "color-5"
  ],

  palettes = [
    {
      id: "example0",
      title: "Example",
      colorClasses: genericColorClasses
    }, {
      id: "example1",
      title: "Example",
      colorClasses: genericColorClasses
    }, {
      id: "example2",
      title: "Example",
      colorClasses: genericColorClasses
    }, {
      id: "github",
      title: "GitHub",
      colorClasses: genericColorClasses
    }
  ],

  titlePlaceholders = [
    "exercise",
    "read",
    "journal",
    "steps",
    "sleep time",
    "pomodoros",
    "cash spent",
    "cups of water"
  ],

  currentPlaceholderIndex = 0,

  // This method returns a random placeholder with repeating the values
  genRandomPlaceholder = function() {
    if (currentPlaceholderIndex == 0) {
      titlePlaceholders.sort(function() { return 0.5 - Math.random() });
    }
    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % titlePlaceholders.length;
    return titlePlaceholders[currentPlaceholderIndex];
  }

  return {
    palettes: palettes,
    genRandomPlaceholder: genRandomPlaceholder
  };
}());
