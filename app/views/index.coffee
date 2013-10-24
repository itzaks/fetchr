View = require './view'

module.exports = class Index extends View
  template: require './templates/startpage'
  collection: app.resources
  paths: 
    items: []
    title: []
    description: []
    permalink: []
  events: 
    "click .btn-getpath": "setPath"
    "click .add-resource": "addResource"

  bootstrap: ->
    window.addEventListener 'message', @messageReceived, false

  domReady: -> 
    @getResource("http://localhost:5000")

    _pathChange = _.throttle @pathChange, 100

    for node in @$(".node-path")
      $(node)
        .on('itemAdded', _pathChange)
        .on('itemRemoved', _pathChange)
        .tagsinput( itemValue: (text) -> text )

  pathChange: (ev) =>
    $field = $(ev.currentTarget)
    type = $field.data("path")
    path = $field.val().split(",")

    @paths[type] = path
    @messageRemote ([type, path.join(" ")].join ":")
    @fetchPreview()

    @grabMeta()

  grabMeta: ->
    itemPath = @paths.item.join(" ").replace("body ", "")
    $meta = @$remote.find(itemPath).html()
    console.log $meta, itemPath, @$remote
    (@$ "#item-view").html $meta

  fetchPreview: ->
    #posts = for node in $(@paths.title.join(" "), data)

  getResource: (url) ->
    $.get "/url/#{ encodeURIComponent(url) }", (data) =>
      @attachTools(data)

  setPath: (ev) =>
    @$path = $(ev.currentTarget).parents(".form-group").find(".node-path")
    @messageRemote("select:#{ @$path.data 'path' }")

  messageRemote: (msg) ->
    @$browser[0].contentWindow.postMessage msg, "*"

  addResource: ->
    @getResource prompt "Gief url", "http://news.ycombinator.com"

  messageReceived: (msg) =>
    data = msg.data.split(" > ")
    @$path.tagsinput 'removeAll'
    @$path.tagsinput 'add', path for path in data

  attachTools: (data) =>
    @$browser = $("<iframe id='browser' width='100%' height='2500' />")
    @$browser.appendTo @$("#browser-wrap").empty()

    iframe = @$browser.contents()[0]
    iframe.open()
    iframe.write data
    iframe.close()
