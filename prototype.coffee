
Promise = require 'bluebird'
Sequelize = require 'sequelize'
_ = require 'lodash'
appcfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'
request = require 'request'
fs = require 'fs'

jsonObj =
  db:
    host: "localhost",
    name: "appform",
    user: "gcomesana",
    pwd: "appform"
  ,
  server:
    host: 'localhost'
    app: 'admtool'
    servicePath: 'datadump'
    user: 'gcomesana@cnio.es'
    pass: 'techn1C0'
    authPath: 'jsp/j_security_check'
  ,
  dumps: [
    prj: "Pangen-EU",
    questionnaire: "QES_Spain",
    group: "Spain",
    section: 2,
    rep: true,
    out: ""
  ,
    prj: "Pangen-EU",
    questionnaire: "RecogidaMuestra_ES",
    group: "Spain",
    section: 3,
    rep: true,
    out: ""
  ]
jsonStr = JSON.stringify jsonObj


FileReader = () ->

  readFile = () ->
    promiseFunc = (resolve, reject) ->
      guard = Math.floor(Math.random()*10)
      even = (guard % 2) == 0
      setTimeout () ->
        if even then resolve "#{jsonStr}" else reject "err of: #{guard}"
      , 1200

    deferred = new Promise(promiseFunc)

  obj =
    read: readFile


ParserJson = () ->

  parse = () ->
    promise = new Promise (resolve, reject) ->
      guard = Math.floor(Math.random()*10)
      even = (guard % 2) == 0
      setTimeout () ->
        if !even
          resolve JSON.parse(jsonStr)
        else
          reject "parse json err: #{guard}"
      , 1500

  obj =
    parse: parse


DBRetriever = () ->
  obj = {}
  sequelize = null

  dbMock = # mocking reference to de database
    prj: [
      name: "PanGen"
      id: 100
    ,
      prj: "Cancer"
      id: 101
    ]
    ,
    group: [
      name: "Spain"
      id: 400
    ,
      name: "Hospital"
      id: 401
    ]
    ,
    questionnaire: [
      name: "QES"
      id: 300
    ,
      name: "IDC"
      id: 303
    ]

  connect = () ->
    sequelize = dbMock
    null

  prjId = (prjName) ->
    _.result(_.find(sequelize.prj, {name: prjName}), 'id')

  grpId = (grpName) ->
    _.result(_.find(sequelize.group, {name: grpName}), 'id')

  intrvId = (intrvName) ->
    _.result(_.find(sequelize.questionnaire, {name: intrvName}), 'id')


  query = (what, name) ->
    if sequelize?
      switch what.toUpperCase()
        when 'PRJ' then prjId name
        when 'GRP' then grpId name
        when 'INTRV' then intrvId name
        else prjId name
    else
      undefined


  obj =
    connect: connect
    getGrpId: (name) -> query 'grp', name
    getPrjId: (name) -> query 'prj', name
    getIntrvId: (name) -> query 'intrv', name




RealDB = require "#{appcfg.paths.root}/lib/dbretriever"
##############################
fr = new FileReader()
pj = new ParserJson()
console.log 'About to read.then(parse) a file...'

db = new DBRetriever()

fr.read().then pj.parse
.then (val) ->
  console.log val
  db.connect()
  dump = val.dumps[0]
  grpId = db.getGrpId dump.group
.then (grpId) -> console.log "Then the retrieved group has id #{grpId}"
.catch (err) -> console.log "ERR: #{err}"

realDb = new RealDB(jsonObj.db)
realDb.connect()
realDb.isConnected().then (val) ->
  console.log "It is supposed we have a connection: #{val}"
.catch (err) ->
  console.error "Something was wrong :-S #{err}"

promise = realDb.getPrjId(jsonObj.dumps[1].prj)
promise.then (val) ->
  keys = _.keysIn(val[0])
  console.log "numOfKeys: #{keys.length} -> type:#{_.isArray(keys)? 'array': _.isObject(keys)? 'object': 'undef'}"
  for k in keys
    console.log "#{k}: #{val[0][k]}"
.catch (err) ->
  console.error "Err retrieving project id: #{err}"

# Downloader
urlAuth = 'http://localhost:8080/admtool/jsp/j_security_check'
urlIndex = 'http://localhost:8080/admtool/jsp/index.jsp'
urlGetHosps = 'http://localhost:8080/admtool/servlet/AjaxUtilServlet?what=hosp&grpid=301&prjid=-1'
urlLogout = 'http://localhost:8080/admtool/logout.jsp?adm=1'
realCookie = null

formData =
  j_username: 'gcomesana@cnio.es'
  j_password: 'techn1C0'

reqLoginObj =
  url: urlAuth
  form: formData
  method: 'POST'
  followAllRedirects: true
  resolveWithFullResponse: true
  jar: true

reqJson =
  url: urlGetHosps
  resolveWithFullResponse: true
  followAllRedirects: true
  jar: true

logoutObj =
  url: urlLogout
  followAllRedirects: true
  resolveWithFullResponse: true
  jar: true


console.log "\n\nPromise based request (simplified)!!!!"
cookieSet = []

