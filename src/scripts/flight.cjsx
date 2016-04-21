_                  = require 'lodash'
RenderInBody       = require './render_in_body'
Calc               = require './calculator.coffee'
{routes, airports} = require '../data'

FRAME_RATE = 60 #FPS

Flight = React.createClass
  maxSpeed: 2
  route: ->
    _.find routes, key: @props.plane.location

  locationCoordsFor: (locCode) ->
    loc = _.find airports, key: locCode
    x: loc.left
    y: loc.top

  startCoords: ->
    @locationCoordsFor @route()?.start

  endCoords: ->
    @locationCoordsFor @route()?.end

  componentDidMount: ->
    @props.plane.x ?= @startCoords().x
    @props.plane.y ?= @startCoords().y
    @animate()

  isAt: ({ x, y }) ->
    Math.abs(@props.plane.x - x) < 1 and Math.abs(@props.plane.y - y) < 1

  animate: ->
    target = @endCoords()
    {x, y} = @props.plane
    return if @isAt( target )

    maxStepDistance = @maxSpeed
    targetAngle     = Calc.angle(x, y, target.x, target.y) # angle
    tripDistance    = Calc.distance(x, y, target.x, target.y) # trip hypotenuse
    stepDistance    = _.min [ tripDistance, maxStepDistance ] # step hypotenuse

    xDistance       = Calc.offsetX(targetAngle, stepDistance)
    yDistance       = Calc.offsetY(targetAngle, stepDistance)

    @props.plane.angle = targetAngle
    @props.plane.x     += xDistance * Calc.axis(targetAngle).x
    @props.plane.y     += yDistance * Calc.axis(targetAngle).y

    @forceUpdate()
    requestAnimationFrame @animate

  coords: ({x, y} = {}) ->
    hasCoords = => !!@props.plane?.x

    if val # set
      @props.plane?.x = x
      @props.plane?.y = y
      return

    # get
    return if not hasCoords()
    _.pick @props.plane, 'x', 'y'

  render: ->
    style =
      position : 'absolute'
      width    : '10px'
      height   : '10px'
      left     : @props.plane.x
      top      : @props.plane.y
      border   : '1px dotted lightgray'
      transform: "rotate(#{ @props.plane.angle }deg)"

    <RenderInBody>
      <div class='flight' style={style} title={@props.plane.name}> v </div>
    </RenderInBody>

module.exports = Flight