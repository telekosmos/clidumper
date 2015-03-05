

Cfg = require "#{__dirname}/../config/init"
Promise = require 'bluebird'
colors = require 'colors'

###
CLIParser = require "#{Cfg.paths.root}/lib/cliparser"
JSONParser = require "#{Cfg.paths.root}/lib/fileparser"
DBRetriever = require "#{Cfg.paths.root}/lib/dbretriever"
Downloader = require "#{Cfg.paths.root}/lib/downloader"
###
CLIParser = require "./cliparser"
JSONParser = require "./fileparser"
DBRetriever = require "./dbretriever"
Downloader = require "./downloader"

module.exports = ->
  cliParser = new CLIParser()
  jsonCfgFile = cliParser.parse()
  dumps = []
  dbRetr = undefined
  dnldr = undefined
  loggedOut = false
  globServerConfig = null
  globDbConfig = null

  if jsonCfgFile
    jsonParser = new JSONParser(jsonCfgFile)

    jsonParser.parse().then (jsonObj) ->
      if !jsonObj?
        console.log "Configuration file malformed. You can check the content by validating at http://rmarcus.info/dirty-json/"
        process.exit(1)

      dbCfg = jsonObj.db
      dumps = jsonObj.dumps
      serverCfg = jsonObj.server
      if !dbCfg? or !serverCfg?
        console.log "No configuration for database and application server where found in config file".red
        process.exit()

      globDbConfig = dbCfg
      dbRetr = new DBRetriever dbCfg
      dbRetr.connect() # check if connection was right after this

      globServerConfig = jsonObj.server
      dnldr = new Downloader serverCfg
      dnldr.serverAlive()

    .then (alive) ->
      if !alive
        msg = "Unable to connect to application host: ".red
        myHost = if globServerConfig.port then globServerConfig.host+':'+globServerConfig.port else globServerConfig.host
        msg = msg + "#{myHost}".red.underline + " server may be unavailable".red
        console.log msg
        process.exit()

      dumpPromises = []
      dumps.every (dump, index) ->
        dumpProm = dbRetr.getAll dump.prj, dump.group, dump.questionnaire
        # dumpPromises.push dumpProm
        dumpPromises[index] = dumpProm
      Promise.all(dumpPromises)

    .then (dumpIds) ->
      # Merge db ids with names in dump config
      dumpIds.forEach (ids, index) ->
        dumps[index].prjid = ids.prjIds[0].project_code # idprj
        dumps[index].grpid = ids.grpIds[0].idgroup
        dumps[index].intrvid = ids.intrvIds[0]?.idinterview

      dnldr.login()

    .then (resp) ->
      dumpReqs = []
      dumps.forEach (dump, index) ->
        dumpCfg =
          prjid: dump.prjid # actually is the project code
          grpid: dump.grpid
          intrvid: dump.intrvid
          secid: dump.section # actually is the section order in the questionnaire

        allParamsFilled = dumpCfg.prjid? and dumpCfg.grpid? and dumpCfg.intrvid? and dumpCfg.secid?

        if allParamsFilled
          # ISBlaC-Aliquots_SP_New-sec1.ext
          filename = "#{dump.prj}-#{dump.group}-#{dump.questionnaire}-sec#{dumpCfg.secid}"
          dumpCfg.repd = 1 if dump.repd
          dumpCfg.filename = filename
          dumpReqs.push dumpCfg

        else
          console.log """Error in dump #{index+1}: some data could not be retrieved from database (#{globDbConfig.name}):
            \tProject id: #{dumpCfg.prjid}
            \tGroup id: #{dumpCfg.grpid}
            \tQuestionnaire id: #{dumpCfg.intrvid}
            \tSection order: #{dumpCfg.secid}
          """.red

      console.log "Getting #{dumpReqs.length} dumps".red.bold
      Promise.reduce dumpReqs
      , (total, dumpReqCfg, index, numOfdumps) ->
        if dumpReqCfg.repd
          dnldr.getXlsx dumpReqCfg, "#{dumpReqCfg.filename}.xlsx"
        else
          dnldr.getCsv dumpReqCfg, "#{dumpReqCfg.filename}.csv"
      , []

    .then (resp) ->
      console.log 'About to logout'
      dnldr.logout()

    .then (resp) ->
      loggedOut = true
      console.log "\nClient logged out from application. Results can take a bit longer to arrive".green
      console.log 'Please, wait until the prompt returns'.green

    .catch (err) ->
      dnldr.logout() if !loggedOut
      console.log "Error while downloading data: #{err.stack}".red.inverse

    ###
      dumps

    .then (theDumps) ->
      theDumps.forEach (myDump) ->
        console.log "Download for: #{myDump.prj} (#{myDump.prjid});
            #{myDump.group} (#{myDump.grpid}); #{myDump.questionnaire} (#{myDump.intrvid});
            sec: #{myDump.sec ? myDump.section}; repeatable: #{myDump.rep}"
    ###
  else
    console.log "No configuration file was provided"


###
dnldr = new Downloader(serverCfg)
if dnldr.serverAlive()
  dnldr.login().then
###




