if window?
  exports = window.exports
  require = window.require

data = undefined

binaryhttp = require 'binaryhttp'
region = require 'region'
chunkdata = require 'chunkdata'
render = require 'render'
nbt = require 'nbt'

whichChunks = (region) ->
  count = 0
  chunks = {}

onProgress = (evt) ->
  $('#proginner').width $('#progouter').width() * (evt.position/evt.total)

delay = (ms, func) ->
  setTimeout func, ms

options = {}

done = (arraybuffer) ->
  delay 150, ->
    start = new Date().getTime()
    data = arraybuffer    
    testregion = new region.Region(data)        
    renderer = new render.RegionRenderer(testregion, options)
    total = new Date().getTime() - start
    seconds = total / 1000.0
    console.log "loaded in #{seconds} seconds"

exports.runTests = ->
  pos = window.location.href.indexOf '?'
  paramstr = window.location.href.substr pos+1
  params = paramstr.split '&'
  options = {}
  for param in params
    tokens = param.split '='
    options[tokens[0]] = tokens[1]
  console.log options
  binaryhttp.loadBinary options.url, onProgress, done
 

  
