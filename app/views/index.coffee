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
    @getCurrentUrl()

    _pathChange = _.throttle @pathChange, 100

    for node in @$(".node-path")
      $(node)
        .on('itemAdded', _pathChange)
        .on('itemRemoved', _pathChange)
        .tagsinput( itemValue: (text) -> text )

  getCurrentUrl: ->
    url = decodeURIComponent(window.location.hash.substr 1)
    console.log url
    @getResource url

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

  fetchPreview: ->
    #posts = for node in $(@paths.title.join(" "), data)

  getResource: (url) ->
    urlEncoded = encodeURIComponent(url)
    app.trigger 'navigate', "fetch/#{ urlEncoded }"

    $.get "/url/#{ urlEncoded }", (data) =>
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
