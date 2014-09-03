module.exports = Backbone.Router.extend
  initialize: ->
    @route '', 'index', -> @view 'index'
    @route 'fetch/:page', -> @view 'index'

  view: (name) ->
    app.trigger "view:change", name
