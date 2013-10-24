$ = jQuery.noConflict()

module.exports = class RemoteSite
  selected: null
  drawBorder: off 

  constructor: ->
    @$doc = $(document)
    @$doc.ready @init
    window.addEventListener 'message', @onMessage, false

  init: =>
    @$selection = $("<div id=fetchr-selection></div>").appendTo "body"
    @$doc.on "mousemove", @mousemove
    
    $("body").on "click", (e) =>
      e.preventDefault()
      @drawBorder = off

  #process messages from parent
  onMessage: (msg) =>
    data = msg.data.split(":")
    command = data[0]

    switch command
      when "select" then @select(data[1])
      when "item" then @setItemPath(data[1])

  #activate element selection
  select: (type) ->
    @type = type
    @drawBorder = on

  #mark items
  setItemPath: (path) ->
    console.log "got", path

    @$items?.removeClass "fetchr-item"
    @$items = $(path)
    @$items.addClass "fetchr-item"

  #get selected element from mouse
  mousemove: (event) =>
    {target} = event

    return unless @drawBorder
    return if @selected is target
    
    @selected = target
    $el = ($ target)
    @setSelection $el
    @sendPath $el

  #create mouse hover box
  setSelection: ($el) ->
    {top, left} = $el.offset()

    @$selection.css
      top: top
      left: left
      width: $el.outerWidth()
      height: $el.outerHeight()

  sendPath: ($node) ->
    path = $node.getPath null, $("body")
    parent.postMessage path, "*"

$.fn.getPath = (path = "", $stop = null) ->
  serializeNode = ($node) ->
    # Add the element name.
    serialized = $node.get(0).nodeName.toLowerCase()
    id = $node.attr("id")
    class_ = $node.attr("class")
    serialized += "#" + id if id
    
    # Add any classes.
    if class_?
      classes = (c for c in class_.split /[\s\n]+/ when c and c.match /^(?!fetchr)/)
      serialized += "." + classes.join(".") if classes.length

    return serialized
    
  # If this element is <html> we've reached the end of the path.
  return "html" + path if @is("html") 
  return serializeNode($stop) + path if ($stop? and @is $stop)
  
  current = (serializeNode @)

  # Recurse up the DOM.
  @parent().getPath (" > " + current + path), $stop
