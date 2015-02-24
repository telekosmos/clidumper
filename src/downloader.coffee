

Promise = require 'bluebird'
# request = require 'request'
rp = require 'request-promise'
_ = require 'lodash'
fs = require 'fs'

###
# It makes a request to get a dump from the databse through the application,
# requesting a URL like:
# - http://localhost:8080/admtool/datadump/PanGen-Eu-QES_Español-sec3.csv?what=dump&prjid=157&grpid=401&intrvid=50&secid=3
# - http://localhost:8080/admtool/datadump/ISBlaC-Aliquots_SP_New-sec1.xlsx?what=dump&prjid=188&grpid=4&intrvid=4100&secid=1&repd=1
# @param {Object} the server parameters to make a connection
###
Downloader = (serverParams) ->
  expose = {}

  host = serverParams.host
  port = serverParams.port || 8080
  appName = serverParams.app || 'admtool'
  servicePath = serverParams.servicePath || 'datadump'
  username = serverParams.user
  passwd = serverParams.pass


  urlIndex = "http://#{host}:#{port}/#{appName}/index.jsp"
  authUrl = "http://#{host}:#{port}/#{appName}/#{serverParams.authPath}"
  reqUrl = "http://#{host}:#{port}/#{appName}/#{servicePath}"
  logoutUrl = "http://#{host}:#{port}/#{appName}/logout.jsp?adm=1"

  cookieJar = rp.jar()


  index = () ->
    reqPromise = rp {url: urlIndex, resolveWithFullResponse: true, jar: cookieJar}
    reqPromise

  ###
  # Checks if the server is alive by requesting the index page
  # @return {boolean} true if is alive; otherwise false
  # @promise
  ###
  expose.serverAlive = () ->
    index().then (httpResp) ->
      true
    .catch (err) ->
      false

  expose.logout = () ->
    logoutObj =
      url: logoutUrl
      followAllRedirects: true
      resolveWithFullResponse: true
      jar: cookieJar
      # jar: true

    rp logoutObj


  ###
  # Get the cookies from the server for this session as an array of strings
  # @return {Array} an array with the cookies as strings
  ###
  expose.getCookies = () ->
    ckString = cookieJar.getCookieString(urlIndex)
    cookieSet = ckString.split ';'
    cookieSet

  ###
  # Get the cookies from the server for this session as an array of objects
  # @return {Array} an array with the cookies as objects key=val
  ###
  expose.getCookiesList = () ->
    cookieJar.getCookies(urlIndex)

  ###
  # Authentify into the app server in order to be able to make requests for downloads
  # @return {Object} the http response from server
  # @promise
  ###
  expose.login = expose.authentify = () ->
    formData =
      j_username: username
      j_password: passwd

    reqObj =
      url: authUrl
      form: formData
      method: 'POST'
      # jar: true
      jar: cookieJar
      resolveWithFullResponse: true
      followAllRedirects: true

    index().then (httpResp) -> rp reqObj
    # .catch (err) -> console.error "Authentication ERR: #{err}"



  expose.buildDumpUrl = (dumpParams, filename) ->
    url = "#{reqUrl}/#{filename}?"
    qString = "what=dump&"
    _.forIn dumpParams, (val, prop) ->
      qString = "#{qString}#{prop}=#{val}&"

    qString = qString.substr 0, qString.length-1
    url = url + qString

  ###
  # It gets the dump as a csv file by make a request such like
  # http://localhost:8080/admtool/datadump/PanGen-Eu-QES_Español-sec3.csv?what=dump&prjid=157&grpid=401&intrvid=50&secid=3
  # @param {Object} are the database identifiers to retrieve the data
  # @param {String} the name of the file to create to be downloaded
  # @return {Object}
  # @promise
  ###
  expose.getCsv = (csvParams, filename) ->
    url = this.buildDumpUrl csvParams, filename
    dumpObj =
      url: url
      followAllRedirects: true
      resolveWithFullResponse: true
      jar: cookieJar

    rp(dumpObj).pipe fs.createWriteStream(filename)
    ###
    new Promise (resolve, reject) ->
      console.log "CSV: #{dumpObj.url}"
      resolve dumpObj.url

    ###


  expose.getXlsx = (xlsxParams, filename) ->
    url = this.buildDumpUrl xlsxParams, filename
    dumpObj =
      url: url
      followAllRedirects: true
      resolveWithFullResponse: true
      jar: cookieJar

    rp(dumpObj).pipe fs.createWriteStream(filename)

  expose

module.exports = Downloader