
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
scrape = require("./core/scrape")
async = require("async")
log = require("logg").getLogger("SM.main")
app = express()

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


# Initialization
initSequence = [scrape.init]

log.info ""
async.series initSequence, (err) ->
  if err
    log.warn "init() :: Failed to initialize. Error:", err
    process.exit 1
  else
    log.info "init() :: Initialization Complete"
    return


# And finally
http.createServer(app).listen app.get("port"), ->
  console.log "Landing page running on port " + app.get("port") + " in " + app.get("env") + " mode."
