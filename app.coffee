
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
request = require("request")
jsdom = require("jsdom")
async = require("async")
url = require("url")
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

# Routes
app.get "/", routes.index

app.get "/scrape", (req, res) ->
  
  # Scraping Medium.com profile
  request
    uri: "http://medium.com/@shayanjm"
  , (err, response, body) ->
    self = this
    self.items = new Array() #I feel like I want to save my results in an array
    
    # Checking for errors
    console.log "Request error."  if err and response.statusCode isnt 200
    
    # Send the body param as the HTML code we will parse in jsdom
    # also tell jsdom to attach jQuery in the scripts and loaded from jQuery.com
    jsdom.env
      html: body
      scripts: ["http://code.jquery.com/jquery-1.6.min.js"]
    , (err, window) ->
      
      #Use jQuery just as in a regular HTML page
      $ = window.jQuery
      console.log $(".post-item-title").text()
      res.end $(".post-item-title").text()


# Initialization
initSequence = [scrape.init]

log.info "init() :: Beginning initialization sequence..."
io = require('socket.io').listen(server)
log.info "init() :: Configuring Socket.IO for Long-Polling..."
io.configure ->
  io.set "transports", ["xhr-polling"]
  io.set "polling duration", 10
log.info "init() :: Long-Polling configuration done!"
async.series initSequence, (err) ->
  if err
    log.warn "init() :: Failed to initialize. Error:", err
    process.exit 1
  else
    log.info "init() :: Initialization Complete"
    return


# And finally
server.listen app.get("port"), ->
  log.info "SM Engine running on port",app.get("port"),"in",app.get("env"),"mode."
