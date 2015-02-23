


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


