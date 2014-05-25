Config = ->
  genericColorClasses = [
    "color-bgd"
    "color-1"
    "color-2"
    "color-3"
    "color-4"
    "color-5"
  ]

  return {
    # Available themes (color palettes)
    themes: [
      {
        id: "ruby"
        title: "Ruby"
        colorClasses: genericColorClasses
      }
      {
        id: "purple"
        title: "Example"
        colorClasses: genericColorClasses
      }
      {
        id: "sulek"
        title: "Sülek"
        colorClasses: genericColorClasses
      }
      {
        id: "octocat"
        title: "Octocat"
        colorClasses: genericColorClasses
      }
    ]

    # If the theme has a light background, a dark status bar will be used (iOS 7)
    lightThemeIds: [
      "octocat"
    ]

    # A list of placeholders to show in the log title input
    titlePlaceholders: [
      "exercise"
      "read"
      "journal"
      "steps"
      "sleep time"
      "pomodoros"
      "cash spent"
      "cups of water"
    ]

    # Sounds used in the application
    sounds: {
      created:   new Audio("sounds/qurazy_quoin.mp3")
      destroyed: new Audio("sounds/friend_exits.mp3")
    }
  }

window.Config = new Config()
