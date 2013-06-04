root.BaseView = class BaseView
  constructor: (options = {}) ->
    @uiInitialised = false
    @settings = root._.extend {
      title: ''
      backgroundColor: root.app.settings.viewBackgroundColor
      backgroundGradient: root.app.settings.viewBackgroundGradient
      backgroundImage: root.app.settings.viewBackgroundImage
      barColor: root.app.settings.viewTitleBarColor
      useTitleBarStyle: true
      viewTitleBarStyle: root.app.settings.viewTitleBarStyle
      style: root.app.settings.style
      useImageButtons: root.app.settings.useImageButtons
      orientationModes: root.app.settings.defaultOrientationModes
      disposeOnClose: false
    }, options
    
    @builtInStyles = ['blueCloth', 'cyanCloth', 'greenCloth', 'greyCloth', 'orangeCloth', 'pinkCloth', 'purpleCloth', 'redCloth']
    
    @isPortrait = (Ti.UI.orientation == Ti.UI.PORTRAIT || Ti.UI.orientation == Ti.UI.UPSIDE_PORTRAIT)
    @isLandscape = (Ti.UI.orientation == Ti.UI.LANDSCAPE_LEFT || Ti.UI.orientation == Ti.UI.LANDSCAPE_RIGHT)
    
    @applyStyle()

    @controls = []

    @window = Ti.UI.createWindow(@settings)
    @window.addEventListener('focus', @focus)
    @window.addEventListener('close', @onClose)
    @window.addEventListener('blur', @onBlur)
    
    @buildLayout()
    @assignDefaultButtons()
  
  onInit: ->
    Ti.App.addEventListener("forceLandscapeWindow", (e) => @window.orientationModes = [Ti.UI.LANDSCAPE_LEFT, Ti.UI.LANDSCAPE_RIGHT])
    Ti.Gesture.addEventListener("orientationchange", (e) =>
      if Ti.UI.orientation == Ti.UI.PORTRAIT || Ti.UI.orientation == Ti.UI.UPSIDE_PORTRAIT
        @isPortrait = true
        @isLandscape = false
        @onPortrait()
      else
        @isLandscape = true
        @isPortrait = false
        @onLandscape()
    )
    
    if @isPortrait
      @onPortrait()
    if @isLandscape
      @onLandscape()
  
  #######################################################################
  ## UI #################################################################
  
  buildLayout: =>
    if Ti.Platform.osname == "android" && !@settings.isHome
      @header = root.app.create('HeaderControl', {
        backgroundColor: @settings.barColor
        height: '50dp'
      })
      @window.add(@header.view)
      @content = Ti.UI.createView {
        top: '50dp'
        height: Ti.UI.FILL
        width: "100%"
      }
      @window.add(@content)
    else
      @content = Ti.UI.createView({
        height: Ti.UI.FILL
        width: "100%"
      })
      @window.add(@content)
  
  assignDefaultButtons: =>
    if Ti.Platform.osname != "android"
      if @settings.useImageButtons && @settings.hasBackButton
        button = root.app.create 'ImageButton', {
          type: 'back'
          text: 'Back'
          onClick: => @close()
        }
        @window.setLeftNavButton button.view
      else if @settings.useImageButtons && @settings.hasDoneButton
        button = root.app.create 'ImageButton', {
          text: 'Done'
          onClick: => @close()
        }
        @window.setRightNavButton(button.view)
      
  applyStyle: =>
    if @settings.style in @builtInStyles
      if @settings.viewTitleBarStyle?
        if Ti.Platform.osname == 'ipad'
          @settings.barImage = "/Common/Framework/Images/iOS/TitleBar/iPad/#{@settings.viewTitleBarStyle}.png"
        else
          @settings.barImage = "/Common/Framework/Images/iOS/TitleBar/#{@settings.viewTitleBarStyle}.png"
        
      if @settings.style?
        if @settings.style == 'brushedMetal'
          if Ti.Platform.osname == 'ipad'
            @settings.backgroundImage = '/Common/Framework/Images/Patterns/brushedMetal-ipad.jpg'
          else
            @settings.backgroundImage = '/Common/Framework/Images/Patterns/brushedMetal.png'
         #@settings.backgroundRepeat = true #NOTE: GJ: waiting for titanium retina bug to be fixed
    else
      @applyTitleBarStyle()
      @applyBackgroundStyle()
      
  applyTitleBarStyle: =>
    if Ti.Platform.osname in ['iphone', 'ipad']
      barImage = null
      if Ti.Platform.osname is 'iphone'
        if @isPortrait
          barImage = "/Images/style/#{@settings.style}/titlebar/titlebar.png"
        else
          if @isIPhone5()
            barImage = "/Images/style/#{@settings.style}/titlebar/titlebar-landscape-568h.png"
          else
            barImage = "/Images/style/#{@settings.style}/titlebar/titlebar-landscape.png"
      else if Ti.Platform.osname is 'ipad'
        if @isPortrait
          barImage = "/Images/style/#{@settings.style}/titlebar/titlebar-ipad.png"
        else
          barImage = "/Images/style/#{@settings.style}/titlebar/titlebar-ipad-landscape.png"
      
      if barImage? then @settings.barImage = barImage
      
    else if Ti.Platform.osname is 'android'
      Ti.API.info 'BaseView.applyTitleBarStyle is Android, do nothing'
  
  applyBackgroundStyle: =>
    if Ti.Platform.osname in ['iphone', 'ipad']
      backgroundImage = null
      if Ti.Platform.osname is 'iphone'
        if @isPortrait
          if @isIPhone5()
            backgroundImage = "/Images/style/#{@settings.style}/background/background-568h.png"
          else
            backgroundImage = "/Images/style/#{@settings.style}/background/background.png"
        else
          if @isIPhone5()
            backgroundImage = "/Images/style/#{@settings.style}/background/background-landscape-568h.png"
          else
            backgroundImage = "/Images/style/#{@settings.style}/background/background-landscape.png"
      else if Ti.Platform.osname is 'ipad'
        if @isPortrait
          backgroundImage = "/Images/style/#{@settings.style}/background/background-ipad.png"
        else
          backgroundImage = "/Images/style/#{@settings.style}/background/background-ipad-landscape.png"
      
      if backgroundImage? then @settings.backgroundImage = backgroundImage
      
    else if Ti.Platform.osname is 'android'
      Ti.API.info 'BaseView.applyTitleBarStyle is Android, do nothing'
    

  #######################################################################
  ## METHODS ############################################################

  show: (options = {}) =>
    if @settings.navigationGroup?
      @settings.navigationGroup.open(@window, options)
    else if @settings.navGroup?
      @settings.navGroup.navGroup.open(@window, options)
    else if root.tabGroup?
      @window.inTabGroup = true
      root.tabGroup.tabs.activeTab.open(@window, options)
    else if root.navGroup?
      @window.inNavGroup = true
      root.navGroup.navGroup.open(@window, options)
    else
      @open options
    @isOpen = true
  
  focus: (e) =>
    @onInit() if !@uiInitialised
    @onFocus()
    @uiInitialised = true
  
  open: (options = {}) =>
    options = root._.extend({}, options)
    @window.open(options)

  close: (options = { animated : true }) =>
    if @settings.navigationGroup?
      @settings.navigationGroup.close(@window, options)
    else if @window.navGroup?
      @window.navGroup.navGroup.close(@window, options)
    else if @window.inTabGroup
      root.tabGroup.tabs.activeTab.close(@window, options)
    else if @window.inNavGroup
      root.navGroup.navGroup.close(@window, options)
    else
      @window.close(options)
    @isOpen = false
      
  dispose: =>    
    @clear()
    @content = null
    @window = null
      
  add: (control) ->
    @content.add control
    @controls.push control
    
  remove: (control) ->
    @content.remove control
    @controls = root._.without(@controls, control)
  
  clear: ->
    for control in @controls
      @content.remove control
    @controls = []
    
  click: (callback) ->  #TODO: Is this used anywhere
    @window.addEventListener("click", callback)
  
  addHeader: (header) ->  #TODO: Is this used anywhere
    @window.add(header)
    @content.top = header.height
  
  isIPhone5: ->
    if Ti.Platform.displayCaps.platformHeight is 568 then true else false
  
  #######################################################################
  ## EVENTS #############################################################
  
  onFocus: ->
    Ti.API.info 'BaseView.onFocus'

  onBlur: ->
    Ti.API.info 'BaseView.onBlur'
  
  onClose: =>
    @dispose() if @settings.disposeOnClose
  
  onPortrait: ->
    Ti.API.info 'BaseView.onPortrait'
    
  onLandscape: ->
    Ti.API.info 'BaseView.onPortrait'