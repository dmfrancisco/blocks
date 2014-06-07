# Allow scripts to be included in any order
@App ||= angular.module("blocks", ["ionic", "pouchdb"])


# The Logs factory handles saving and loading logs from local storage
@App.factory "Logs", (pouchdb) ->
  logsDB   = pouchdb.create("dbv0-logs")
  valuesDB = pouchdb.create("dbv0-values")

  cache = { logs: [], logsById: {} }
  obj = {}

  obj.all = ($scope = cache, callback) ->
    $scope.logs ||= cache.logs

    logsDB.allDocs(include_docs: true).then (response) ->
      cache.logs = []
      angular.forEach response.rows, (row) ->
        cache.logs.push(row.doc)
        cache.logsById[row.doc._id] = row.doc
      $scope.logs = cache.logs
    .catch (error) ->
      console.log error

    callback() unless callback is `undefined`
    return true

  obj.get = ($scope, id, callback) ->
    $scope.log = cache.logsById[id] || $scope.log

    logsDB.get(id).then (log) ->
      valuesDB.get(id).then (values) ->
        log._rev = log._rev
        log._values_rev = values._rev
        log.values   = values.values
        log.maxValue = values.maxValue

        $scope.log = log

        callback() unless callback is `undefined`

      .catch (error) ->
        console.log error
    .catch (error) ->
      console.log error

  obj.create = ($scope, log) ->
    log.position = $scope.logs.length

    logsDB.post({
      title:    log.title
      themeId:  log.themeId
      position: log.position
    }).then (response) ->
      log._id  = response.id
      log._rev = response.rev
      $scope.logs.push log

      valuesDB.put({
        values:   log.values
        maxValue: log.maxValue
      }, log._id).then (values) ->
        log._values_rev = values.rev

      .catch (error) ->
        console.log error
    .catch (error) ->
      console.log error

  obj.update = ($scope, log) ->
    valuesDB.put({
      _id:      log._id
      _rev:     log._values_rev
      values:   log.values
      maxValue: log.maxValue
    }).then (response) ->
      log._values_rev = response.rev
    .catch (error) ->
      console.log error

    logsDB.put({
      _id:      log._id
      _rev:     log._rev
      title:    log.title
      themeId:  log.themeId
      position: log.position
    }).then (response) ->
      log._rev = response.rev
    .catch (error) ->
      console.log error

  obj.remove = ($scope, log) ->
    valuesDB.get(log._id).then (values) ->
      valuesDB.remove(values).catch (error) ->
        console.log error

    logsDB.remove(log).then ->
      index = $scope.logs.indexOf(log)
      $scope.logs.splice(index, 1)
    .catch (error) ->
      console.log error


  obj.newLog = (logTitle, logThemeId) ->
    return {
      title:    logTitle
      themeId:  logThemeId
      position: -1
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
