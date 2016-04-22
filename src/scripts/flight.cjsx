_                  = require 'lodash'
ReactDOM           = require 'react-dom'
RenderInBody       = require './render_in_body'
Calc               = require './calculator'
require('./message_bus')
{routes, airports} = require '../data'

Flight = React.createClass
  maxSpeed: 2
  route: ->
    _.find routes, key: @props.plane.enroute

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

  land: ->
    # horrible - shoudl be in a model....
    @props.plane.location = @route().end
    delete @props.plane.enroute

    parent = ReactDOM.findDOMNode(@).parentNode
    ReactDOM.unmountComponentAtNode parent
    MessageBus.publish 'dataChange'

  animate: ->
    target = @endCoords()
    {x, y} = @props.plane
    return @land() if @isAt( target )

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
      width    : '40px'
      height   : '40px'
      left     : @props.plane.x
      top      : @props.plane.y
      transform: "rotate(#{ @props.plane.angle }deg)"

    <RenderInBody>
      <img className='flight' style={style} title={@props.plane.name} src='./images/plane.png'></img>
    </RenderInBody>

module.exports = Flight