rp = require 'request-promise'
cookieJar = rp.jar()
reqIndex = rp {url: urlIndex, resolveWithFullResponse: true, jar: cookieJar}
reqIndex.then (httpResp) ->
  console.log "Cookies from index: #{cookieJar.getCookieString(urlIndex)}"
  reqLoginObj.jar = cookieJar
  rp reqLoginObj
.then (httpRespBis) ->
  console.log "Cookies from index 2: #{cookieJar.getCookieString(urlIndex)}"
  reqJson.jar = cookieJar
  rp reqJson
.then (fullResp) ->
  console.log "The final json???: #{fullResp.body}"
  logoutObj.jar = cookieJar
  rp logoutObj
.then (finalResp) ->
  console.log "Goodbye with status! #{finalResp.statusCode}"
  console.log "And the cookies: #{cookieJar.getCookieString(urlIndex)}"
.catch (catchErr) ->
  console.error "Catch ERR: #{catchErr}"


console.log "\n*** Downloader..."
filename = 'ISBlaC-Aliquots_SP_New-sec3'
loggedOut = false
Downloader = require "#{appcfg.paths.root}/lib/downloader"
downloader = new Downloader(jsonObj.server)
downloader.login().then (resp) ->
  csvParams =
    prjid: 188
    grpid: 4
    intrvid: 4100
    secid: 3
    # repd: 1

  if csvParams.repd
    filename += '.xlsx'
    downloader.getXlsx csvParams, filename
  else
    filename += '.csv'
    downloader.getCsv csvParams, filename


.then (resp) ->
#  ws = fs.createWriteStream(filename)
#  resp.pipe(ws)
  console.log "Downloader cookies: #{downloader.getCookies()}"
  downloader.logout()
.then (resp) ->
  loggedOut = true
  console.log "Downloader log(ged)out with status: #{resp.statusCode}"
.catch (err) ->
  downloader.logout() if !loggedOut
  console.log "Downloader ERR: #{err.stack}"



###
reqPromise.then (httpResp) ->
  if httpResp
    console.log "Response: #{httpResp} -> cookie 1: "+httpResp.headers['set-cookie'][0]
    cookiesStr = httpResp.headers['set-cookie'][0]
    cookies = cookiesStr.split ';'
    cookieSet.push cookies[0]
    j = rp.jar()
    realCookie = rp.cookie cookies[0]
    j.setCookie realCookie, urlAuth
    # reqObj.jar = j
    reqObj.jar = true
    reqObj

.then rp
.then (httpRespBis) ->
  console.log "Response cookie 2: "+httpRespBis.headers['set-cookie'][0]
  cookieStr = httpRespBis.headers['set-cookie'][0]
  cookies = cookieStr.split ';'
  cookieSet.push cookies[0]
  j = rp.jar()
  myCookie = rp.cookie cookieSet[1]
  j.setCookie myCookie, reqJson.url
  # reqJson.jar = j
  reqJson.jar = true
  reqJson

.then rp
.then (fullResp) ->
  console.log "The final json???: #{fullResp.body}"
  logoutObj =
    url: urlLogout
    followAllRedirects: true
    resolveWithFullResponse: true
  j = rp.jar()
  myCookie = rp.cookie cookieSet[0]
  j.setCookie myCookie, reqJson.url
  # logoutObj.jar = j
  logoutObj.jar = true
  logoutObj

.then (rp)
.then (resp) ->
  console.log "Goodbye with status! #{resp.statusCode}"
.catch (catchErr) ->
  console.error "Catch ERR: #{catchErr}"
###

# request.debug = true
# should be requestIndex.then (resp) -> authentify.then (resp) -> downloads.then (resp) -> logout()
###
request urlIndex, (err, httpResp, body) ->
  if err
    console.log "ERR: #{err} -> #{err.stack}"
  else
    if httpResp
      console.log "Response: #{httpResp} -> cookie 1: "+httpResp.headers['set-cookie'][0]
      cookiesStr = httpResp.headers['set-cookie'][0]
      cookies = cookiesStr.split ';'
      j = request.jar()
      realCookie = request.cookie cookies[0]
      j.setCookie realCookie, urlAuth
      reqObj.jar = j

      request reqObj, (errBis, httpRespBis) ->
        if errBis
          console.log "ERRBis: #{err} -> #{err.stack}"
        else
          console.log "Response cookie 2: "+httpRespBis.headers['set-cookie'][0]

###





###
.on 'error', (err) ->
  console.log "Event err: #{err} -> #{err.stack}"
.on 'response', (resp) ->
  console.log "Response: #{resp.body}"
###


###
  cliparser.parse().then (file)->
  fileparser.parse().then (jsonObj) ->
    hostParams = jsonObj.host
    dbParams = jsonObj.db
    dumps = jsonObj.dumps
    dumps.forEach (dump) ->
      dbIds = dbRetr.getAll(dump)
      filename = dump.project+dump.group+dump.section+dump.rep
      downloader.getFile(dbIds, filename).then (f) ->
        writefile(f)

###

###
fr.read().then (val) ->
  console.log "Success: #{val}"
,
(err) -> console.log "ERR: #{err}"
###
