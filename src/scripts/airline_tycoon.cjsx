Link = require('react-router').Link

pink = '#d5a6bd'
blue = '#9fc5e8'
grey = '#eeeeee'

player1 =
  name: 'Blue'
  color: blue

player2 =
  name: 'Pink'
  color: pink

nobody =
  name: 'Nobody'
  color: grey

planes = [
  {name: 'Plane1', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane2', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane3', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane4', flights_flown: 0, location: 'NYC', owner: player2},
  {name: 'Plane5', flights_flown: 0, location: 'NYC', owner: player2},
  {name: 'Plane6', flights_flown: 0, location: 'NYC', owner: player2}
]

planes_at = (location) ->
  plane for plane in planes when plane.location == location

# Duplicating name/key as you need unique keys, but can't do @props.key for name...
airports = [
  {key: 'NYC', name: 'NYC', left: 330, top:  300, owner: player2 },
  {key: 'LHR', name: 'LHR', left: 580, top:  250, owner: nobody },
  {key: 'DUB', name: 'DUB', left: 770, top:  380, owner: player1 }
]

# Some "virtual" places flight can live when they're moving between airports
routes = [
  { key: 'NYC->LHR', name: 'NYC->LHR', start: 'NYC', end: 'LHR', x: 450, y: 240 },
  { key: 'LHR->NYC', name: 'LHR->NYC', start: 'LHR', end: 'NYC', x: 472, y: 326 },
  { key: 'LHR->DUB', name: 'LHR->DUB', start: 'LHR', end: 'DUB', x: 710, y: 280 },
  { key: 'DUB->LHR', name: 'DUB->LHR', start: 'DUB', end: 'LHR', x: 660, y: 340 }
]

module.exports = React.createClass
  displayName: 'AirlineTycoon'

  render: ->
    route_components = (<Route {...props}/> for props in routes)
    airport_components = (<Airport {...airport}/> for airport in airports)

    <div id='map'>
      {airport_components}
      {route_components}
    </div>

Airport = React.createClass
  render: ->
    # There are here cause it was quick and I'm lazy, but parts probably be better suited in CSS.
    style =
      backgroundColor: @props.owner.color
      border: '1px solid #000'
      height: 20
      width: 20
      position: 'absolute'
      top: @props.top
      left: @props.left

    <div className='airport' style={style}>
      <div style={marginTop: 20, width: 100}>{@props.name} - {@props.owner.name}</div>
      <PlaneList planes={planes_at(@props.name)} />
    </div>

Route = React.createClass
  render: ->
    # There are here cause it was quick and I'm lazy, but parts probably be better suited in CSS.
    style =
      backgroundColor: '#ccc'
      border: '1px solid #000'
      height: 20
      width: 20
      position: 'absolute'
      left: @props.x
      top: @props.y

    <div className='route' style={style}>
      <div style={marginTop: 20, width: 100}>{@props.name}</div>
      <PlaneList planes={planes_at(@props.name)} />
    </div>

PlaneList = React.createClass
  render: ->
    plane_components = (<li key={plane.name}>{plane.name}</li> for plane in @props.planes)

    <ul style={width: 200}>{plane_components}</ul>
