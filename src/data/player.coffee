_       = require 'lodash'
Model   = require './model'
Airport = require './airport'

pink = '#d5a6bd'
blue = '#9fc5e8'
grey = '#eeeeee'

class Player extends Model
  @blue = ->
    @find(name: 'Blue')

  @pink = ->
    @find(name: 'Pink')

  @none = ->
    @find(name: 'None')

  @active = ->
    _.without @list, @none()

  step: (cb = ->) ->
    return cb() unless @brain
    @brain.nextMove cb

  setHQ: (location) ->
    @hq = @claimLocation location

  claimLocation: (location) ->
    location.owner = @
    location

  implant: (brain) ->
    @brain       = brain
    @brain.owner = @

  toJSON: ->
    _.pick @, 'name', 'color', 'money'

Player.create [
  { name: 'Blue', color: blue, money: 0 }
  { name: 'Pink', color: pink, money: 0 }
  { name: 'None', color: grey, money: 0 }
]


module.exports = Player