Layout = require 'views/layout'
Router = require 'lib/router'

class URLResource extends Backbone.Model
  url: "/submit"
  defaults:
    name: "lolshack"
    url: ""
    paths: 
      title: ""
      description: ""
      href: ""

class Resources extends Backbone.Collection
  model: URLResource

module.exports = class Application
  constructor: ->
    _.extend @, Backbone.Events

    @router = new Router
    @resources = new Resources
    @on "navigate", (url) -> @router.navigate url

    $ => @ready()

  ready: ->
    @layout = new Layout {el: $("#application")}
    Backbone.history.start pushState: off, trigger: on
