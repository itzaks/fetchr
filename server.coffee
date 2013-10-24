class Server
  request: require 'request'
  mongoose: require 'mongoose'
  express: require 'express'
  sysPath = require 'path'

  constructor: ->
    @app = @express()
    @app.use @express.static(sysPath.resolve "public")
    @app.use @express.bodyParser()
    
    @app.post "/", (req, res) -> res.sendfile "public/index.html"
    @app.post "/submit", @addUser
    @app.get "/url/:site", @getResource
    
    #start on heroku
    @startServer() unless module.parent

  getResource: (req, res) =>
    host = req.params.site
    console.info "getResource:started"
    @request host, (err, response, body) ->
      console.info "getResource:fetched"
      return console.error err if err

      relativeLinks = /(src=|href=)(['|"])(\/[^\/][^['|"]*)(['|"])/g
      communication = """
        <link href="/remote.css" rel="stylesheet" />
        <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
        <script src="/javascripts/remote.js"></script>
        <script>
          RemoteSite = require('remote');
          remoteSite = new RemoteSite();
        </script>
      """

      body = body.replace relativeLinks, "$1$2#{ host }$3$4"
      body = body.replace "</head>", "#{ communication }</head>"
      
      res.send body

  startServer: (port = process.env.PORT, path, callback) ->
    console.log "startServer on port: #{ port }, path #{ path }"
    @app.listen port

module.exports = new Server()