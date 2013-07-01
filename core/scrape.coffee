log = require("logg").getLogger("SM.core.scrape")
request = require("request")
scraper = module.exports = {}
host = null

# Initialization
scraper.init = (done) ->
  log.info "init() :: Initializing web scraper..."
  # Figure out some success metric... Host for now
  log.info "init() :: Host is currently:", host
  return if host isnt null
  host = "http://medium.com"
  log.info "init() :: Setting host to:", host, "... done!"
  done()


