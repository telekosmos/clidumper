
# #!/usr/bin/env node
Cfg = require "#{__dirname}/config/init"
Promise = require 'bluebird'

CLIParser = require "#{Cfg.paths.root}/lib/cliparser"
JSONParser = require "#{Cfg.paths.root}/lib/fileparser"
DBRetriever = require "#{Cfg.paths.root}/lib/dbretriever"
Downloader = require "#{Cfg.paths.root}/lib/downloader"

cliParser = new CLIParser()
jsonCfgFile = cliParser.parse()
dumps = []
dbRetr = undefined
dnldr = undefined
loggedOut = false

if jsonCfgFile
  jsonParser = new JSONParser(jsonCfgFile)

  jsonParser.parse().then (jsonObj) ->
    dbCfg = jsonObj.db
    dumps = jsonObj.dumps
    serverCfg = jsonObj.server
    if !dbCfg? or !serverCfg?
      console.log "No configuration for database and application server where found in config file"
      process.exit()

    dbRetr = new DBRetriever dbCfg
    dbRetr.connect() # check if connection was right after this

    dnldr = new Downloader serverCfg
    dnldr.serverAlive()

  .then (alive) ->
    if !alive
      console.log "Unable to connect to application host: server may be unavailable"
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
        if dumpCfg.repd
          dnldr.getXlsx dumpCfg, "#{filename}.xlsx"
        else
          dnldr.getCsv dumpCfg, "#{filename}.csv"
      else
        console.log """Error in dump #{index+1}: some data could not be retreived from database (undefined):
          \tProject id: #{dumpCfg.prjid}
          \tGroup id: #{dumpCfg.grpid}
          \tQuestionnaire id: #{dumpCfg.intrvid}
          \tSection order: #{dumpCfg.secid}
        """

  .then (resp) ->
    dnldr.logout()

  .then (resp) ->
    loggedOut = true
    console.log "\nClient logged out from application. Results can take a bit longer to arrive"
    console.log 'Please, wait until the prompt returns'

  .catch (err) ->
    dnldr.logout() if !loggedOut
    console.log "Error while downloading data: #{err.stack}"

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




