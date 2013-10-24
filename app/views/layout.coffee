View = require('./view')

# Application frame
module.exports = class Layout extends View
  tagName: "body"

  bootstrap: ->
    @$views = @$("#views")
    @listenTo app, "view:change", @renderView

  renderView: (view) ->
    return if view is @activeView

    console.log view

    @activeView = new View = require "views/#{ view }"
    @$views.html @activeView.render().el
