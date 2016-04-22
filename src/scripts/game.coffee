require './message_bus'
_       = require 'lodash'
{ Alert, Plane, Airport, Loyalty, Player, Route } = require '../data'

instance = null

class Game
  @instance = ->
    if not instance
      instance ?= new Game
      instance.step()

    instance

  constructor: ->
    MessageBus.subscribe( @, 'landed', @onPlaneLanded)
    MessageBus.subscribe( @, '*', @step)

  start: -> @step('start')

  step: (args...) ->
    player.step(args...) for player in Player.list or []

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
    plane.location = plane.location.split('->')[1]
    MessageBus.publish 'landed', plane
    MessageBus.publish 'dataChange'
    console.log "landed in #{plane.location}!"

  buyPlane: (player) ->
    Plane.createFor( player )
    player.money -= 300
    MessageBus.publish 'dataChange'

  onPlaneLanded: (plane) =>
    console.log 'handling!'

    # Every flight increases our flown count
    # @todo retire planes flown > 4
    plane.flights_flown++

    # Reward every landing
    owner = plane.owner
    owner.money += 100

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

    if owner.money >= 300
      # Buy more planes!
      @buyPlane(owner)

    # Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')
    if Airport.where(owner: Player.pink()).length == 0
      Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')

    else if Airport.where(owner: Player.blue()).length == 0
      Alert.create(message: 'Oops, it seems youve been out-tycooned!')

    MessageBus.publish 'dataChange'

module.exports = Game