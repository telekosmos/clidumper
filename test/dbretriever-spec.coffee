
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'

# DBRetreiver = require "#{cfg.paths.root}/#{cfg.paths.src}/dbretriever.coffee"
DBRetreiver = require "#{cfg.paths.root}/#{cfg.paths.jsLib}/dbretriever"
should = chai.should()
chai.use(chaiAsPromised)



describe 'Database retrieval of ids based on dump parameters', () ->
  dbRetr = connection = undefined
  dumpCfgMock =
    db:
      host: 'localhost'
      name: 'appform'
      user: 'gcomesana'
      pwd: 'appform'
    dumps: [
      prj: "PanGen-Eu"
      questionnaire: "QES_Español"
      group: "spain"
      section: 2
      rep: true
      out: ""
    ,
      prj: "Isblac"
      questionnaire: "IDC_Espanol"
      group: "hospital de orihuela"
      section: 1
      rep: true
      out: ""
    ]

  beforeEach () ->
    dbRetr = new DBRetreiver(dumpCfgMock.db)

  it 'should setup a db connection', () ->
    should.exist(dbRetr)
    dbRetr.connect()
    sequelize = dbRetr.sequelize()
    should.exist(sequelize)
    sequelize.should.be.an 'object'

  it 'should check the connection', () ->
    dbRetr.connect()
    checkPromise = dbRetr.isConnected()
    checkPromise.should.eventually.fulfilled
    checkPromise.should.eventually.be.undefined # Ehmmm... sequelize way

  it 'should check there is no connection', () ->
    checkPromise = dbRetr.isConnected()
    checkPromise.should.eventually.fulfilled
    checkPromise.should.eventually.be.false

  it 'should retrieve project dbid', () ->
    dbRetr.connect()
    promise = dbRetr.getPrjId(dumpCfgMock.dumps[0].prj)
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'array'
    # promise.should.eventually.be.an 'object'
    promise.should.eventually.to.have.length 1
    promise.then (val) ->
      console.log 'Testing the promise result'
      should.exist(val)
      val.should.to.have.length 1
      val[0].should.be.an 'object'
      should.exist(val[0].idprj)
      val[0].idprj.should.be.equal 50
      console.log "EO promise result testing: #{val[0].idprj}"

  it 'should retrieve primary group dbid', () ->
    dbRetr.connect()
    promise = dbRetr.getGrpId(dumpCfgMock.dumps[0].group)
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'array'
    promise.then (val) ->
      should.exist(val)
      val.should.to.have.length 1
      val[0].should.be.an 'object'
      should.exist(val[0].idgroup)
      val[0].idgroup.should.be.gt 1
      console.log "EO promise result testing (group): #{val[0].idgroup}"


  it 'should retrieve secondary group dbid', () ->
    dbRetr.connect()
    promise = dbRetr.getGrpId(dumpCfgMock.dumps[1].group)
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'array'
    # promise.should.eventually.be.equal 1301
    promise.then (val) ->
      should.exist(val)
      val.should.to.have.length 1
      val[0].should.be.an 'object'
      should.exist(val[0].idgroup)
      val[0].idgroup.should.be.eq 1301
      console.log "EO promise result testing (secondary): #{val[0].idgroup}"


  it 'should retreive questionnaire dbid', () ->
    dbRetr.connect()
    intrvName = dumpCfgMock.dumps[0].questionnaire
    prjName = dumpCfgMock.dumps[0].prj
    promise = dbRetr.getIntrvId intrvName, prjName
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'array'
    # promise.should.eventually.be.equal 50
    promise.then (val) ->
      should.exist(val)
      val.should.to.have.length.gte 1
      val[0].should.be.an 'object'
      should.exist(val[0].idinterview)
      val[0].idinterview.should.be.eq 50
      console.log "EO promise result testing (intrv): #{val[0].idinterview}"


  it 'should return undefined when no questionnaire', () ->
    dbRetr.connect()
    promise = dbRetr.getIntrvId 'QES_Spain', 'ISBlaC'
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.empty
    promise.then (val) ->
      should.exist(val)
      val.should.be.empty
      val.length.should.be.eq 0


  it 'should return all id values', () ->
    dbRetr.connect()
    prjName = dumpCfgMock.dumps[0].prj
    grpName = dumpCfgMock.dumps[0].group
    intrvName = dumpCfgMock.dumps[0].questionnaire
    promise = dbRetr.getAll prjName, grpName, intrvName
    promise.should.eventually.be.fulfilled
    promise.should.eventually.be.an 'object'
    promise.then (objVal) ->
      should.exist objVal
      should.exist objVal.prjIds
      should.exist objVal.intrvIds
      should.exist objVal.grpIds
      objVal.prjIds[0].idprj.should.be.gt 0
      objVal.grpIds[0].idgroup.should.be.gt 0
      objVal.intrvIds.length.should.be.equal 1
      ###
      console.log "Ids: p: #{objVal.prjIds[0].idprj};
        g: #{objVal.grpIds[0].idgroup};
        i: #{objVal.intrvIds[0].idinterview}"
      ###

