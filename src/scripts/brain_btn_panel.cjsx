require './message_bus'
_         = require 'lodash'
ApiBrain  = require './api_brain'
LocoBrain = require './loco_brain'

BrainBtnMixin =
  toggleBrain: ->
    if @props.player.brain
      delete @props.player.brain
      @setState(selected: false)

    else
      return unless brain = @newBrain()
      @props.player.implant( brain )
      @setState(selected: true)

  getInitialState: ->
    selected: false


ApiBrainBtn = React.createClass
  mixins: [ BrainBtnMixin ]

  newBrain: ->
    new ApiBrain(@refs.url.value)

  render: ->
    btnStyle =
      backgroundColor : @props.player.color

    imgStyle = margin: "8px 0 0 0"

    className = "brain-btn api"
    className += " selected" if @state.selected

    <div style={ btnStyle } className={ className }>
      <input ref="url" placeholder="Enter API url..." className="api-url" />
      <img src="./images/brain.png" style={imgStyle} onClick={ @toggleBrain } />
    </div>


LocoBrainBtn = React.createClass
  mixins: [ BrainBtnMixin ]

  newBrain: ->
    new LocoBrain

  render: ->
    btnStyle =
      backgroundColor : @props.player.color

    className = "brain-btn loco"
    className += " selected" if @state.selected

    <div style={ btnStyle } className={className} onClick={ @toggleBrain }>
      <img src="./images/loco-bot.png" />
    </div>



PlayerBrainPanel = React.createClass
  render: ->
    <div className="player">
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
