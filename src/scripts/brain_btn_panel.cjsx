require './message_bus'
_         = require 'lodash'
ApiBrain  = require './api_brain'
LocoBrain = require './loco_brain'

BrainBtnMixin =
  componentDidMount:    ->
    @subscribe 'brain-selected', @onBrainSelected
    @subscribe 'brain-deselected', @onBrainSelected

  componentWillUnmount: ->
    @unsubscribe 'brain-selected'
    @unsubscribe 'brain-deselected'

  onBrainSelected: (player) ->
    return unless player is @props.player

    if @props.player.brain?.constructor is @brainConstructor()
      @setState(selected: true)
    else
      @setState(selected: false)

  onClick: ->
    if @props.player.brain
      delete @props.player.brain
      MessageBus.publish 'brain-deselected', @props.player

    else
      @props.player.implant( @newBrain() )
      MessageBus.publish 'brain-selected', @props.player

  getInitialState: ->
    selected: false

ApiBrainBtn = React.createClass
  mixins: [
    MessageBusMixin
    BrainBtnMixin
  ]

  brainConstructor: ->
    ApiBrain

  newBrain: ->
    new ApiBrain('http://localhost:9090/next_turn')

  render: ->
    btnStyle =
      backgroundColor : @props.player.color
      cursor          : 'pointer'
      borderRadius    : '40px'
      border          : "2px solid black"
      margin          : "10px"
      width           : "80px"
      height          : "80px"
      boxShadow       : "2px 2px 10px rgba(0,0,0,0.35)"
      display         : 'inline-block'
      padding         : '7px'
      float           : 'left'

    if @state.selected
      _.extend btnStyle,
        border    : "2px solid green"
        boxShadow : "0 0 10px green"

    imgStyle =
      margin: "8px 0 0 0"

    <div style={ btnStyle } onClick={ @onClick }>
      <img src="./images/brain.png" style={imgStyle} />
    </div>


LocoBrainBtn = React.createClass
  mixins: [
    MessageBusMixin
    BrainBtnMixin
  ]

  brainConstructor: ->
    LocoBrain

  newBrain: ->
    new LocoBrain

  render: ->
    btnStyle =
      backgroundColor : @props.player.color
      cursor          : 'pointer'
      borderRadius    : '40px'
      border          : "2px solid black"
      margin          : "10px"
      width           : "80px"
      height          : "80px"
      boxShadow       : "2px 2px 10px rgba(0,0,0,0.35)"
      display         : 'inline-block'
      float           : 'right'

    if @state.selected
      _.extend btnStyle,
        border    : "2px solid green"
        boxShadow : "0 0 10px green"

    <div style={ btnStyle } onClick={ @onClick }>
      <img src="./images/loco-bot.png" />
    </div>

PlayerBrainPanel = React.createClass
  render: ->
    className = "player #{@props.player.name}"

    <div className={className}>
      <ApiBrainBtn player={@props.player}></ApiBrainBtn>
      <LocoBrainBtn player={@props.player}></LocoBrainBtn>
    </div>

BrainBtnPanel = React.createClass
  render: ->
    btns = (
      <PlayerBrainPanel player={player}></PlayerBrainPanel> for player in @props.players or []
    )

    style =
      position : 'fixed'
      top      : '0px'
      right    : '0px'

    <div style={style}>{btns}</div>

module.exports = BrainBtnPanel