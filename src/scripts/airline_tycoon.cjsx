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

ThePlayer       = player1
selectedAirport = null # horrible

airports[0].owner = player2
airports[1].owner = nobody
airports[2].owner = player1

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

planes_for = (player) ->
  plane for plane in planes when plane.owner == player

player2_planes = ->
  planes_for(player2)

player1_planes = ->
  planes_for(player1)

newCustomers = ->
  for airport in airports
    # Terminals with planes gain 50 passengers each second
    if planes_at(airport.name).length != 0
      airport.customers += 50 if airport.customers < 1000
      MessageBus.publish 'dataChange'

# Game Loop!
requestAnimationFrame newCustomers

fly_to = (locationCode) ->
  return unless selectedAirport
  plane          = _.first planes
  plane.location = selectedAirport
  plane.enroute  = "#{ plane.location }->#{ locationCode }"
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
    </div>

Airport = React.createClass
  mixins: [MessageBusMixin]

  getInitialState: ->
    selected: false

  componentDidMount: ->
    @subscribe('deselectAirports', @deselect)

  componentWillUnmount: ->
    @unsubscribe('deselectAirports')

  onClick: ->
    if @props.owner is ThePlayer
      selectedAirport = @props.name
      MessageBus.publish 'deselectAirports'
      @setState(selected: true)
      @forceUpdate()

    else
      fly_to @props.name

  deselect: ->
    @setState(selected: false)

  render: ->
    style =
      backgroundColor: @props.owner.color
      top: @props.top
      left: @props.left

    if @state.selected
      _.extend style, border: '2px solid green'

    <div className='airport locbox' style={style} onClick={@onClick}>
      <div style={marginTop: 20, width: 100}><b>{@props.name}</b></div>
      <PlaneList planes={planes_at(@props.name)} />
      <div className='customers'>D:{@props.customers}</div>
    </div>

Route = React.createClass
  render: ->
    style =
      left: @props.x
      top: @props.y

    <div className='route locbox' style={style}>
      <div style={marginTop: 20, width: 100}>{@props.name}</div>
      <PlaneList planes={planes_at(@props.name)} />
    </div>

PlaneList = React.createClass
  render: ->
    return <div/> if @props.planes.length == 0

    plane_components = (<li key={plane.name}>{plane.name}</li> for plane in @props.planes)

    <ul className='planelist'>{plane_components}</ul>
