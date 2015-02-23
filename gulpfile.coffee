
gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
mocha = require 'gulp-mocha'

del = require 'del'

coffee = require 'gulp-coffee'
sourcemaps = require 'gulp-sourcemaps'
program = require 'commander'


program.version '0.0.1'
.option '-f, --file <cs_file>', 'File to compile'
.option '-o, --output <path>', 'Output for the compiled js file'

program.parse process.argv

# User commander instead to get arguments from CLI for gulp
compileCoffeeFile = () ->
  gulp.src program.file
  .pipe sourcemaps.init()
  .pipe coffee({bare: true})
  .pipe sourcemaps.write('.')
  .on 'error', gutil.log
  .pipe gulp.dest(program.output || './lib')

gulp.task 'compile-cs-file', compileCoffeeFile


compileCoffee = () ->
  gulp.src './src/*.coffee'
  .pipe sourcemaps.init()
  .pipe coffee {bare: true}
  .pipe sourcemaps.write('.')
  .on('error', gutil.log)
  .pipe gulp.dest(program.output || './lib')

gulp.task 'compile-coffee', compileCoffee


compileTests = () ->
  gulp.src './test/*.coffee'
  .pipe sourcemaps.init()
  .pipe coffee {bare: true}
  .pipe sourcemaps.write(program.output || './test/js')
  .on('error', gutil.log)
  .pipe gulp.dest(program.output || './test/js')

# gulp.task 'compile-tests', ['compile-coffee'], compileTests
gulp.task 'compile-tests', compileTests

###
runTests = (done) ->
  karmaConfLoc = __dirname + '/karma.conf.js'
  karmaServer.start {configFile: karmaConfLoc, action: 'start', singleRun: true, frameworks:['mocha']},
    () -> done
###

runTests = () ->
  console.log 'Running tests!!!'
  gulp.src './test/*-spec.coffee'
  .pipe mocha({reporter: 'nyan', compilers: 'coffee:coffee-script/register'})
gulp.task 'run-tests', runTests
# gulp.task 'run-tests', ['compile-tests'], runTests


runOneTest = () ->
  gulp.src program.file
  .pipe mocha({reporter: 'nyan', colors: ''})

gulp.task 'run-test-in', runOneTest


gulp.task 'list', () ->
  console.log(Object.keys(gulp.tasks).join('\n'));


gulp.task 'clean-jstest', (cb) ->
  del(['test/js/*.js*'], cb)

gulp.task 'clean-files', (cb) ->
  del(['*.csv', '*.xls*'], cb)

###
gulp.task 'clean-lib', (cb) ->
  del(['lib/* * / *.js*'], cb)

gulp.task 'clean', ['clean-lib', 'clean-jstest']

###