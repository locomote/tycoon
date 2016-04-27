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
      return unless brain = @newBrain()
      @props.player.implant( brain )
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
    return unless url = document.querySelector(".api-url.#{@props.player.name}").value
    new ApiBrain(url)

  render: ->
    btnStyle =
      backgroundColor : @props.player.color

    imgStyle = margin: "8px 0 0 0"

    className = "brain-btn api"
    className += " selected" if @state.selected

    <div style={ btnStyle } className={ className }>
      <input placeholder="Enter API url..." className="api-url #{@props.player.name}" />
      <img src="./images/brain.png" style={imgStyle} onClick={ @onClick } />
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

    className = "brain-btn loco"
    className += " selected" if @state.selected

    <div style={ btnStyle } className={className} onClick={ @onClick }>
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