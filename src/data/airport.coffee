_     = require 'lodash'
Model = require './model.coffee'

class Airport extends Model
  @selected: ->
    _.find @list, selected: true

  @deselectAll: ->
    airport.selected = false for airport in @list

  @selectByKey: (airportCode) ->
    @deselectAll()
    airport.selected = true  for airport in @list when airport.name is airportCode

Airport.create [
  { key: 'NYC', name: 'NYC', x: 330, y: 300, customers: 200, selected: false },
  { key: 'LHR', name: 'LHR', x: 580, y: 250, customers: 200, selected: false },
  { key: 'DUB', name: 'DUB', x: 770, y: 380, customers: 200, selected: false }
]

module.exports = Airport
