
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
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

# development only
app.use express.errorHandler()  if app.get("env") is "development"
app.on "error", (err) ->
	console.error "Houston, we have a problem: " + err
app.get "/", routes.index
http.createServer(app).listen app.get("port"), ->
  console.log "Landing page running on port " + app.get("port") + " in " + app.get("env") + " mode."
