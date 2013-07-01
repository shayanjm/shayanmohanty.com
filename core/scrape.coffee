select = require("soupselect").select
htmlparser = require("htmlparser")
log = require("logg").getLogger("SM.core.scrape")
http = require("http")
sys = require("sys")
scraper = module.exports = {}
host = null
scraper.init = (done) ->
  log.info "init() :: Initializing web scraper..."
  # Figure out some success metric...
  log.info "init() :: Host is currently:", host
  return if host isnt null
  host = "http://medium.com"
  log.info "init() :: Setting host to:", host, "... done!"
  done()




