_             = require 'lodash'
Link          = require('react-router').Link
ReactDOM      = require 'react-dom'
Flight        = require './flight'
PlaneList     = require '../components/plane_list'
FunButtons    = require '../components/fun_buttons'
MoneyBalance  = require '../components/money_balance'
LoyaltyList   = require '../components/loyalty_list'
AlertOverlay  = require '../components/alert_overlay'
RouteLines    = require '../components/route_lines'
PathAnimation = require './path_animation'
Brain         = require './brain'
Game          = require('./game').instance()
{ Route, Airport, Plane, Loyalty, Alert, Player } = require '../data'

require('./message_bus')

Player.pink().setHQ Airport.find(name: 'NYC')
# Player.none().setHQ Airport.find(name: 'LHR')
# Player.none().setHQ Airport.find(name: 'MEL')
Player.blue().setHQ Airport.find(name: 'MEL')

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

    <div id='map'>
      <RouteLines />
      {airport_components}
      {route_components}
      <MoneyBalance players={[Player.blue(), Player.pink()]} />
      <Brains players={[Player.blue(), Player.pink()]} />
      <AlertOverlay alerts={Alert.list} />
    </div>

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
      backgroundColor: (@props.owner or Player.none()).color
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

  componentDidMount:    -> @subscribe   'dataChange', @animateFlights
  componentWillUnmount: -> @unsubscribe 'dataChange'

  animateFlights: ->
    newPlanes = _.difference Plane.at(@props.name), @planes
    if !_.isEmpty(newPlanes)
      @planes = Plane.at(@props.name)

  render: ->
    animations = for plane in Plane.at(@props.name) #@planes
      done = Game.landPlane.bind Game, plane
      <PathAnimation key={plane.name} player={plane.owner} node={"path-#{plane.location}"} onDone={done} />

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

