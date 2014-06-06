# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic", "pouchdb"])


# The Logs factory handles saving and loading logs from local storage
@App.factory "Logs", (pouchdb) ->
  db = pouchdb.create("logr-db")
  cache = { logs: [], logsById: {} }
  obj = {}

  obj.all = ($scope) ->
    $scope.logs ||= cache.logs

    db.allDocs(include_docs: true).then (response) ->
      cache.logs = []
      angular.forEach response.rows, (row) ->
        cache.logs.push(row.doc)
        cache.logsById[row.doc._id] = row.doc
      $scope.logs = cache.logs
    .catch (error) ->
      console.log error

    return true

  obj.all(cache)

  obj.get = ($scope, id, callback) ->
    $scope.log = cache.logsById[id] || $scope.log
    db.get(id).then callback

  obj.create = ($scope, log) ->
    log.position = $scope.logs.length

    db.post(log).then (response) ->
      log._id = response.id
      log._rev = response.rev
      $scope.logs.push log
    .catch (error) ->
      console.log error

  obj.update = ($scope, log) ->
    db.put(log).then (response) ->
      log._rev = response.rev
    .catch (error) ->
      console.log error

  obj.remove = ($scope, log) ->
    db.remove(log).then (response) ->
      index = $scope.logs.indexOf(log)
      $scope.logs.splice(index, 1)
    .catch (error) ->
      console.log error

  obj.newLog = (logTitle, logThemeId) ->
    return {
      title:    logTitle
      themeId:  logThemeId
      values:   {}
      maxValue: 0
    }

  obj.getValue = (log, date) ->
    value = log.values[date.toDateString()]
    return -1 if value is undefined
    return value

  obj.setValue = (log, date, value) ->
    if value == -1
      delete log.values[date.toDateString()]
    else
      log.values[date.toDateString()] = value
    updateMaxValue(log)

  updateMaxValue = (log, maxValue = 0) ->
    angular.forEach log.values, (value) ->
      maxValue = Math.max(value or 0, maxValue)
    log.maxValue = maxValue

  return obj
