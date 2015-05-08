names = ["chet", "joe", "charlie", "devon", "luke", "ryan", "bret", "andrew", "kyle", "nick", "carl", "meghan", "leslie", "lisa", "carley", "alice"]

Meteor.startup =>
  if Players.find().count() is 0
    for name in names
      Players.insert({name})

N = 5
S = 3

stopLast = (f) ->
  handle = null
  () ->
    handle?.stop?()
    handle = f()

publishCursor = (cursor, sub, collection) ->
  handle = cursor.observeChanges 
    added: (id, fields) ->
      sub.added(collection, id, fields)
    changed: (id, fields) ->
      sub.changes(collection, id, fields)
    removed: (id) ->
      sub.removed(collection, id)
  sub.onStop ->
    handle?.stop?()
  return handle

Meteor.publish 'players', ->
  players = Players.find({}, {fields:{_id:1}}).fetch()
  ids = _.pluck(players, '_id')
  sub = this

  poll = ->
    _.sample(ids, N)

  diff = (prev, next)->
    for id in R.difference(prev, next)
      sub.removed('players', id)

  prev = []
  publish = stopLast ->
    next = poll()
    diff(prev, next)
    prev = next
    cursor = Players.find({_id:{$in:prev}})
    publishCursor(cursor, sub, 'players')

  publish()
  id = Meteor.setInterval(publish, S*1000)
  sub.ready()
  sub.onStop ->
    Meteor.clearInterval(id)
  return