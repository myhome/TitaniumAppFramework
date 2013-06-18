root.BaseView = class BaseView
  constructor: (options = {}) ->
    @uiInitialised = false
    @settings = root._.extend {
      title: ''
      barColor: root.app.settings.viewTitleBarColor
      backgroundColor: root.app.settings.viewBackgroundColor
      backgroundGradient: root.app.settings.viewBackgroundGradient
      backgroundImage: root.app.settings.viewBackgroundImage
      style: root.app.settings.style # Style will override barColor, backgroundColor, backgroundGradient and backgroundImage if present
      useImageButtons: root.app.settings.useImageButtons
      orientationModes: root.app.settings.defaultOrientationModes
      disposeOnClose: false
    }, options
    
    @controls = []
    @hasNewStyle = false
    
    @isPortrait = (Ti.UI.orientation == Ti.UI.PORTRAIT || Ti.UI.orientation == Ti.UI.UPSIDE_PORTRAIT)
    @isLandscape = (Ti.UI.orientation == Ti.UI.LANDSCAPE_LEFT || Ti.UI.orientation == Ti.UI.LANDSCAPE_RIGHT)
    
    @applyStyle() if @settings.style?

    @createWindow()
    
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
  
  
  ## UI #################################################################
  #######################################################################
  
  createWindow: =>
    @window = Ti.UI.createWindow(@settings)
    @window.addEventListener('focus', @focus)
    @window.addEventListener('close', @onClose)
    @window.addEventListener('blur', @onBlur)
    
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
          onClick: @close
        }
        @window.setLeftNavButton button.view
      else if @settings.useImageButtons && @settings.hasDoneButton
        button = root.app.create 'ImageButton', {
          text: 'Done'
          onClick: @close
        }
        @window.setRightNavButton(button.view)
      
  applyStyle: =>
    
    # Override predefined styles with style parameters
    @settings.barColor = @settings.style.barColor if @settings.style.barColor?
    @settings.backgroundColor = @settings.style.backgroundColor if @settings.style.backgroundColor?
    
    # If platform iOS(iPhone/iPad) then set barImage to appropriate image file
    if Ti.Platform.osname in ['iphone', 'ipad']
      barImage = null
      if Ti.Platform.osname is 'iphone'
        if @isPortrait
          barImage = "/Images/style/#{@settings.style.name}/titlebar/titlebar.png"
        else
          if @isIPhone5()
            barImage = "/Images/style/#{@settings.style.name}/titlebar/titlebar-landscape-568h.png"
          else
            barImage = "/Images/style/#{@settings.style.name}/titlebar/titlebar-landscape.png"
      else if Ti.Platform.osname is 'ipad'
        if @isPortrait
          barImage = "/Images/style/#{@settings.style.name}/titlebar/titlebar-ipad.png"
        else
          barImage = "/Images/style/#{@settings.style.name}/titlebar/titlebar-ipad-landscape.png"
      @settings.barImage = barImage
    
    # If platform iOS(iPhone/iPad) then set backgroundImage to appropriate image file
    if Ti.Platform.osname in ['iphone', 'ipad']
      backgroundImage = null
      if Ti.Platform.osname is 'iphone'
        if @isPortrait
          if @isIPhone5()
            backgroundImage = "/Images/style/#{@settings.style.name}/background/background-568h.png"
          else
            backgroundImage = "/Images/style/#{@settings.style.name}/background/background.png"
        else
          if @isIPhone5()
            backgroundImage = "/Images/style/#{@settings.style.name}/background/background-landscape-568h.png"
          else
            backgroundImage = "/Images/style/#{@settings.style.name}/background/background-landscape.png"
      else if Ti.Platform.osname is 'ipad'
        if @isPortrait
          backgroundImage = "/Images/style/#{@settings.style.name}/background/background-ipad.png"
        else
          backgroundImage = "/Images/style/#{@settings.style.name}/background/background-ipad-landscape.png"
      
      @settings.backgroundImage = backgroundImage
      
  updateStyle: (styleRequest) =>
    if root.app.settings.dynamicStyle?
      style = root.app.settings.dynamicStyle(styleRequest)
      if style?
        @settings.style = style
        @applyStyle()
        @refreshStyle()
  
  refreshStyle: =>
    if Ti.Platform.osname in ['iphone', 'ipad']
      @window.barImage = @settings.barImage
      @window.backgroundColor = @settings.backgroundColor
      @window.backgroundImage = @settings.backgroundImage
    else if Ti.Platform.osname in ['android']
      @hasNewStyle = true
      
  
  ## METHODS ############################################################
  #######################################################################

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
  
  
  ## EVENTS #############################################################
  #######################################################################
  
  onFocus: =>
    Ti.API.info 'BaseView.onFocus'
    # Applying any new style for android here because it was causing android to crash.
    if @hasNewStyle and Ti.Platform.osname in ['android']
      @window.setBackgroundColor @settings.backgroundColor
      @header.setBarColor @settings.barColor
      @hasNewStyle = false

  onBlur: ->
    Ti.API.info 'BaseView.onBlur'
  
  onClose: =>
    @dispose() if @settings.disposeOnClose
  
  onPortrait: =>
    # Ti.API.info 'BaseView.onPortrait'
    
  onLandscape: =>
    # Ti.API.info 'BaseView.onLandscape'