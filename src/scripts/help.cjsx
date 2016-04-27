_ = require 'lodash'

Help = React.createClass
  onClick: ->
    window.open('https://github.com/locomote/tycoon/blob/master/INSTRUCTIONS.md')

  render: ->
    <div className="help-btn" onClick={ @onClick }>?</div>

module.exports = Help