{ Route, Airport } = require '../data'
VectorCalc         = require '../scripts/vector_calc'

SVGComponent = React.createClass render: -> <svg {...this.props}>{this.props.children}</svg>
SVGPath      = React.createClass render: -> <path {...this.props}>{this.props.children}</path>

module.exports = RouteLines = React.createClass
  render: ->
    lines = for route in Route.list
      s = Airport.find(name: route.start)
      e = Airport.find(name: route.end)
      [ p1, p2, p3, p4 ] = VectorCalc.gentleBezier(s,e)
      directions = "M#{p1.x} #{p1.y} C #{p3.x} #{p3.y}, #{p4.x} #{p4.y}, #{p2.x} #{p2.y}"

      curve = <SVGPath id="path-#{route.key}" key={route.key} d={directions} strokeWidth="2" stroke="#ccc" fill="transparent" strokeDasharray="10,10" />

      line = (v, c) -> <SVGPath d="M0 0 #{v.x} #{v.y}" stroke={c} strokeWidth="3" />

      [
        curve,
        # Enable these for debugging!
        # line(p1, 'red'),
        # line(p2, 'blue'),
        # line(p3, 'green'),
        # line(p4, 'orange')
      ]

    <SVGComponent height="700" width="1300">
      {lines}
    </SVGComponent>
