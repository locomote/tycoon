_            = require 'lodash'
Link         = require('react-router').Link
ReactDOM     = require 'react-dom'
Flight       = require './flight'

require('./message_bus')

{ routes, airports } = require '../data'

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

airports[0].owner = player2
airports[1].owner = nobody
airports[2].owner = player1

planes_for = (player) ->
  plane for plane in planes when plane.owner == player

player2_planes = ->
  planes_for(player2)

player1_planes = ->
  planes_for(player1)

# Duplicating name/key as you need unique keys, but can't do @props.key for name...
# airports = [
#   {key: 'NYC', name: 'NYC', left: 330, top:  300, owner: player2, customers: 200 },
#   {key: 'LHR', name: 'LHR', left: 580, top:  250, owner: nobody, customers: 200 },
#   {key: 'DUB', name: 'DUB', left: 770, top:  380, owner: player1, customers: 200 }
# ]

# Some "virtual" places flight can live when they're moving between airports
# routes = [
#   { key: 'NYC->LHR', name: 'NYC->LHR', start: 'NYC', end: 'LHR', x: 450, y: 240 },
#   { key: 'LHR->NYC', name: 'LHR->NYC', start: 'LHR', end: 'NYC', x: 472, y: 326 },
#   { key: 'LHR->DUB', name: 'LHR->DUB', start: 'LHR', end: 'DUB', x: 710, y: 280 },
#   { key: 'DUB->LHR', name: 'DUB->LHR', start: 'DUB', end: 'LHR', x: 660, y: 340 }
# ]

newCustomers = ->
  for airport in airports
    # Terminals with planes gain 50 passengers each second
    if planes_at(airport.name).length != 0
      airport.customers += 50
      MessageBus.publish 'dataChange'

# Game Loop!
setInterval newCustomers, 1000

fly_to = (location, loc_planes) ->
  plane.location = location for plane in loc_planes
  MessageBus.publish 'dataChange'

player1_goes_to_nyc = ->
  fly_to('NYC', player1_planes())

player1_goes_to_dub = ->
  fly_to('DUB', player1_planes())

player2_goes_to_nyc = ->
  fly_to('NYC', player2_planes())

player2_goes_to_dub = ->
  fly_to('DUB', player2_planes())

fly_to = (locationCode) ->
  plane          = _.first planes
  route          = "#{ plane.location }->#{ locationCode }"
  plane.location = route
  ReactDOM.render(<Flight plane={plane} />, document.createElement "div")

lets_all_go_to_nyc = ->
  plane.location = 'NYC' for plane in planes
  MessageBus.publish 'dataChange'

lets_all_go_to_dubai = ->
  plane.location = 'DUB' for plane in planes
  MessageBus.publish 'dataChange'

lets_all_be_in_the_air_to_london = ->
  plane.location = 'NYC->LHR' for plane in planes
  MessageBus.publish 'dataChange'


module.exports = React.createClass
  displayName: 'AirlineTycoon'
  mixins: [MessageBusMixin]

  componentDidMount: ->
    # You should never, ever do this.
    # But it sure is a convenient hack-day way to avoid implementing a store with callback hell!
    @subscribe('dataChange', @forceUpdate)

  componentWillUnmount: ->
    @unsubscribe('dataChange')

  render: ->
    route_components = (<Route {...props}/> for props in routes)
    airport_components = (<Airport {...airport}/> for airport in airports)

    fly_to_nyc = fly_to.bind null, 'NYC'
    fly_to_lhr = fly_to.bind null, 'LHR'

    <div id='map'>
      {airport_components}
      {route_components}
      <button onClick={lets_all_go_to_nyc}>Lets all go to NYC!</button>
      <button onClick={lets_all_go_to_dubai}>Lets all go to Dubai!</button>
      <button onClick={lets_all_be_in_the_air_to_london}>Lets all be flying to London!</button>
      <button onClick={fly_to_nyc}>Lets animate to NYC!</button>
      <button onClick={fly_to_lhr}>Lets animate to LHR!</button>
      <button onClick={player1_goes_to_nyc}>Player1 to NYC!</button>
      <button onClick={player1_goes_to_dub}>Player1 to DUB!</button>
      <button onClick={player2_goes_to_nyc}>Player2 to NYC!</button>
      <button onClick={player2_goes_to_dub}>Player2 to DUB!</button>

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
      <div style={marginTop: 20, width: 100}><b>{@props.name} - {@props.owner.name}</b></div>
      <PlaneList planes={planes_at(@props.name)} />
      <div><b>Customers: {@props.customers}</b></div>
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

    <ul style={width: 200, color: 'blue' }>{plane_components}</ul>
