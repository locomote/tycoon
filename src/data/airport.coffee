_     = require 'lodash'
Model = require './model.coffee'

class Airport extends Model
  @selected: ->
    _.find @list, selected: true

  @deselectAll = ->
    airport.selected = false for airport in @list

  @selectByKey = (airportCode) ->
    @deselectAll()
    airport.selected = true  for airport in @list when airport.name is airportCode

Airport.create [
  {key: 'NYC', name: 'NYC', left: 330, top:  300, customers: 200, selected: false },
  {key: 'LHR', name: 'LHR', left: 580, top:  250, customers: 200, selected: false },
  {key: 'DUB', name: 'DUB', left: 770, top:  380, customers: 200, selected: false }
]

module.exports = Airport