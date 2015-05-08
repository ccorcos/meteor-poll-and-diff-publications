Session.setDefault("show", true)

Template.main.events
  'click button': () ->
    Session.set('show', not Session.get('show'))

Template.main.helpers
  show: () ->
    Session.get('show')



sameId = (a,b) -> 
  a._id is b._id

preserveDocumentOrder = (prev, next) ->
  withoutPrev = R.filter(R.complement(R.containsWith(sameId, R.__, prev)))
  newDocs = withoutPrev(next)
  prev.concat(newDocs)

Template.list.onCreated ->
  @order = new ReactiveVar([])

Template.list.onRendered ->
  @autorun ->
    Meteor.subscribe 'feed'

  @autorun =>
    results = Players.find({}, {sort:{name:1}}).fetch()
    Tracker.nonreactive =>
      @order.set preserveDocumentOrder(@order.get(), results)

Template.list.helpers
  players: ->
    Template.instance().order.get()
    
    
    