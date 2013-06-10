fs = require 'fs'
path = require 'path'
async = require 'async'
_ = require 'underscore'

exports.mkdirs = (mkpath, cb) ->
  mkpath = path.relative process.cwd(), mkpath
  paths = mkpath.split(path.sep)
  currentPath = ''
  async.eachSeries paths,
    (pathPart, cb) ->
      fs.mkdir path.join(currentPath, pathPart), (err) ->
        return cb(err) if err and err.code != 'EEXIST'
        currentPath = path.join(currentPath, pathPart)
        cb null
  , (err) ->
    cb err

exports.findFiles = (dir, fnMatch, cb) ->
  results = {}
  fs.readdir dir, (err, files) ->
    return cb(err) if err

    remaining = files.length;
    if (remaining == 0)
      cb null, results
    else
      for file in files
        do ->
          curPath = path.join dir, file
          fs.stat curPath, (err, stat) ->
            if stat
              if stat.isDirectory()
                exports.findFiles curPath, fnMatch, (err, subdirResults) ->
                  results = _.extend results, subdirResults
                  cb(null, results) if --remaining == 0
              else
                if not fnMatch or fnMatch(curPath)
                  results[curPath] = stat
                cb(null, results) if --remaining == 0

exports.stringEndsWidth = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) > -1

exports.funcAsAsync = (func) ->
  (params...) ->
    cb = _.last(params)
    result = func.apply(this, params[0...-1])
    try
      cb null, result
    catch err
      cb new Error("#{func.name} failed: #{err}")
