_             = require 'lodash'
Link          = require('react-router').Link
ReactDOM      = require 'react-dom'
Flight        = require './flight'
BrainButtons  = require './brain_btn_panel'
PlaneList     = require '../components/plane_list'
FunButtons    = require '../components/fun_buttons'
MoneyBalance  = require '../components/money_balance'
LoyaltyList   = require '../components/loyalty_list'
AlertOverlay  = require '../components/alert_overlay'
RouteLines    = require '../components/route_lines'
GameHelp      = require './help'
PathAnimation = require './path_animation'
LocoBrain     = require './loco_brain'
ApiBrain      = require './api_brain'
Game          = require('./game').instance()

{ Route, Airport, Plane, Loyalty, Alert, Player } = require '../data'

require('./message_bus')

Player.pink().setHQ Airport.find(name: 'NYC')
Player.blue().setHQ Airport.find(name: 'MEL')

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
      <BrainButtons players={[Player.blue(), Player.pink()]} />
      <AlertOverlay alerts={Alert.list} />
      <GameHelp />
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


