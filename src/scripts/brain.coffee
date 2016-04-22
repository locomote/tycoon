_    = require 'lodash'
Game = require('./game').instance()
{ Plane, Route, Player, Loyalty, Airport } = require '../data'

# This would be were we can integrate an api - i.e. send a post to an applicants
# API with a JSON doc defining game state (i.e. locations, planes, player assets)
# and their api would decide what to do next and send back cmds... For now - Ill
# just code in the client side
class Brain
  constructor: (@owner) ->

  nextMove: (gameEvent, eventData) ->
    # if we wanted to we could determine where to move based on
    # the gamEvent being raised - for now - we will just movePlanes
    # on all events
    @movePlanes()

  movePlanes: ->
    return if _.isEmpty( planes = @myStationaryPlanes() )
    for plane in planes
      continue unless airport = @bestDestinationFor plane
      plane.location = "#{plane.location}->#{airport.name}"

    MessageBus.publish 'dataChange'

  bestDestinationFor: (plane) ->
    reachableAirportIn = (list) ->
      airports = _.filter list, (airport) ->
        routeKey = "#{plane.location}->#{airport.key}"
        !!Route.find(key: routeKey)

      _.sample airports

    reachableAirportIn( @otherAirports() ) or reachableAirportIn( @myAirports() )

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