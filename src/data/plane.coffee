_     = require 'lodash'
Model = require './model.coffee'

class Plane extends Model
  @at: (location) ->
    plane for plane in Plane.list when plane.location == location

  @for: (player) ->
    plane for plane in Plane.list when plane.owner == player

  @createFor = (owner) ->
    rnd = Math.random().toString(36).replace(/[^0-9a-f]+/g, '').substr(0, 6)
    Plane.create( name: "Plane-#{rnd}", flights_flown: 0, location: owner.hq.name, owner: owner )

module.exports = Plane