
# This is broken now because of dependencies on globals... need to fix it up
fly_to = (destinationCode) ->
  return unless airportSelected()
  plane          = _.first planes
  plane.location = airportSelected()
  plane.enroute  = "#{ plane.location.name }->#{ destinationCode }"
  ReactDOM.render(<Flight plane={plane} />, document.createElement "div")
  deselectAirports()

fly_to_nyc = (planes) ->
  ->
    fly_to.bind null, 'NYC'

fly_to_lhr = (planes) ->
  ->
    fly_to.bind null, 'LHR'

lets_all_go_to_nyc = (planes) ->
  ->
    plane.location = 'NYC' for plane in planes
    MessageBus.publish 'dataChange'

lets_all_go_to_dubai = (planes) ->
  ->
    plane.location = 'DUB' for plane in planes
    MessageBus.publish 'dataChange'

lets_all_be_in_the_air_to_london = (planes) ->
  ->
    plane.location = 'NYC->LHR' for plane in planes
    MessageBus.publish 'dataChange'


FunButtons = React.createClass
  render: ->
    <div>
      <button onClick={lets_all_go_to_nyc(@props.planes)}>Lets all go to NYC!</button>
      <button onClick={lets_all_go_to_dubai(@props.planes)}>Lets all go to Dubai!</button>
      <button onClick={lets_all_be_in_the_air_to_london(@props.planes)}>Lets all be flying to London!</button>
      <button onClick={fly_to_nyc(@props.planes)}>Lets animate to NYC!</button>
      <button onClick={fly_to_lhr(@props.planes)}>Lets animate to LHR!</button>
    </div>

module.exports = FunButtons
