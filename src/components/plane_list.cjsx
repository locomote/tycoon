PlaneList = React.createClass
  render: ->
    return <div/> if @props.planes.length == 0

    plane_components = for plane in @props.planes
      <li style={backgroundColor: plane.owner.color} key={plane.name}>{plane.name}</li>

    <ul className='planelist'>{plane_components}</ul>

module.exports = PlaneList
