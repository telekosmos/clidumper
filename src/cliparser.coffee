

parser = () ->
  parserObj = {}
  program = require 'commander'

  parse = () ->
    program.version '0.0.1'
    .usage '-b, --batch <config_file>'
    .option '-b, --batch <config_file', 'Performs a batch data retrieval based on config file'

    program.parse(process.argv);
    program.batch if program.rawArgs.length > 3 && program.batch

  parserObj =
    parse: parse

module.exports = parser