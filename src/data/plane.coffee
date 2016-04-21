_     = require 'lodash'
Model = require './model.coffee'

class Plane extends Model
  @at: (location) ->
    plane for plane in Plane.list when plane.location == location

  @for: (player) ->
    plane for plane in Plane.list when plane.owner == player

module.exports = Plane