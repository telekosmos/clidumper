
# #!/usr/bin/env node
Cfg = require './config/init'

CLIParser = require "#{Cfg.paths.root}/lib/cliparser"
JSONParser = require "#{Cfg.paths.root}/lib/fileparser"
DBRetriever = require "#{Cfg.paths.root}/lib/dbretriever"
Downloader = require "#{Cfg.paths.root}/lib/downloader"

cliParser = new CLIParser()
jsonCfgFile = cliParser.parse()

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
    dnldr.serverAlive().then (alive) ->
      if !alive
        console.log "Unable to connect to application host: server may be unavailable"
        process.exit()

      dumpPromises = []
      dumps.every (dump, index) ->
        dumpProm = dbRetr.getAll dump.prj, dump.group, dump.questionnaire
        # dumpPromises.push dumpProm
        dumpPromises[index] = dumpProm

      dumpPromises.every (promise, index) ->
        promise.then (ids) ->
          dumps[index].prjid = ids.prjIds[0].idprj
          dumps[index].grpid = ids.grpIds[0].idgroup
          dumps[index].intrvid = ids.intrvIds[0]?.idinterview
          dumps[index]
        .then (myDump) ->
          console.log "Download for: #{myDump.prj} (#{myDump.prjid});
              #{myDump.group} (#{myDump.grpid}); #{myDump.questionnaire} (#{myDump.intrvid});
              sec: #{myDump.sec ? myDump.section}; repeatable: #{myDump.rep}"








    ###
    dnldr = new Downloader(serverCfg)
    if dnldr.serverAlive()
      dnldr.login().then
    ###




