Cfg = require "/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init"

Sequelize = require 'sequelize'
Promise = require 'bluebird'

# FileParser = require '../lib/fileparser'

# filename = "#{cfg.paths.root}/resources/test.json"

###
# Class to retrieve database id params from names for projects, groups and questionnaires
# @class
# @param {Object} an object with the params
###
DBRetriever = (dbCfgObj) ->
  expose = {}
  sequelize = null
  PRJ = 0; GRP = 1; INTRV = 2
  dbCfg = dbCfgObj

  grpIdSql = "select idgroup from appgroup where upper(name) = upper(:name)"
  prjIdSql = "select idprj from project where upper(name) = upper(:name)"
  intrvIdSql = "select idinterview
    from interview i, project p
    where upper(i.name) = upper(:name)
      and p.name = :prjname
      and i.codprj = p.idprj;"

  ###
  # Method to make the query in order to get the data.
  # @param {Integer} what to retrieve, either project, group or questionnaire
  # @param {String} the name of the item to retrieve
  # @return {Array} an array of results
  # @promise
  ###
  query = (what) ->
    name = arguments[1]
    projName = arguments[2]

    switch what
      when PRJ
        qry = prjIdSql
        replacements = {name: name}
      when GRP
        qry = grpIdSql
        replacements = {name: name}
      when INTRV
        qry = intrvIdSql
        replacements = {name: name, prjname: projName}
        console.log "intrv: #{name}; prj: #{projName}"
      else
        qry = prjIdSql
        replacements = {name: name}

    sequelize.query qry, {replacements: replacements, type: Sequelize.QueryTypes.SELECT}


  expose.connect = () ->
    options =
      host: dbCfg.host or 'localhost'
      port: dbCfg.port or 5432
      dialect: 'postgres'

    sequelize = new Sequelize dbCfg.name, dbCfg.user, dbCfg.pwd, options
    null

  expose.sequelize = () -> sequelize

  expose.isConnected = () -> # sequelize?.authenticate() # Promise is returned!!!
    if sequelize
      sequelize.authenticate()
    else
      new Promise (resolve) ->
        resolve(false)

  expose.getAll = (prjName, grpName, intrvName) ->

    Promise.join this.getPrjId(prjName), this.getGrpId(grpName), this.getIntrvId(intrvName, prjName), (prjId, grpId, intrvId) ->
      vals =
        prjIds: prjId # returns [{idprj: prjId}]
        grpIds: grpId # returns [{idgrp: grpId},...,{idgrp: grpId}]
        intrvIds: intrvId # returns [{idintrv: intrvId},...,{idintrv: intrvId}]

    # Promise.all [this.getPrjId(prjName), this.getGrpId(grpName), this.getIntrvId(intrvName)]
    
  ###
  # Gets a project database id from the name
  # @param {String} the project name
  # @return {Integer} the project id
  # @promise
  ###
  expose.getPrjId = (name) -> query PRJ, name
  expose.getGrpId = (name) -> query GRP, name
  expose.getIntrvId = (name, prj) -> query INTRV, name, prj

  expose

module.exports = DBRetriever