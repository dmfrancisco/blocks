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
    newLog: function(logTitle, logThemeId, logValues) {
      return {
        title: logTitle,
        themeId: logThemeId,
        values: (logValues || {})
      };
    }
  }
})

.controller('LogIndexController', function($scope, $ionicModal, $ionicActionSheet, $timeout, Logs) {
  // Load or initialize logs
  $scope.logs = Logs.all();

  // Load themes (for the new form)
  $scope.themes = Config.themes;

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
    var newLog = Logs.newLog(log.title, log.themeId);
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
    $scope.log = { title: null, themeId: Config.themes[0].id }

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
    $ionicActionSheet.show({
      destructiveText: 'Remove <strong>'+ log.title.toLowerCase() +'</strong> log',
      cancelText: 'Cancel',
      destructiveButtonClicked: function() {
        var index = $scope.logs.indexOf(log);
        $scope.logs.splice(index, 1);
        Logs.save($scope.logs);
        return true;
      }
    })
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

.controller('LogController', function($scope, $stateParams, $timeout, Logs) {
  $scope.logIndex = $stateParams.id;
  $scope.logs = Logs.all();
  $scope.log = $scope.logs[$scope.logIndex];

  $scope.setValue = function(dayOfWeek, weekNo) {
    var date = Config.getDate(dayOfWeek, weekNo);
    date = date.format('YYYY-MM-DD');

    $scope.log.values[date] = $scope.log.values[date] || 0;
    $scope.log.values[date] = ($scope.log.values[date] + 1) % 6;
    Logs.save($scope.logs);
  }

  $scope.dateTip = function(dayOfWeek, weekNo) {
    var date = Config.getDate(dayOfWeek, weekNo);

    if (date.format("D") == "1" && date.format("M") == "1") {
      return date.format("YYYY");
    } else if (date.format("D") == "1") {
      return date.format("MMM");
    } else if (date.day() == 1 && weekNo == 0) {
      return "M";
    } else if (date.day() == 3 && weekNo == 0) {
      return "W";
    } else if (date.day() == 5 && weekNo == 0) {
      return "F";
    }
  }

  $scope.getColor = function(dayOfWeek, weekNo) {
    var date = Config.getDate(dayOfWeek, weekNo);

    if (date > moment()) {
      return "";
    } else {
      date = date.format('YYYY-MM-DD');
      return "color-" + ($scope.log.values[date] || 0); // TODO
    }
  }

  $scope.weeks = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
  $scope.weekdays = [0,1,2,3,4,5,6];
  $scope.hasMoreData = true;

  $scope.loadMore = function() {
    for (var i = 0; i < 8; i++) {
      $scope.weeks.push($scope.weeks.length);
    }
    if ($scope.weeks.length >= 336) {
      $scope.hasMoreData = false;
    }
    $scope.$broadcast('scroll.infiniteScrollComplete');
  }

  // Use the lightContent statusbar (light text, for dark backgrounds)
  if (window.StatusBar) {
    var themeIsLight = Config.lightThemeIds.indexOf($scope.log.themeId) == -1;

    if (themeIsLight) {
      StatusBar.styleLightContent();
    } else {
      $timeout(StatusBar.styleDefault, 400);
    }
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
Config = (function () {
  var genericColorClasses = [
    "color-bgd",
    "color-1",
    "color-2",
    "color-3",
    "color-4",
    "color-5"
  ],

  themes = [
    {
      id: "ruby",
      title: "Ruby",
      colorClasses: genericColorClasses
    }, {
      id: "purple",
      title: "Example",
      colorClasses: genericColorClasses
    }, {
      id: "sulek",
      title: "Sülek",
      colorClasses: genericColorClasses
    }, {
      id: "octocat",
      title: "Octocat",
      colorClasses: genericColorClasses
    }
  ],

  // If the theme has a light background, a dark status bar will be used (iOS 7)
  lightThemeIds = [
    "octocat"
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
  },

  getDate = function(dayOfWeek, weekNo) {
    return moment().day(dayOfWeek - 7 * weekNo);
  }

  return {
    themes: themes,
    lightThemeIds: lightThemeIds,
    genRandomPlaceholder: genRandomPlaceholder,
    getDate: getDate
  };
}());
