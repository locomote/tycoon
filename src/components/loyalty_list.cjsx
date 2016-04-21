LoyaltyList = React.createClass
  render: ->
    loyalty_components = for loyalty in @props.loyalties when loyalty.amount > 0
      owner = loyalty.owner
      <li className='loyalty' key={owner.name}>
        <span style={backgroundColor: owner.color, width: "#{loyalty.amount}%"} />
      </li>

    return <div/> if loyalty_components.length == 0
    <ul className='loyalties'>{loyalty_components}</ul>

module.exports = LoyaltyList
