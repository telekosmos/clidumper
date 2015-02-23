
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
should = chai.should()
chai.use(chaiAsPromised)

cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'

describe 'Parser for the "dirty-json" config file', () ->
  cfgFile = ''
  JSONParser = {}

  beforeEach () ->
    cfgFile = "#{cfg.paths.root}/resources/test.json"
    JSONParser = require "#{cfg.paths.root}/#{cfg.paths.jsLib}/fileparser"

  it 'should get a file from the cli arguments', () ->
    fp = new JSONParser(cfgFile);
    should.exist(fp);
    promise = fp.read(cfgFile);
    promise.should.eventually.be.fulfilled;
    promise.should.eventually.not.be.empty;

  it 'should get the file contents as string', () ->
    fp = new JSONParser(cfgFile);
    should.exist(fp);
    promise = fp.read(cfgFile);
    promise.should.eventually.be.fulfilled;
    promise.should.eventually.be.a('string');
    promise.should.eventually.to.have.length.above(2);
    promise.should.eventually.contain('server');

  it 'should show another way to deal with promises', () ->
    fp = new JSONParser(cfgFile);
    should.exist(fp);

    fp.read(cfgFile)
    .then (val) ->
      # val.should.contain('server');
      val.should.be.a('string')
    .catch (err) ->
      console.error "ERR:\n #{err}"

    ###
    fp.read(filename).then(function(val) {
    console.log('With full of shit:\n'+val);
    });
    ###

  xit 'should print the file contents', () ->
    jp = new JSONParser(cfgFile)
    should.exist(jp)
    should.exist(jp.printJSON)
    jp.printJSON()


  it 'should parse dirty json file content', () ->
    jp = new JSONParser(cfgFile)

    promise = jp.parse()
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'object'
    promise.should.eventually.to.include.keys 'db', 'server', 'dumps'



  it 'should get a connection object for bd', () ->
    console.log 'Get a connection object for bd'
    jp = new JSONParser(cfgFile)

    jp.parse().then (jsonObj) ->
      console.log 'Inside the then testing for db config params'
      should.exist(jsonObj.db)
      should.exist(jsonObj.server)
      should.exist(jsonObj.dumps)
      jsonObj.dumps.should.be.an 'array'
      jsonObj.server.should.be.an 'object'
      dumps = jsonObj.dumps
      dumps.should.to.have.length.gt 1
      dumps[0].rep.should.be.true


  it 'should get a connection object for app server', () ->
    jp = new JSONParser(cfgFile)

    jp.parse().then (jsonObj) ->
      should.exist(jsonObj.server)
      jsonObj.server.should.to.include.keys 'host', 'port', 'app', 'servicePath'

  it 'should get a list of data retrieval config objects', () ->
    jp = new JSONParser(cfgFile)

    jp.parse().then (jsonObj) ->
      should.exist(jsonObj.dumps)
      jsonObj.dumps.should.be.an 'array'
      jsonObj.dumps.should.have.length.gte 0
      oneDump = jsonObj.dumps[0]
      should.exist(oneDump)
      oneDump.should.include.keys 'prj', 'questionnaire', 'section', 'group'
