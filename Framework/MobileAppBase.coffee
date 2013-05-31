Ti.include('/Common/Framework/Lib/analytics.js');
root.MobileAppBase = class MobileAppBase
  constructor: (options) ->
    @settings = root._.extend {
      viewBackgroundImage: null
      viewBackgroundRepeat: true
      viewBackgroundColor: null
      viewBackgroundGradient: null
      viewTitleBarColor: '#000000'
      viewTitleBarGradient: null
      viewTitleBarImage: null
      debugMode: false
      noInternetViewEnabled: false
      ignoreAndroidTablet: false
      useImageButtons: false
    }, options
    
    @configureGoogleAnalytics()
    
    if Ti.Filesystem.getFile('dev.env').exists()
      @settings.accountDomain = @settings.devAccountDomain
    
    @classFactory = new root.ClassFactory { ignoreAndroidTablet: @settings.ignoreAndroidTablet }
    @sounds = new root.SoundCache()
    @network = new root.Network()
    
    Ti.Network.addEventListener('change', (e) => @checkInternet(e.online) if !@checking)
  
  configureGoogleAnalytics: =>
    if @settings.googleAnalyticsID?
      @analytics = new Analytics(@settings.googleAnalyticsID, Ti.App.name, Ti.App.version)
      @analytics.start(10)
  
  delay: (ms, func) ->
    if ms == 0 then func() else setTimeout(func, ms)
      
  randomDelay: (randomDelay, minDelay, func) ->
    @delay (Math.random() * randomDelay) + minDelay, func
    
  debug: (msg) ->
    Ti.API.info(msg)
  
  isDebugMode: ->
    @settings.debugMode
  
  create: (className, options = {}) ->
    @classFactory.create(className, options)

  noInternetEnable: =>
    @settings.noInternetViewEnabled = true
    @checkInternet() if !@checking
    
  noInternetDisable: =>
    @settings.noInternetViewEnabled = false
    @checkInternet() if !@checking
    
  checkInternet: (isOnline) =>
    @checking = true
    
    isOnline = Ti.Network.online unless isOnline?

    if isOnline
      Ti.API.info('Welcome to the internet')
      @noInternetView.window.close() if @noInternetView
    else
      Ti.API.info('Bloody hell, the network just DISSAPEARED!')
      @noInternetView = @create("NoInternetView") unless @noInternetView
      if @settings.noInternetViewEnabled
        @noInternetView.window.open()

    @checking = false
      
  trackPageview: (pageUrl) => @analytics.trackPageview(pageUrl) if @analytics?