
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


# Routes
app.get "/", routes.index
app.get "/getlatest", scrape.getLatest
app.get "/getrecommended", scrape.getRecommended



# And finally
server.listen app.get("port"), ->
  log.info "SM Engine running on port",app.get("port"),"in",app.get("env"),"mode."
