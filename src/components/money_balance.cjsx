MoneyBalance = React.createClass
  render: ->

    player_components = for player in @props.players
      <span className='dollars' style={color: player.color} key={player.name}>${player.money}</span>

    <div className='dollar-list'>{player_components}</div>

module.exports = MoneyBalance
