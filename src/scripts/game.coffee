require './message_bus'
_       = require 'lodash'
{ Alert, Plane, Airport, Loyalty, Player, Route } = require '../data'

PLANE_COST = 500
instance   = null

class Game
  @instance = ->
    if not instance
      instance ?= new Game

    instance

  start: ->
    delete @_stop
    @step()

  stop: ->
    @_stop = true

  step: (idx = 0) ->
    next = =>
      return if @_stop
      requestAnimationFrame @step.bind(@, idx)

    return next() unless player = Player.active()[ idx ]
    return next() unless Plane.areAllLanded()

    player.step ->
      return if @_stop
      MessageBus.publish 'dataChange'

      idx += 1
      idx  = 0 if idx % Player.active().length is 0
      next()

  selectAirport: (airportCode) ->
    Airport.selectByKey airportCode
    MessageBus.publish 'dataChange'

  deselectAirports: (airportCode) ->
    Airport.deselectAll()
    MessageBus.publish 'dataChange'

  scheduleFlight: (startAirportCode, endAirportCode) ->
    # @todo only send our own planes
    plane = _.first (Plane.at startAirportCode)
    routeKey = "#{startAirportCode}->#{endAirportCode}"
    return unless Route.find(key: routeKey)
    plane.location = routeKey
    MessageBus.publish 'dataChange'

  landPlane: (plane) ->
    # @todo flight ordering on landing
    return unless plane.isFlying()
    return unless route = Route.find(key: plane.location)

    plane.location = plane.location.split('->')[1]
    @processRewardsFor plane, route
    MessageBus.publish 'dataChange'

  buyPlane: (player) ->
    Plane.createFor( player )
    player.money -= PLANE_COST
    MessageBus.publish 'dataChange'

  processRewardsFor: (plane, route) =>
    return if @_stop
    # Every flight increases our flown count
    # @todo retire planes flown > 4
    plane.flights_flown++

    # Reward every landing
    owner = plane.owner
    owner.money += route.flightValue

    # Loyalty increases when Airport is not ours
    loyalty = Loyalty.find(location: plane.location, owner: owner)
    airport = Airport.find(name: plane.location)

    if airport.owner != owner
      loyalty.amount += 20

      # Airport becomes ours once loyalty reaches 100%
      if loyalty.amount >= 100
        owner.claimLocation airport

        # It's a big marketing win, all other loyalties take a hit!
        loyalty.amount = 0 for loyalty in Loyalty.where(location: airport.name)

    while owner.money >= PLANE_COST
      # Buy more planes!
      @buyPlane(owner)

    # Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')
    if Airport.where(owner: Player.pink()).length == 0
      @stop()
      Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')

    else if Airport.where(owner: Player.blue()).length == 0
      @stop()
      Alert.create(message: 'Oops, it seems youve been out-tycooned!')

    MessageBus.publish 'dataChange'

  toJSON: ->
    players  : Player.toJSON()
    loyalty  : Loyalty.toJSON()
    airports : Airport.toJSON()
    routes   : Route.toJSON()
    planes   : Plane.toJSON()



module.exports = Game