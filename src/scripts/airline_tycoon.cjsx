_            = require 'lodash'
Link         = require('react-router').Link
ReactDOM     = require 'react-dom'
Flight       = require './flight'
PlaneList    = require '../components/plane_list'
FunButtons   = require '../components/fun_buttons'
MoneyBalance = require '../components/money_balance'

require('./message_bus')

{ routes, airports } = require '../data'

pink = '#d5a6bd'
blue = '#9fc5e8'
grey = '#eeeeee'

player1 =
  name: 'Blue'
  color: blue
  money: 0

player2 =
  name: 'Pink'
  color: pink
  money: 0

nobody =
  name: 'Nobody'
  color: grey

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

airportSelected = ->
  _.find airports, selected: true

selectAirport = (airportCode) ->
  airport.selected = false for airport in airports
  airport.selected = true  for airport in airports when airport.name == airportCode
  MessageBus.publish 'dataChange'

deselectAirports = (airportCode) ->
  airport.selected = false for airport in airports
  MessageBus.publish 'dataChange'

scheduleFlight = (startAirportCode, endAirportCode) ->
  # @todo only send our own planes
  plane = _.first (planes_at startAirportCode)
  plane.location = "#{startAirportCode}->#{endAirportCode}"
  MessageBus.publish 'dataChange'

landPlane = (plane) ->
  ->
    # @todo flight ordering on landing
    plane.location = plane.location.split('->')[1]
    plane.flights_flown++
    plane.owner.money += 100
    MessageBus.publish 'dataChange'
    console.log "landed in #{plane.location}!"

newCustomers = ->
  for airport in airports
    # Terminals with planes gain 50 passengers each second
    if planes_at(airport.name).length != 0
      airport.customers += 50 if airport.customers < 1000
      MessageBus.publish 'dataChange'

# Game Loop!
requestAnimationFrame newCustomers

module.exports = React.createClass
  displayName: 'AirlineTycoon'
  mixins: [MessageBusMixin]

  # You should never, ever do this.
  # But it sure is a convenient hack-day way to avoid implementing a store with callback hell!
  componentDidMount:    -> @subscribe   'dataChange', @forceUpdate
  componentWillUnmount: -> @unsubscribe 'dataChange'

  render: ->
    route_components = (<Route {...props}/> for props in routes)
    airport_components = (<Airport {...airport}/> for airport in airports)

    <div id='map'>
      {airport_components}
      {route_components}
      <MoneyBalance players={[player1, player2]} />
      <FunButtons planes={planes} />
    </div>


Airport = React.createClass
  mixins: [MessageBusMixin]

  select: ->
    if airportSelected()?
      if airportSelected().name != @props.name
        console.log "Flying #{airportSelected().name}->#{@props.name}"
        scheduleFlight airportSelected().name, @props.name

      deselectAirports()
      console.log('deselected')
    else
      selectAirport @props.name
      console.log('selected')

  render: ->
    style =
      backgroundColor: @props.owner.color
      top: @props.top
      left: @props.left

    if @props.selected
      _.extend style, border: '2px solid green'

    <div className='airport locbox' style={style} onClick={@select}>
      <div style={marginTop: 20, width: 100}><b>{@props.name}</b></div>
      <PlaneList planes={planes_at(@props.name)} />
      <div className='customers'>D:{@props.customers}</div>
    </div>

Route = React.createClass
  mixins: [MessageBusMixin]

  # This is also bad, but it appears that setState is _potentially_ async so we can't rely on it for
  # sync read/write as required in animateFlights so we're not processing the same flight multiple times
  planes: []

  getInitialState: ->
    @planes = planes_at(@props.name) # hack as @props is not available at init time
    null

  componentDidMount:    -> @subscribe   'dataChange', @animateFlights
  componentWillUnmount: -> @unsubscribe 'dataChange'

  animateFlights: ->
    newPlanes = _.difference planes_at(@props.name), @planes
    if !_.isEmpty(newPlanes)
      for plane in newPlanes
        setTimeout landPlane(plane), 3000 # @todo set according to distance between airports

      @planes = planes_at(@props.name)

  render: ->
    style =
      left: @props.x
      top: @props.y

    <div className='route locbox' style={style}>
      <div style={marginTop: 20, width: 100}>{@props.name}</div>
      <PlaneList planes={planes_at(@props.name)} />
    </div>

