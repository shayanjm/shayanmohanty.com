log = require("logg").getLogger("SM.core.scrape")
jsdom = require("jsdom")
request = require("request")
scraper = module.exports = {}
host = null

# Initialization
scraper.init = (done) ->
  log.info "init() :: Initializing web scraper..."
  # Figure out some success metric... Host for now
  log.info "init() :: Host is currently:", host
  return if host isnt null
  host = "http://medium.com/@shayanjm"
  log.info "init() :: Setting host to:", host, "... done!"
  done()

scraper.start = (done, res) ->
  # Scraping Medium.com profile
  request
    uri: "http://www.medium.com/@shayanjm"
  , (err, response, body) ->
    self = this
    self.items = new Array() #I feel like I want to save my results in an array

    # Checking for errors
    log.error "Request error.", err  if err and response.statusCode isnt 200

    # Send the body param as the HTML code we will parse in jsdom
    # also tell jsdom to attach jQuery in the scripts and loaded from jQuery.com
    jsdom.env
      html: body
      scripts: ["http://code.jquery.com/jquery-1.6.min.js"]
    , (err, window) ->

      # Use jQuery just as in a regular HTML page
      $ = window.jQuery
      log.info "start() :: Scraper returned", $(".post-item-title").text()
      res.end $(".post-item-title").text()


