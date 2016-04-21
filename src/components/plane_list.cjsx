PlaneList = React.createClass
  render: ->
    return <div/> if @props.planes.length == 0

    plane_components = (<li key={plane.name}>{plane.name}</li> for plane in @props.planes)

    <ul className='planelist'>{plane_components}</ul>

module.exports = PlaneList
