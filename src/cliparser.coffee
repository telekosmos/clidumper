
###
# Command line parser for the dumper
###
parser = () ->
  parserObj = {}
  program = require 'commander'

  ###
  # Just makes a parser getting name of the batch file used to configure
  # the dumper or undefined if no param was provided
  ###
  parse = () ->
    program.version '0.0.1'
    .usage '-b, --batch <config_file>'
    .option '-b, --batch <config_file', 'Performs a batch data retrieval based on config file'

    program.parse(process.argv);
    program.help() if !program.batch?
    program.batch if program.rawArgs.length > 3 && program.batch

  parserObj =
    parse: parse

module.exports = parser