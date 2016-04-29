_     = require 'lodash'
Model = require './model.coffee'

class Route extends Model
  toJSON: ->
    _.pick @, 'key', 'name', 'start', 'end', 'flightValue'


Route.create [
  { key: 'NYC->LHR', name: 'NYC->LHR', start: 'NYC', end: 'LHR', flightValue: 200, x: 450, y: 240 },
  { key: 'LHR->NYC', name: 'LHR->NYC', start: 'LHR', end: 'NYC', flightValue: 200, x: 472, y: 326 },
  { key: 'LHR->DUB', name: 'LHR->DUB', start: 'LHR', end: 'DUB', flightValue: 150, x: 710, y: 280 },
  { key: 'DUB->LHR', name: 'DUB->LHR', start: 'DUB', end: 'LHR', flightValue: 150, x: 660, y: 340 },
  { key: 'DUB->NYC', name: 'DUB->NYC', start: 'DUB', end: 'NYC', flightValue: 100, x: 582, y: 380 },
  { key: 'NYC->DUB', name: 'NYC->DUB', start: 'NYC', end: 'DUB', flightValue: 100, x: 573, y: 444 },
  { key: 'DUB->MEL', name: 'DUB->MEL', start: 'DUB', end: 'MEL', flightValue: 50, x: 573, y: 444 },
  { key: 'MEL->DUB', name: 'MEL->DUB', start: 'MEL', end: 'DUB', flightValue: 50, x: 873, y: 744 },
  { key: 'MEL->PEK', name: 'MEL->PEK', start: 'MEL', end: 'PEK', flightValue: 200, x: 873, y: 744 },
  { key: 'PEK->MEL', name: 'PEK->MEL', start: 'PEK', end: 'MEL', flightValue: 200, x: 873, y: 744 },
]

module.exports = Route

