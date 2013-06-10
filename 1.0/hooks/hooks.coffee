fs = require 'fs'
path = require 'path'
async = require 'async'
_ = require 'underscore'
spawn = require('child_process').spawn
coffeescript = require 'coffee-script'
less = require 'less'
compileFileType = require './compile-file-type'
utils = require './utils'


exports.build_pre_compile = (logger, config, cli, build, finished) ->
  logger.info "Compiling source files"

  # Setup
  resourcesOutputDir = build.projectDir + '/Resources'
  staticResourcesInputDir = build.projectDir + '/Resources-static'
  compileResourcesInputDir = build.projectDir + '/Resources-compile'

  async.parallel [
    (cb) ->
      # make sure output directory exists
      try
        fs.mkdirSync resourcesOutputDir
      catch err
        return cb(err) if not err or err.code != 'EEXIST'
      cb null
    (cb) -> copyStaticFiles(staticResourcesInputDir, resourcesOutputDir, cb)
    (cb) -> compileFiles(logger, compileResourcesInputDir, resourcesOutputDir, cb)
  ]
  , (err) ->
    if err
      logger.error "Error compiling files: #{err}"
      throw err

    logger.info 'Finished compiling source files'
    finished()

exports.clean_post = (logger, config, cli, build, finished) ->
  console.log cli.argv['project-dir']
  resourcesOutputDir = cli.argv['project-dir'] + '/Resources'
  logger.info "Cleaning resources output directory: #{resourcesOutputDir}"
  cleanFiles resourcesOutputDir

copyStaticFiles = (inputDir, outputDir, cb) ->
  spawn 'cp', [
    '-r'
    inputDir + '/'
    outputDir
  ]

  # TODO: check for errors?
  cb null

compileFiles = (logger, inputDir, outputDir, cb) ->
  compileFunctions = _.map [
    { inSuffix: 'coffee', outSuffix: 'js', fnCompile: utils.funcAsAsync(coffeescript.compile) }
    { inSuffix: 'less', outSuffix: 'css', fnCompile: less.render }
  ], (funcDef) ->
    (cbCompile) ->
      compileFileType logger, funcDef.fnCompile, inputDir, funcDef.inSuffix, outputDir, funcDef.outSuffix, cbCompile

  async.parallel compileFunctions, (err) ->
    cb err

# TODO: integrate this somewhere
cleanFiles = (outputDir, cb) ->
  spawn 'rm', [
    '-r'
    outputDir + path.sep
  ]
  # TODO: errors?
