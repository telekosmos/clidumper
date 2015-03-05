
chai = require 'chai'
should = chai.should()
cfg = require '/Users/telekosmos/DevOps/epiquest/cli-dumper/config/init'
CLIParser = require "#{cfg.paths.root}/#{cfg.paths.jsLib}/cliparser"

describe 'CLI parser module', () ->
  cliParser = undefined
  beforeEach () ->
    # CLIParser = require '../../src/cliparser'
    cliParser = new CLIParser()
    process.argv.length = 0


  it 'should exists the cli parser object', () ->
    should.exist(cliParser)
    should.exist(cliParser.parse);
    true.should.equal(true)
    true.should.be.a('boolean');

  it 'should retrieve the -b arg', () ->
    should.exist(cliParser);
    process.argv = ['node', 'cli', '-b', 'dumpfile1.cfg'];
    file = cliParser.parse();
    should.exist(file);
    file.should.not.be.empty;

  it 'should retrieve the --batch arg', () ->
    # console.log("args: " + process.argv.length);
    should.exist(cliParser);
    process.argv = ['node', 'cli', '--batch', 'resources/dumpfile2.cfg'];
    file = cliParser.parse();
    should.exist(file);
    file.should.not.be.empty;

  it 'should return nothing if no args', () ->
    # console.log("args: " + process.argv.length);
    process.argv = ['node', 'cli'];
    should.exist(cliParser);
    file = cliParser.parse();
    should.not.exist(file);
    # cliParser.file.should.be.empty;
