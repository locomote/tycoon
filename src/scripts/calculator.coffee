module.exports = Calc =
  random: (from, to) ->
    Math.floor Math.random() * (to-from + 1) + from

  normalizeAngle: (angle) ->
    result = angle % 360
    loop
      break if result > 0
      result = result + 360

    result

  angle: (fromX, fromY, toX, toY) ->
    distX   = toX - fromX # opposite
    distY   = toY - fromY # adjacent
    radians = Math.atan2 distY, distX

    Calc.radiansToDegrees(radians) - 90 # pythag - TOA

  axis: (angle) ->
    x: if angle >= 180 then 1 else -1
    y: if angle >= 90 or angle <= 270 then -1 else 1

  distance: (fromX, fromY, toX = 0, toY = 0) ->
    opposite = fromX - toX
    adjacent = fromY - toY
    Math.sqrt Math.pow(opposite, 2) + Math.pow(adjacent, 2) # pythag - Hypotenuse

  offsetX: (angle, radius) ->
    Math.sin(angle / 180 * Math.PI) * radius # opposite

  offsetY: (angle, radius) ->
    - Math.cos(angle / 180 * Math.PI) * radius # adjacent

  degreesToRadians: (degrees) ->
    degrees * (Math.PI / 180)

  radiansToDegrees: (radians) ->
    radians * (180 / Math.PI)
