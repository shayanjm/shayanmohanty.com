log = require("logg").getLogger("SM.core.scrape")
jsdom = require("jsdom")
request = require("request")
scraper = module.exports = {}
host = null

# Initialization
scraper.init = (done) ->
  log.info "init() :: Initializing web scraper..."
  # Figure out some success metric... Host for now
  return if host isnt null
  host = "http://www.medium.com/@"
  log.info "init() :: Host is currently:", host
  done()

scraper.getLatest = (done, res) ->
  # Scraping Medium.com profile for latest posts @ count
  user = "Vlokshin"
  count = 2
  request
    uri: host+user+"/latest/"
  , (err, response, body) ->
    self = this
    self.items = new Array()
    # Checking for errors
    log.error "getLatest() :: Mission Failed:", err if err and response.statusCode isnt 200

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
      log.info "getLatest() :: Scraper returned", self.items
      res.end "Done!"


scraper.getRecommended = (done, res) ->
  # TODO - REPLICATE getLatest()
  # Scraping Medium.com profile for recommended post
  user = "shayanjm"
  request
    uri: host+user
  , (err, response, body) ->

    # Checking for errors
    log.error "getRecommended() :: Mission Failed:", err if err and response.statusCode isnt 200

    jsdom.env
      html: body
      scripts: ["http://code.jquery.com/jquery-1.6.min.js"]
    , (err, window) ->

      $ = window.jQuery
      log.info "getRecommended() :: Scraper returned", $(".post-item-title:lt(1)").append("\n").html()
      res.end $(".post-item-title:lt(1)").append("\n").html()
      done()

