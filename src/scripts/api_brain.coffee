_     = require 'lodash'
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
    MockPostRequest Game.toJSON(), (response) =>
      @processAPICommands( response )
      cb()

  processAPICommands: (response) ->
    console.warn 'Process Api Commands not implemented'

module.exports = ApiBrain