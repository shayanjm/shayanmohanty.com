
###
Module dependencies.
###
app = require("express")()
express = require("express")
server = require("http").createServer(app)
routes = require("./routes")
http = require("http")
path = require("path")
scrape = require("./core/scrape")
async = require("async")
log = require("logg").getLogger("SM.main")



# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# Development Environment
app.use express.errorHandler()  if app.get("env") is "development"
app.on "error", (err) ->
	console.error "Houston, we have a problem: " + err

# Initialization
initSequence = [scrape.init]

log.info "init() :: Beginning initialization sequence..."
# Socket.IO Polling configuration
io = require('socket.io').listen(server)
log.info "init() :: Configuring Socket.IO for Long-Polling..."
io.configure ->
  io.set "transports", ["xhr-polling"]
  io.set "polling duration", 10
log.info "init() :: Long-Polling configuration done!"
# The rest of the initialization sequence
async.series initSequence, (err) ->
  if err
    log.warn "init() :: Failed to initialize. Error:", err
    process.exit 1
  else
    log.info "init() :: Initialization Complete"
    return

# Socket.IO Stuff for medium.com scraper
io.sockets.on "connection", (socket) ->
  getLatest

  socket.on "successevent", (data) ->
    log.info data

getLatest = (cb, req, res) ->
  # Scraping Medium.com profile for latest posts @ count
  articles = []
  user = "Vlokshin"
  count = 2
  request
    uri: host+user+"/latest/"
  , (err, response, body) ->
    self = this
    self.items = new Array()
    # Checking for errors
    log.error "getLatest() :: Mission Failed:", err if err and response.statusCode isnt 200

    # Passing callback
    if cb
      cb(body)
      return
    # Send the body param as the HTML code we will parse in jsdom
    # also tell jsdom to attach jQuery in the scripts and loaded from jQuery.com
    jsdom.env
      html: body
      scripts: ["http://code.jquery.com/jquery-1.6.min.js"]
    , (err, window) ->

      # Use jQuery just as in a regular HTML page
      $ = window.jQuery

      $entries = $("body").find(".post-item-title:lt("+count+")")

      $entries.each (i, item) ->
        $title = $(item).children("a").text()
        $href = $(item).children("a").attr("href")
        $_href = "http://www.medium.com" + $href

        self.items[i] =
          title: $title
          href: $_href
        articles = self.items
      socket.emit("articles", articles)
      log.info "getLatest() :: Scraper returned", articles
      res.end "Done!"
# Routes
app.get "/", routes.index
app.get "/getlatest", scrape.getLatest
app.get "/getrecommended", scrape.getRecommended



# And finally
server.listen app.get("port"), ->
  log.info "SM Engine running on port",app.get("port"),"in",app.get("env"),"mode."
