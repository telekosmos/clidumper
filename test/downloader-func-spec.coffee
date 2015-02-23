

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
Cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'
Downloader = require "#{Cfg.paths.root}/lib/downloader"
sinon = require 'sinon'

should = chai.should()
chai.use(chaiAsPromised)


describe 'Downloader data using params from config file', () ->
  downloader = null
  hostParams =
    host: 'localhost'
    app: 'admtool'
    servicePath: 'datadump'
    user: 'gcomesana@cnio.es'
    pass: 'techn1C0'
    authPath: 'jsp/j_security_check'

  dumpParams = [
    prjid: 157
    grpid: 4
    intrvid: 1301
    secid: 6
    repd: 1
    # filename: 'PanGen-Eu-IDC_Espanol-sec6.xlsx'
  ,
    prjid: 157
    grpid: 401
    intrvid: 50
    secid: 3
    # filename: 'PanGen-Eu-QES_Español-sec3.csv'
  ]

  pipeStub = null
  beforeEach () ->
    downloader = new Downloader(hostParams)


  it 'should authentify via cookies', () ->
    promise = downloader.login()
    promise.should.eventually.be.fulfilled
    promise.then (resp) ->
      should.exist(resp)
      should.exist(resp.statusCode)
      ckSet = downloader.getCookies()
      ckList = downloader.getCookiesList()
      should.exist ckSet
      should.exist ckList

      resp.statusCode.should.be.eq 200
      ckSet.should.to.have.length 2
      ckList.should.to.have.length 2
      ckList[0].should.be.an 'object'
      downloader.logout()

  it 'should logout successfully', () ->
    logged = downloader.login()
    logged.should.eventually.be.fulfilled
    logged.then (resp) ->
      ckList = downloader.getCookiesList()
      should.exist ckList
      ckList.should.to.have.length 2
      loggedOut = downloader.logout()
      loggedOut.should.eventually.be.fulfilled


  ###
  # @todo improve this test by mocking rp.pipe in order not to write file
  ###
  it 'should retrieve csv data', () ->
    dumpCfg = dumpParams[1]
    dumpCfg.should.to.satisfy (obj) -> obj.repd == undefined || obj.repd == 0 || obj.repd == false

    logged = downloader.login()
    logged.should.eventually.be.fulfilled
    logged.then (resp) ->
      fw = downloader.getCsv dumpCfg, 'file.csv'
      should.exist(fw)
      fw.should.be.an 'object'
    .then () ->
      downloader.logout()


  ###
  # @todo improve this test by mocking rp.pipe in order not to write file
  ###
  it 'should retrieve xlsx data', () ->
    dumpCfg = dumpParams[0]
    dumpCfg.should.to.contain.keys 'repd'
    dumpCfg.repd.should.to.satisfy (val) -> val == true || val == 1

    logged = downloader.login()
    logged.should.eventually.be.fulfilled
    logged.then (resp) ->
      fw = downloader.getXlsx dumpCfg, 'file.xlsx'
      should.exist fw
      fw.should.be.an 'object'
    .then () ->
      downloader.logout()
