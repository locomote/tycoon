_      = require 'lodash'
Model  = require './model'
Player = require './player'
Route  = require './route'

class Plane extends Model
  @at: (location) ->
    plane for plane in Plane.list when plane.location == location

  @for: (player) ->
    plane for plane in Plane.list when plane.owner == player

  @createFor = (owner) ->
    rnd = Math.random().toString(36).replace(/[^0-9a-f]+/g, '').substr(0, 6)
    Plane.create( name: "Plane-#{rnd}", flights_flown: 0, location: owner.hq.name, owner: owner )

  @areAllLanded = ->
    not _.find( @list, (plane) -> plane.isFlying() )

  isFlying: ->
    _.includes @location, '->'

  scheduleFlight: (endAirportCode)->
    startAirportCode = @location
    routeKey = "#{startAirportCode}->#{endAirportCode}"
    return unless Route.find(key: routeKey)
    @location = routeKey

  toJSON: ->
    _.extend _.pick( @, 'name', 'flights_flown', 'location' ),
      owner: @owner?.name

Plane.create [
  {name: 'Plane1', flights_flown: 0, location: 'MEL', owner: Player.blue()},
  {name: 'Plane2', flights_flown: 0, location: 'MEL', owner: Player.blue()},
  {name: 'Plane3', flights_flown: 0, location: 'MEL', owner: Player.blue()},
  {name: 'Plane4', flights_flown: 0, location: 'NYC', owner: Player.pink()},
  {name: 'Plane5', flights_flown: 0, location: 'NYC', owner: Player.pink()},
  {name: 'Plane6', flights_flown: 0, location: 'NYC', owner: Player.pink()}
]

window.Plane = Plane
module.exports = Plane