_     = require 'lodash'

AlertOverlay = React.createClass
  render: ->
    return <div/> if _.isEmpty @props.alerts
    alert_components = <p>{alert.message}</p> for alert in @props.alerts

    <div className='alert'>
      {alert_components}
      <a href='/'>Play again!</a>
    </div>

module.exports = AlertOverlay
