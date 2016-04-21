RenderInBody = React.createClass
  container: ->
    document.getElementById('app')

  componentDidMount: ->
    @el = document.createElement "div"
    @container().appendChild @el
    @_renderLayer()

  componentDidUpdate: ->
    @_renderLayer()

  componentWillUnmount: ->
    React.unmountComponentAtNode @el
    @container().removeChild @el

  _renderLayer: ->
    React.render @props.children, @el

  render: ->
    React.DOM.div @props

module.exports = RenderInBody