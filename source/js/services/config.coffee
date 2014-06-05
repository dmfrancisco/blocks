# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic", "pouchdb"])


# Configurations used across the application
@App.factory "Config", ->
  obj = {}

  genericColorClasses = [
    "color-bgd"
    "color-1"
    "color-2"
    "color-3"
    "color-4"
    "color-5"
  ]

  # Property to save temporary dirty properties
  obj.dirty = {}

  # Available themes (color palettes)
  obj.themes = [{
    id: "ruby"
    colorClasses: genericColorClasses
  }, {
    id: "purple"
    colorClasses: genericColorClasses
  }, {
    id: "sulek"
    colorClasses: genericColorClasses
  }, {
    id: "octocat"
    colorClasses: genericColorClasses
  }]

  # If the theme has a light background, a dark status bar will be used (iOS 7)
  obj.lightThemeIds = [
    "octocat"
  ]

  # A list of placeholders to show in the log title input
  obj.titlePlaceholders = [
    "exercise"
    "running"
    "read"
    "journal"
    "writing"
    "blog post"
    "drawing"
    "painting"
    "flossing"
    "inbox zero"
    "empty inbox"
    "homework"
    "steps"
    "gym"
    "workout"
    "social"
    "meditation"
    "sleep time"
    "hours slept"
    "bed early"
    "vitamins"
    "pomodoros"
    "focus"
    "cash spent"
    "water cups"
    "new skill"
    "drinking"
    "gas"
    "calories"
    "cake intake"
    "eat fruits"
    "hours worked"
    "commits"
    "joy levels"
    "breaks"
    "sodas today"
    "coffees"
    "coffees ☕️"
    "chocolate"
    "chocolate 🍫"
    "cookies"
    "cookies 🍪"
    "walk 🐶"
    "expenses 💰"
    "practice 🎵"
    "23pm 🌙"
    "6am 😴"
  ]

  # Sounds used in the application
  obj.sounds = {
    created:   new Howl(urls: ["sounds/poppyup-glass.mp3"])
    destroyed: new Howl(urls: ["sounds/bottle-pipe.mp3"])
  }

  # Number of weeks the app displays
  if window.innerHeight <= 480
    obj.initialWeeks = 9
    obj.totalWeeks = 26
  else
    obj.initialWeeks = 12
    obj.totalWeeks = 52

  return obj
