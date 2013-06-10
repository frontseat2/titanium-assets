fs = require 'fs'
async = require 'async'
_ = require 'underscore'
utils = require './utils'
path = require 'path'

module.exports = (logger, fnCompile, inputDir, inputSuffix, outputDir, outputSuffix, cb) ->

  # find all input files and find the corresponding output file
  # (if it already exists)
  async.parallel [
    (cbFindInput) ->
      # get input files
      utils.findFiles inputDir, (inputPath) ->
        utils.stringEndsWidth inputPath, inputSuffix
      , cbFindInput
    (cbFindOutput) ->
      # get current output files
      utils.findFiles outputDir, (outputPath) ->
        utils.stringEndsWidth outputPath, outputSuffix
      , cbFindOutput
  ]
  , (err, files) ->
    return cb(new Error("Error scanning files: #{err}")) if err
    [inputFiles, outputFiles] = files

    # Figure out which files need to be compiled
    filesToCompile =
      outOfDate: []
      newFiles: []
    filesOk = []
    _.each inputFiles, (fileStat, filepath) ->
      outputOfInputFile = outputDir + filepath.slice(inputDir.length).slice(0, -inputSuffix.length) + outputSuffix
      if not outputFiles[outputOfInputFile]
        # If there's no output file, mark it as a new output
        filesToCompile.newFiles.push
          input: filepath
          output: outputOfInputFile
      else if outputFiles[outputOfInputFile].mtime.getTime() < fileStat.mtime.getTime()
        # If the output file's modified time is older than the input, mark it as an out of date file
        filesToCompile.outOfDate.push
          input: filepath
          output: outputOfInputFile
      else
        # Or else there's no need to compile the file
        filesOk.push filepath
    logger.info "#{inputSuffix}: #{filesToCompile.outOfDate.length} files out of date, #{filesToCompile.newFiles.length} new files, #{filesOk.length} files unchanged"

    # Put together all the files that we want to compile
    allFilesToCompile = filesToCompile.outOfDate.concat filesToCompile.newFiles

    # Figure out all the output directories
    allOutputDirs =_.uniq _.map allFilesToCompile, (fileInfo) -> fileInfo.output.slice(0, _.lastIndexOf(fileInfo.output, path.sep))
    if allOutputDirs.length > 0
      async.map allOutputDirs,
        # Make sure the output directory exists
        (dir, cbMkDir) -> utils.mkdirs(dir, cbMkDir)
      , (err) ->
        return cb(err) if err and err.code != 'EEXIST'

        # Compile all the files
        if allFilesToCompile.length > 0
          async.map allFilesToCompile,
            (fileInfo, cbCompileFile) ->
              logger.trace "Compiling #{fileInfo.input}"
              async.waterfall [
                (cbRead) -> fs.readFile(fileInfo.input, 'utf8', cbRead)
                (code, cbCompile) -> fnCompile code, cbCompile
                (compiled, cbWrite) -> fs.writeFile(fileInfo.output, compiled, 'utf8', cbWrite)
              ], (err) ->
                return cbCompileFile(new Error("Error compiling '#{fileInfo.input}': #{err}")) if err
                cbCompileFile null
          , cb
    else
      cb null

