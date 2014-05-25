# Directive for an underlay for the status bar
Application.directive "fadeBar", ->
  restrict: "E"
  template: "<div class=\"fade-bar\"></div>"
  replace: true
