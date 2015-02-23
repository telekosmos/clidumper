
Promise = require 'bluebird'
dJSON = require 'dirty-json'
fs = require 'fs'
_ = require 'lodash'

Promise.promisifyAll(fs)

FileParser = (filename) ->
  fileJSON = undefined
  readFilePromise = fs.readFileAsync filename, {encoding: 'utf-8'}
  dbParams = {}
  serverParams = {}
  dumps = []

  # return another promise (asynchronous) such that the objParser params are out of sync
  parseConfig = () ->
    readFile()
    .then dJSON.parse
    .then (jsonObj) ->
      throw "#{filename} error: json file malformed, could not be parsed" if jsonObj == null
      if jsonObj.dumps? and jsonObj.dumps?.length > 0
        throw "#{filename} error: no db config specified" if _.has(jsonObj, 'db') == false
        throw "#{filename} error: no db user config specified" if _.has(jsonObj.db, 'user') == false
        throw "#{filename} error: no db host config specified" if _.has(jsonObj.db, 'host') == false
        throw "#{filename} error: no db name config specified" if _.has(jsonObj.db, 'name') == false
        throw "#{filename} error: no db password config specified" if _.has(jsonObj.db, 'pwd') == false
        throw "#{filename} error: no server config specified" if _.has(jsonObj, 'server') == false
        throw "#{filename} error: no server host config specified" if _.has(jsonObj.server, 'host') == false
        throw "#{filename} error: no service path config specified" if _.has(jsonObj.server, 'servicePath') == false
        throw "#{filename} error: no server app user config specified" if _.has(jsonObj.server, 'user') == false
        throw "#{filename} error: no server app password config specified" if _.has(jsonObj.server, 'pass') == false
        throw "#{filename} error: no server authorization path config specified" if _.has(jsonObj.server, 'authPath') == false

      fileJSON = jsonObj
    .catch (err) ->
      console.error "#{filename} parser err: #{err}"

  printJSON = () ->
    this.read().then (data) -> console.log "printJSON:\n #{data}"

  readFile = () -> # return a fucking promise
    readFilePromise ?= fs.readFileAsync filename, {encoding: 'utf-8'}


  setParams = (jsonObj) ->


  objParser =
    dbParams: dbParams,
    serverParams: serverParams,
    dumps: dumps,
    printJSON: printJSON,
    read: readFile,
    parse: parseConfig


module.exports = FileParser;