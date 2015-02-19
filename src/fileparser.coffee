
Promise = require 'bluebird'
dJSON = require 'dirty-json'
fs = require 'fs'

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
      fileJSON = jsonObj

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