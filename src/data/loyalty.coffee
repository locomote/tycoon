_     = require 'lodash'
Model = require './model.coffee'

class Loyalty extends Model
  @for: (airport) ->
    loyalty for loyalty in Loyalty.list when loyalty.location == airport.name

module.exports = Loyalty
