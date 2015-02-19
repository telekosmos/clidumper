

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
Cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'
Downloader = require "#{Cfg.paths.root}/lib/downloader"

should = chai.should()
chai.use(chaiAsPromised)


describe 'Downloader data using paramas from config file', () ->
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


  it 'should retrieve csv data', () ->
    dumpCfg = dumpParams[1]
    dumpCfg.should.to.satisfy (obj) -> obj.repd == undefined || obj.repd == 0 || obj.repd == false

    promise = downloader.getCsv dumpCfg, 'file.csv'
    promise.should.eventually.be.fulfilled
    promise.should.eventually.not.equal ""
    promise.should.eventually.contain 'file.csv'



  it 'should retrieve xlsx data', () ->
    dumpCfg = dumpParams[0]
    dumpCfg.should.to.contain.keys 'repd'
    dumpCfg.repd.should.to.satisfy (val) -> val == true || val == 1

    promise = downloader.getXlsx dumpCfg, 'file.xlsx'
    promise.should.eventually.be.fulfilled
    promise.should.eventually.not.equal ""
    promise.should.eventually.contain 'file.xlsx'
    promise.should.eventually.contain 'repd'
