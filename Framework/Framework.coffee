root._ = require('Common/Framework/Lib/underscore')._
root.moment = require('Common/Framework/Lib/moment.min')
root.ent = require('Common/Framework/Lib/ent')
root.moduleNames = []

Array::first = -> root._.first @ #TODO: GJ: move to extensions.js
Array::without = (value) -> root._.without @, value
Array::shuffle = -> root._.shuffle(@) 
Array::random = -> @.shuffle().first()
Array::random_without = (value) -> @without(value).random()

root.Framework = class Framework
  constructor: (options) ->
    @settings = root._.extend({}, options)
    @classFactory = new root.ClassFactory()
    @includedFiles = []
    @unloadedModules = []
        
  includePath: (path = "", recursive = false) =>
    for file in @getFiles(path, recursive)
      Ti.API.info("Including #{file}")
      @include file

  includeModule: (moduleName) ->
    Ti.API.info("Including module ..... [#{moduleName}]")
    root.moduleNames.push moduleName
    root[moduleName] = {}
    @includePath("Common/Modules/#{moduleName}", true)
  
  includeModuleJs: (moduleName) ->
    Ti.API.info("Including module ..... [#{moduleName}]")
    root.moduleNames.push moduleName
    root[moduleName] = {}
    Ti.include("/Common/Modules/#{moduleName}/#{moduleName}.js")
    
  includeDynamicModule: (moduleName) ->
    Ti.API.info("Including Dynamic module ..... [#{moduleName}]")
    @unloadedModules.push moduleName
    
  loadDynamicModule: (moduleName) ->
    if moduleName in @unloadedModules
      Ti.API.info("Loading Dynamic Module ..... [#{moduleName}]")
      @includeModule moduleName
      @unloadedModules = _.without @unloadedModules, moduleName
    
  include: (file) =>    
    if @includedFiles.indexOf(file) == -1
      filePath = Titanium.Filesystem.resourcesDirectory + file
      Ti.API.info("Including ..... #{file}")
      Ti.include(filePath)
      @includedFiles.push file
    else
      Ti.API.info("Skipping ..... #{file}")

  getFiles: (path = "", recursive = false) ->
    dir = Titanium.Filesystem.getFile(Titanium.Filesystem.resourcesDirectory + "/" + path)
    items = dir.getDirectoryListing()
    files = []

    if items?
      for item in items
        if item.indexOf('.js') != -1
          files.push "#{path}/#{item}"
        else if item.indexOf('.coffee') != -1
          files.push "#{path}/#{item.replace('.coffee', '.js')}"
        else if item.indexOf('.dummy') != -1
          files.push "#{path}/#{item.replace('.dummy', '.js')}"

      for item in items
        if recursive and item.indexOf('.') == -1 and item.indexOf('_') != 0 #TODO:GJ: a better way of checking for dir
          additional = @getFiles("#{path}/#{item}", recursive)
          files = files.concat additional
    root._.uniq files
    
  fromJson: (json, klass) ->
    obj = new klass()
    for key, value of JSON.parse(json)
      obj[key] = value
    obj
    
  deepExtend = (object, extenders...) ->
    return {} if not object?
    for other in extenders
      for own key, val of other
        if not object[key]? or typeof val isnt "object"
          object[key] = val
        else
          object[key] = deepExtend object[key], val
    object
  
  getImageResolutionUrl: (url) ->
    if Ti.Platform.osname is "android"
      dpi = Titanium.Platform.displayCaps.dpi
      if dpi < 160 then size = 'l'
      else if dpi >= 160 and dpi < 240  then size = 'm'
      else if dpi >= 240 and dpi < 320 then size = 'h'
      else if dpi >= 320 then size = 'x'
      else size = 'm'
      urlParts = url.split('.')
      return "#{urlParts[0]}-#{size}.#{urlParts[1]}"
    else
      return url
      
  getDeviceDependentImage: (url) ->
    if Ti.Platform.osname is "android"
      dpi = Titanium.Platform.displayCaps.dpi
      if dpi < 160 then size = 'l'
      else if dpi >= 160 and dpi < 240  then size = 'm'
      else if dpi >= 240 and dpi < 320 then size = 'h'
      else if dpi >= 320 then size = 'x'
      else size = 'm'
      urlParts = url.split('.')
      parts = "#{urlParts[0]}-#{size}.#{urlParts[1]}".split('/Images')
      "#{parts[0]}/Images/Android#{parts[1]}"
    else
      parts = url.split('/Images')
      "#{parts[0]}/Images/iOS#{parts[1]}"