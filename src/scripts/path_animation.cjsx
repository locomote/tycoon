_ = require 'lodash'

# Render an animation that follows a given SVG path
# Thanks to the handy native getTotalLength and getPointAtLength methods that exist on <path> elements!
# See: https://developer.mozilla.org/en/docs/Web/API/SVGPathElement
module.exports = PathAnimation = React.createClass
  getInitialState: ->
    percent: 0
    animating: true
    x: 0
    y: 0

  componentDidMount: -> @animate()

  animate: ->
    @done() if @state.percent >= 100

    svg_path = document.getElementById(@props.node)
    return if _.isNull svg_path

    length = svg_path.getTotalLength() * (@state.percent/100)
    point  = svg_path.getPointAtLength(length)

    @setState
      x: point.x - 10
      y: point.y - 10
      percent: @state.percent + 0.5

    requestAnimationFrame @animate if @state.animating

  done: ->
    @setState animating: false
    @props.onDone()

  render: ->
    marker = <div className='marker' style={left: @state.x, top: @state.y}></div>

    if @state.animating then marker else <div/>
