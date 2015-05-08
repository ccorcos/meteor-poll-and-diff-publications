names = ["chet", "joe", "charlie", "devon", "luke", "ryan", "bret", "andrew", "kyle", "nick", "carl", "meghan", "leslie", "lisa", "carley", "alice"]

Meteor.startup =>
  if Players.find().count() is 0
    for name in names
      Players.insert({name})

# this class will handle observing, publishing, and diffing when
# you want to observe a new cursor. If you want to accumulate results
# over the course of the publication, set accumulate to true.
class CursorObserver
  constructor: (@sub, @collection, @key, @getCursor, @accumulate=false) ->
    @ids = []
    @handle = null
    @sub.onStop =>
      @handle?.stop?()

  observe: (newIds) ->
    if @accumulate
      # accumulate all documents
      newIds = R.union(newIds, @ids)
    else
      # remove the stale docs
      removeIds = R.difference(@ids, newIds)
      for id in removeIds
        @sub.removed(@collection, id)

    # don't add the same doc twice!
    addIds = R.difference(newIds, @ids)
    cursor = @getCursor(newIds)

    @handle?.stop?()
    @handle = cursor.observeChanges 
      added: (id, fields) =>
        if R.contains(id, addIds)
          fields[@key] = true
          @sub.added(@collection, id, fields)
      changed: (id, fields) =>
        @sub.changed(@collection, id, fields)
      removed: (id) =>
        @sub.removed(@collection, id)
    
    @ids = newIds


getPlayersCursor = (x) ->
  Players.find({_id:{$in:x}})

N = 5
S = 3

# sample N playerIds
poll = () ->
  _.pluck(_.sample(Players.find({}, {fields:{_id:1}}).fetch(), N), '_id')

Meteor.publish 'feed1', ->
  observer = new CursorObserver(this, 'players', 'feed1', getPlayersCursor, true)
  publish = ->
    playerIds = poll()
    observer.observe(poll())
  publish()
  id = Meteor.setInterval(publish, S*1000)
  @ready()
  @onStop ->
    Meteor.clearInterval(id)
  return

Meteor.publish 'feed2', ->
  observer = new CursorObserver(this, 'players', 'feed2', getPlayersCursor, true)
  publish = ->
    playerIds = poll()
    observer.observe(poll())
  publish()
  id = Meteor.setInterval(publish, S*1000)
  @ready()
  @onStop ->
    Meteor.clearInterval(id)
  return


