# Directive for an underlay for the status bar
Application.directive "fadeBar", ->
  restrict: "E"
  template: "<div class=\"fade-bar\"></div>"
  replace: true

# New directive to handle the drag event (more info: http://goo.gl/JF5qYM)
Application.directive 'onDrag', ($ionicGesture) ->
  restrict: 'A',
  link: ($scope, $element, $attr) ->
    # If the user holds, the dragging will be enabled
    $ionicGesture.on 'hold', (-> Application.isDragging = true), $element

    handle = (e) ->
      # If the user swipes horizontally, the dragging will be enabled too
      if e.gesture.distance > 40 and e.gesture.distance - Math.abs(e.gesture.deltaX) < 10
        Application.isDragging = true

      if Application.isDragging == true
        $scope.$apply (self) ->
          self[$attr.onDrag](e, $scope, $element, $attr)

    gesture = $ionicGesture.on('drag', handle, $element)
    $scope.$on '$destroy', -> $ionicGesture.off(gesture, 'drag', handle)

Application.directive 'onDrop', ($ionicGesture) ->
  restrict: 'A',
  link: ($scope, $element, $attr) ->
    handle = (e) ->
      $scope.$apply (self) ->
        if Application.isDragging == true
          self[$attr.onDrop](e, $scope, $element, $attr)
        Application.isDragging = false

    gesture = $ionicGesture.on('release', handle, $element)
    $scope.$on '$destroy', -> $ionicGesture.off(gesture, 'release', handle)
