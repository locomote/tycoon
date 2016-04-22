_    = require 'lodash'
Game = require('./game').instance()
{ Plane, Route, Player, Loyalty, Airport } = require '../data'

class Brain
  constructor: (@owner) ->

  nextMove: (gameEvent, eventData) ->
    # if we wanted to we could determine where to move based on
    # the gamEvent being raised - for now - we will just movePlanes
    # on all events
    @movePlane()

  movePlane: ->
    return unless plane   = _.sample @myStationaryPlanes()
    return unless airport = @bestDestinationFor plane
    plane.location = "#{plane.location}->#{airport.name}"
    MessageBus.publish 'dataChange'

  bestDestinationFor: (plane) ->
    flyableAirportIn = (list) ->
      airports = _.filter list, (airport) -> airport.location isnt plane.location
      _.sample airports

    flyableAirportIn( @otherAirports() ) or flyableAirportIn( @myAirports() )

  # airports
  myAirports    : -> @my Airport
  freeAirports  : -> @free Airport
  enemyAirports : -> @enemy Airport
  otherAirports : -> @other Airport

  # planes
  myPlanes    : -> @my Plane
  freePlanes  : -> @free Plane
  enemyPlanes : -> @enemy Plane
  otherPlanes : -> @other Plane
  myStationaryPlanes: -> _.filter @myPlanes(), (plane)-> not plane.isFlying()

  my: (model)->
    model.where( owner: @owner )

  free: (model) ->
    model.where( owner: Player.none() )

  enemy: (model) ->
    _.filter model.list, (a) => a.owner isnt @owner and a.owner isnt Player.none()

  other: (model)->
    _.filter model.list, (a) => a.owner isnt @owner



module.exports = Brain