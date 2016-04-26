_     = require 'lodash'
$     = require 'jquery'
Brain = require './brain'
Game  = require('./game').instance()

{ Plane } = require '../data'

class ApiBrain extends Brain
  constructor: (@url) ->

  nextMove: (cb = ->) ->
    # TODO - replace this Mock with something like $.post
    $.ajax(
      type        : 'POST'
      url         : @url
      data        : JSON.stringify( Game.toJSON() )
      contentType : 'application/json; charset=utf-8'
      dataType    : 'json'
    ).done (data) =>

      try
        @processAPICommands( data )

      catch err
        console.error "ERR on req:", err

      cb()

  # Expected format:
  # [
  #    { name: "Plane1", location: "NYC->LHR" }
  # ]
  processAPICommands: (planeInstructionList) ->
    log = (str) ->
      console.warn "Skipping Plane Instruction:", str
      false

    parseRoute = (str) ->
      return log("Invalid Location")        unless _.isString( str )
      return log("Invalid Location Format") unless _.includes( str, '->' )
      return log("Invalid Location Format") unless ( bits = str.split('->') ).length is 2
      start : bits[0]
      end   : bits[1]

    _.each planeInstructionList, (data) =>
      instruction  = _.pick data, 'name', 'location'

      return unless route = parseRoute( instruction.location )
      return log("Can't find Plane for Player")      unless plane = Plane.find(name: instruction.name, owner: @owner)
      return log("Plane cannot fly route requested") unless plane.location is route.start

      plane.scheduleFlight route.end

module.exports = ApiBrain