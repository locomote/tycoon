_             = require 'lodash'
Link          = require('react-router').Link
ReactDOM      = require 'react-dom'
Flight        = require './flight'
PlaneList     = require '../components/plane_list'
FunButtons    = require '../components/fun_buttons'
MoneyBalance  = require '../components/money_balance'
LoyaltyList   = require '../components/loyalty_list'
AlertOverlay  = require '../components/alert_overlay'
VectorCalc    = require './vector_calc'
PathAnimation = require './path_animation'
Brain         = require './brain'
Game          = require('./game').instance()
{ Route, Airport, Plane, Loyalty, Alert, Player } = require '../data'

require('./message_bus')

Player.pink().claimLocation Airport.find(name: 'NYC')
Player.none().claimLocation Airport.find(name: 'LHR')
Player.blue().claimLocation Airport.find(name: 'DUB')

# assign ai to NPC's
# TODO: create a button to toggle Brain for player(s)
# Player.pink().implant new Brain
Game.start()

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

      curve = <SVGPath id="path-#{route.key}" key={route.key} d={directions} strokeWidth="2" stroke="#ccc" fill="transparent" strokeDasharray="10,10" />

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
      <MoneyBalance players={[Player.blue(), Player.pink()]} />
      <Brains players={[Player.blue(), Player.pink()]} />
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
        Game.scheduleFlight selection.name, @props.name

      Game.deselectAirports()
      console.log('deselected')
    else
      Game.selectAirport @props.name
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
      @planes = Plane.at(@props.name)

  done: (plane) ->
    ->
      Game.landPlane(plane)

  render: ->
    animations = for plane in @planes
      <PathAnimation key={plane.name} node={"path-#{plane.location}"} onDone={@done(plane)} />

    <div>{animations}</div>


Brains = React.createClass
  mixins: [MessageBusMixin]

  getInitialState: ->
    state = {}
    _.each @props.players, (player) -> state[ player.name ] = false
    state

  onClick: (player) ->
    state = @state

    if player.brain
      delete player.brain
      state[ player.name ] = false

    else
      player.implant( brain = new Brain )
      brain.nextMove()
      state[ player.name ] = true

    @setState( state )

  render: ->
    btns = (
      _.map @props.players, (player) =>
        onClick     = @onClick.bind(@, player)

        borderColor =

        btnStyle =
          cursor: 'pointer'
          borderRadius: '40px'
          border: "2px solid black"
          backgroundColor: player.color
          margin: "10px"
          boxShadow: "2px 2px 10px rgba(0,0,0,0.35)"

        if @state[ player.name ]
          _.extend btnStyle,
            border: "2px solid green"
            boxShadow: "none"

        <div style={ btnStyle } onClick={ onClick }>
          <img src="./images/brain.png" style={{margin: "10px 10px 0 10px"}} />
        </div>
    )

    style =
      position: 'fixed'
      top: '0px'
      right: '0px'

    <div style={style}>{btns}</div>

