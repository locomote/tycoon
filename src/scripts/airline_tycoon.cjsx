_            = require 'lodash'
Link         = require('react-router').Link
ReactDOM     = require 'react-dom'
Flight       = require './flight'
PlaneList    = require '../components/plane_list'
FunButtons   = require '../components/fun_buttons'
MoneyBalance = require '../components/money_balance'
LoyaltyList  = require '../components/loyalty_list'
AlertOverlay  = require '../components/alert_overlay'
VectorCalc   = require './vector_calc'

require('./message_bus')
{ Route, Airport, Plane, Loyalty, Alert } = require '../data'

pink = '#d5a6bd'
blue = '#9fc5e8'
grey = '#eeeeee'

player1 = name: 'Blue',   color: blue, money: 0, hq: Airport.list[2]
player2 = name: 'Pink',   color: pink, money: 0, hq: Airport.list[0]
nobody  =  name: 'Nobody', color: grey, money: 0, hq: Airport.list[1]

player1.hq.owner = player1
player2.hq.owner = player2
nobody.hq.owner  = nobody
# static data setup
Plane.create [
  {name: 'Plane1', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane2', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane3', flights_flown: 0, location: 'DUB', owner: player1},
  {name: 'Plane4', flights_flown: 0, location: 'NYC', owner: player2},
  {name: 'Plane5', flights_flown: 0, location: 'NYC', owner: player2},
  {name: 'Plane6', flights_flown: 0, location: 'NYC', owner: player2}
]
Loyalty.create [
  { location: 'NYC', amount: 0, owner: player1 },
  { location: 'LHR', amount: 0, owner: player1 },
  { location: 'DUB', amount: 0, owner: player1 },
  { location: 'NYC', amount: 0, owner: player2 },
  { location: 'LHR', amount: 0, owner: player2 },
  { location: 'DUB', amount: 0, owner: player2 }
]

Game =
  landedHandler: (plane) ->
    console.log 'handling!'

    # Every flight increases our flown count
    # @todo retire planes flown > 4
    plane.flights_flown++

    # Reward every landing
    owner = plane.owner
    owner.money += 100

    # Loyalty increases when Airport is not ours
    loyalty = Loyalty.find(location: plane.location, owner: owner)
    airport = Airport.find(name: plane.location)
    if airport.owner != owner
      loyalty.amount += 20

      # Airport becomes ours once loyalty reaches 100%
      if loyalty.amount >= 100
        airport.owner = owner

        # It's a big marketing win, all other loyalties take a hit!
        loyalty.amount = 0 for loyalty in Loyalty.where(location: airport.name)

    if owner.money >= 300
      # Buy more planes!
      buyPlane(owner)

    # Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')
    if Airport.where(owner: player2).length == 0
      Alert.create(message: 'Congratulations! You are the ultimate Airline Tycoon!')
    else if Airport.where(owner: player1).length == 0
      Alert.create(message: 'Oops, it seems youve been out-tycooned!')

    MessageBus.publish 'dataChange'

# Game mechanics!
MessageBus.subscribe(Game, 'landed', Game.landedHandler)

buyPlane = (player) ->
  Plane.createFor(player)
  player.money -= 300
  MessageBus.publish 'dataChange'

selectAirport = (airportCode) ->
  Airport.selectByKey airportCode
  MessageBus.publish 'dataChange'

deselectAirports = (airportCode) ->
  Airport.deselectAll()
  MessageBus.publish 'dataChange'

scheduleFlight = (startAirportCode, endAirportCode) ->
  # @todo only send our own planes
  plane = _.first (Plane.at startAirportCode)
  plane.location = "#{startAirportCode}->#{endAirportCode}"
  MessageBus.publish 'dataChange'

landPlane = (plane) ->
  ->
    # @todo flight ordering on landing
    plane.location = plane.location.split('->')[1]
    MessageBus.publish 'landed', plane
    MessageBus.publish 'dataChange'
    console.log "landed in #{plane.location}!"

newCustomers = ->
  for airport in Airport.list
    # Terminals with planes gain 50 passengers each second
    if Plane.at(airport.name).length != 0
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
    route_components = (<RouteMarker {...props}/> for props in Route.list )
    airport_components = (<AirportMarker {...airport}/> for airport in Airport.list )

    lines = for route in Route.list
      s = Airport.find(name: route.start)
      e = Airport.find(name: route.end)
      [ p1, p2, p3, p4 ] = VectorCalc.gentleBezier(s,e)
      directions = "M#{p1.x} #{p1.y} C #{p3.x} #{p3.y}, #{p4.x} #{p4.y}, #{p2.x} #{p2.y}"

      curve = <SVGPath key={route.key} d={directions} strokeWidth="2" stroke="#ccc" fill="transparent" strokeDasharray="10,10" />

      line = (v, c) -> <SVGPath d="M0 0 #{v.x} #{v.y}" stroke={c} strokeWidth="3" />

      [
        curve,
        # Enable these for debug!
        # line(p1, 'red'),
        # line(p2, 'blue'),
        # line(p3, 'green'),
        # line(p4, 'orange')
      ]

    <div id='map'>
      <SVGComponent height="700" width="1300">
        {lines}
      </SVGComponent>
      {airport_components}
      {route_components}
      <MoneyBalance players={[player1, player2]} />
      <AlertOverlay alerts={Alert.list} />
    </div>


SVGComponent = React.createClass render: -> <svg {...this.props}>{this.props.children}</svg>
SVGPath      = React.createClass render: -> <path {...this.props}>{this.props.children}</path>


AirportMarker = React.createClass
  mixins: [MessageBusMixin]

  select: ->
    if selection = Airport.selected()
      if selection.name != @props.name
        console.log "Flying #{selection.name}->#{@props.name}"
        scheduleFlight selection.name, @props.name

      deselectAirports()
      console.log('deselected')
    else
      selectAirport @props.name
      console.log('selected')

  render: ->
    style =
      backgroundColor: @props.owner.color
      top: @props.y
      left: @props.x

    if @props.selected
      _.extend style, border: '2px solid green'

    <div className='airport marker' style={style} onClick={@select}>
      <div style={marginTop: 20, width: 100}><b>{@props.name}</b></div>
      <PlaneList planes={Plane.at(@props.name)} />
      <div className='customers'>D:{@props.customers}</div>
      <LoyaltyList loyalties={Loyalty.where(location: @props.name)} />
    </div>

RouteMarker = React.createClass
  mixins: [MessageBusMixin]

  # This is also bad, but it appears that setState is _potentially_ async so we can't rely on it for
  # sync read/write as required in animateFlights so we're not processing the same flight multiple times
  planes: []

  getInitialState: ->
    @planes = Plane.at(@props.name) # hack as @props is not available at init time
    null

  componentDidMount:    -> @subscribe   'dataChange', @animateFlights
  componentWillUnmount: -> @unsubscribe 'dataChange'

  animateFlights: ->
    newPlanes = _.difference Plane.at(@props.name), @planes
    if !_.isEmpty(newPlanes)
      for plane in newPlanes
        setTimeout landPlane(plane), 1000 # @todo set according to distance between airports

      @planes = Plane.at(@props.name)

  render: ->
    style =
      left: @props.x
      top: @props.y

    <div className='route marker' style={style}>
      <div style={marginTop: 20, width: 100}>{@props.name}</div>
      <PlaneList planes={Plane.at(@props.name)} />
    </div>

