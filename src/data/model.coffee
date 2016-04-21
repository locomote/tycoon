class Model

  @create: (attrs) ->
    new this(props) for props in _.flatten( [ attrs ] )

  constructor: (attrs) ->
    @constructor.list ?= []
    @constructor.list.push @
    _.extend @, attrs

module.exports = Model