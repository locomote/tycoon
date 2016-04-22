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

  step: (args...) ->
    @brain?.nextMove args...

  claimLocation: (location) ->
    @hq       = location
    @hq.owner = @

  implant: (brain) ->
    @brain       = brain
    @brain.owner = @

Player.create [
  { name: 'Blue', color: blue, money: 0 }
  { name: 'Pink', color: pink, money: 0 }
  { name: 'None', color: grey, money: 0 }
]


module.exports = Player