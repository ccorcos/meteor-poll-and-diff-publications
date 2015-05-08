Session.setDefault("showFeed1", true)
Session.setDefault("showFeed2", true)

Template.main.events
  'click button.feed1': () ->
    Session.set('showFeed1', not Session.get('showFeed1'))
  'click button.feed2': () ->
    Session.set('showFeed2', not Session.get('showFeed2'))

Template.main.helpers
  showFeed1: () ->
    Session.get('showFeed1')
  showFeed2: () ->
    Session.get('showFeed2')
  countFeed1: () ->
    Players.find({feed1:true}).count()
  countFeed2: () ->
    Players.find({feed2:true}).count()
   

sameId = (a,b) -> 
  a._id is b._id

# filter the previous documents out of the new set of documents (by _id)
# and return the union of the set of documents, preserving the document 
# order of the previous set
preserveDocumentOrder = (prev, next) ->
  withoutPrev = R.filter(R.complement(R.containsWith(sameId, R.__, prev)))
  newDocs = withoutPrev(next)
  prev.concat(newDocs)


Template.feed1.onCreated ->
  @order = new ReactiveVar([])

Template.feed1.onRendered ->
  @autorun ->
    Meteor.subscribe 'feed1'

  # watch for changes to the cursor, and preserve document order.
  @autorun =>
    results = Players.find({feed1:true}, {sort:{name:1}}).fetch()
    Tracker.nonreactive =>
      @order.set preserveDocumentOrder(@order.get(), results)

Template.feed1.helpers
  players: ->
    Template.instance().order.get()


Template.feed2.onCreated ->
  @order = new ReactiveVar([])

Template.feed2.onRendered ->
  @autorun ->
    Meteor.subscribe 'feed2'

  @autorun =>
    results = Players.find({feed2:true}, {sort:{name:1}}).fetch()
    Tracker.nonreactive =>
      @order.set preserveDocumentOrder(@order.get(), results)

Template.feed2.helpers
  players: ->
    Template.instance().order.get()
    
    
    