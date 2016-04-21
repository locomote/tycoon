Victor = require('victor')

module.exports = VectorCalc =
  # Takes a start x,y, end x,y and returns the
  # two original points plus a gentle set of bezier controls
  # See https://developer.mozilla.org/en/docs/Web/SVG/Tutorial/Paths
  gentleBezier: (s, e) ->

    # Offsets to adjust for size of markers
    hw = 20/2
    hh = 20/2

    p1 = new Victor(s.x + 10, s.y + 10)
    p2 = new Victor(e.x + 10, e.y + 10)
    d = p2.clone().subtract(p1)

    l = new Victor(0, d.magnitude() / 3)

    b1 = l.clone().rotateByDeg(d.angleDeg()+150)
    b2 = l.clone().rotateByDeg(d.angleDeg()-150)

    p3 = p1.clone().add(b1)
    p4 = p2.clone().subtract(b2)

    [p1,p2,p3,p4]

