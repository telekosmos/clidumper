


chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
should = chai.should()
chai.use(chaiAsPromised)

Cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'

describe 'End2End application workflow', () ->
  cfgFile = ''
  CLIParser = {}
  JSONParser = DBRetriever = undefined

  beforeEach () ->
    cfgFile = "#{Cfg.paths.root}/resources/test.json"
    # JSONParser = require "#{cfg.paths.root}/#{cfg.paths.jsLib}/fileparser"
    CLIParser = require "#{Cfg.paths.root}/lib/cliparser"
    JSONParser = require "#{Cfg.paths.root}/lib/fileparser"
    DBRetriever = require "#{Cfg.paths.root}/lib/dbretriever"
    process.argv.length = 0

  it 'should create an command line parser object', () ->
    cliParser = new CLIParser()
    should.exist cliParser
    process.argv = ['node', 'cli', '-b', "#{Cfg.paths.root}/resources/test.json"]
    file = cliParser.parse()
    should.exist file
    file.should.not.be.empty
    file.should.to.contain 'test.json'

  it 'should get an object from the config file', () ->
    cliParser = new CLIParser()
    process.argv = ['node', 'cli', '-b', "#{Cfg.paths.root}/resources/test.json"]
    file = cliParser.parse()
    should.exist JSONParser
    jsonParser = new JSONParser file
    should.exist jsonParser
    cfgObjPromise = jsonParser.parse()
    cfgObjPromise.should.eventually.be.fulfilled
    cfgObjPromise.should.eventually.to.include.keys 'db', 'server', 'dumps'

    cfgObjPromise.then (jsonObj) ->
      jsonObj.dumps.should.have.length.above 0
      jsonObj.db.should.to.include.keys 'host', 'name', 'user', 'pwd'
      jsonObj.server.should.to.include.keys 'user', 'pass', 'authPath', 'servicePath', 'app'

  it 'should get database params for dumps', () ->
    cliParser = new CLIParser()
    process.argv = ['node', 'cli', '-b', "#{Cfg.paths.root}/resources/test.json"]
    file = cliParser.parse()
    should.exist JSONParser
    jsonParser = new JSONParser(file)
    cfgObjPromise = jsonParser.parse()
    should.exist DBRetriever
    cfgObjPromise.should.eventually.be.fulfilled
    cfgObjPromise.then (cfgObj) ->
      should.exist cfgObj
      should.exist cfgObj.db
      dbRtr = new DBRetriever cfgObj.db
      should.exist dbRtr
      should.exist cfgObj.dumps
      cfgObj.dumps.should.have.length 3
      # and loop over the dumps, getting the dbIds for every dump
      # then try to mock the downloads...
      dumpPromises = []
      dbRtr.connect()
      cfgObj.dumps.every (dump, index) ->
        dumpProm = dbRtr.getAll dump.prj, dump.group, dump.questionnaire
        dumpPromises.push dumpProm

      dumpPromises.should.have.length 3;
      dumpPromises.every (promise) ->
        promise.should.eventually.be.fulfilled
        promise.then (val) ->
          should.exist val
          should.exist val.prjIds
          val.prjIds[0].idprj.should.be.equal 50
          console.log "\n**-> Ids: p: #{val.prjIds[0].idprj};
            g: #{val.grpIds[0].idgroup};
            i: #{val.intrvIds[0]?.idinterview}"
