_     = require 'lodash'
$     = require 'jquery'
Brain = require './brain'
Game  = require('./game').instance()

{ Plane } = require '../data'

MockPostRequest = (gameState, cb) ->
  # TODO: formalise a response format that can be interpreted
  # as commands - processAPICommands should be able to read and action
  # an API response
  response = {}
  cb response

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

  processAPICommands: (planeInstructionList) ->
    parseRoute = (str) ->
      return unless _.isString( str )
      return unless _.includes( str, '->' )
      return unless ( bits = str.split('->') ).length is 2
      start : bits[0]
      end   : bits[1]

    _.each planeInstructionList, (data) =>
      instruction  = _.pick data, 'name', 'location'
      return unless route = parseRoute( instruction.location )
      return unless plane = Plane.find(name: instruction.name, owner: @owner)
      return unless plane.location is route.start

      plane.scheduleFlight route.end

module.exports = ApiBrain