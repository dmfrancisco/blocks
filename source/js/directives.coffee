# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic"])


# Directive for an underlay for the status bar
@App.directive "fadeBar", ->
  restrict: "E"
  template: "<div class=\"fade-bar\"></div>"
  replace: true


# New directive to handle the drag event (more info: http://goo.gl/JF5qYM)
@App.directive 'onDrag', ($ionicGesture) ->
  restrict: "A"
  link: ($scope, $element, $attr) ->
    handle = (e) ->
      $scope.$apply (self) ->
        self[$attr.onDrag](e, $scope, $element, $attr)

    # If the user holds, the dragging will be enabled
    holdGesture = $ionicGesture.on 'hold', ((e) ->
      window.isHolding = true
      handle(e)
    ), $element

    dragGesture = $ionicGesture.on 'drag', ((e) ->
      # If the user swipes horizontally, apply same behavior as holding
      if e.gesture.distance > 40 and e.gesture.distance - Math.abs(e.gesture.deltaX) < 10
        window.isHolding = true

      if window.isHolding
        window.isDragging = true
        handle(e)
    ), $element

    $scope.$on '$destroy', -> $ionicGesture.off(holdGesture, 'hold', handle)
    $scope.$on '$destroy', -> $ionicGesture.off(dragGesture, 'drag', handle)


# New directive to handle the drop event
@App.directive 'onRelease', ($ionicGesture) ->
  restrict: "A"
  link: ($scope, $element, $attr) ->
    handle = (e) ->
      $scope.$apply (self) ->
        if window.isDragging or window.isHolding
          self[$attr.onRelease](e, $scope, $element, $attr)
        window.isDragging = false
        window.isHolding = false

    gesture = $ionicGesture.on('release', handle, $element)
    $scope.$on '$destroy', -> $ionicGesture.off(gesture, 'release', handle)
