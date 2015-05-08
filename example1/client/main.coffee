Template.main.onRendered ->
  @autorun ->
    Meteor.subscribe 'players'

Template.main.helpers
  players: ->
    Players.find({}, {sort:{name:1}})
    
    