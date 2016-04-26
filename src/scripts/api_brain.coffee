_     = require 'lodash'
$     = require 'jquery'
Brain = require './brain'
Game  = require('./game').instance()

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
      url         : 'http://localhost:9090/next_turn'
      data        : JSON.stringify( Game.toJSON() )
      contentType : 'application/json; charset=utf-8'
      dataType    : 'json'
    ).done (data) =>

      try
        @processAPICommands( data )

      catch err
        console.error "ERR on req:", err

      cb()


  processAPICommands: (response) ->
    console.warn 'Process Api Commands not implemented'

module.exports = ApiBrain