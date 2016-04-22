_     = require 'lodash'
Model = require './model.coffee'

class Route extends Model


Route.create [
  { key: 'NYC->LHR', name: 'NYC->LHR', start: 'NYC', end: 'LHR', x: 450, y: 240 },
  { key: 'LHR->NYC', name: 'LHR->NYC', start: 'LHR', end: 'NYC', x: 472, y: 326 },
  { key: 'LHR->DUB', name: 'LHR->DUB', start: 'LHR', end: 'DUB', x: 710, y: 280 },
  { key: 'DUB->LHR', name: 'DUB->LHR', start: 'DUB', end: 'LHR', x: 660, y: 340 },
  { key: 'DUB->NYC', name: 'DUB->NYC', start: 'DUB', end: 'NYC', x: 582, y: 380 },
  { key: 'NYC->DUB', name: 'NYC->DUB', start: 'NYC', end: 'DUB', x: 573, y: 444 },
  { key: 'DUB->MEL', name: 'DUB->MEL', start: 'DUB', end: 'MEL', x: 573, y: 444 },
  { key: 'MEL->DUB', name: 'MEL->DUB', start: 'MEL', end: 'DUB', x: 873, y: 744 },
]

module.exports = Route

