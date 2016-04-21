class Model

  @create: (attrs) ->
    new this(props) for props in _.flatten( [ attrs ] )

  @where: (attrs) ->
    _.filter @list, attrs

  @find: (attrs) ->
    _.find @list, attrs

  constructor: (attrs) ->
    @constructor.list ?= []
    @constructor.list.push @
    _.extend @, attrs

module.exports = Model
