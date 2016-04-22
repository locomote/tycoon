_      = require 'lodash'
Model  = require './model'
Player = require './player'

class Loyalty extends Model

Loyalty.create [
  { location: 'NYC', amount: 0, owner: Player.blue() },
  { location: 'LHR', amount: 0, owner: Player.blue() },
  { location: 'DUB', amount: 0, owner: Player.blue() },
  { location: 'MEL', amount: 0, owner: Player.blue() }
  { location: 'PEK', amount: 0, owner: Player.blue() },
  { location: 'NYC', amount: 0, owner: Player.pink() },
  { location: 'LHR', amount: 0, owner: Player.pink() },
  { location: 'DUB', amount: 0, owner: Player.pink() },
  { location: 'MEL', amount: 0, owner: Player.pink() },
  { location: 'PEK', amount: 0, owner: Player.pink() },
]

module.exports = Loyalty
