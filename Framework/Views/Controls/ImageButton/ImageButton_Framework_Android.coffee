root.ImageButton_Framework_Android = class ImageButton_Framework_Android extends root.ImageButton_Framework
  constructor:(options = {}) ->
    options = root._.extend {}, options
    super options
    
  createBackButton: (settings) =>

  createButton: (settings) =>
    @bg = "/Common/Framework/Images/Android/button-nine-patch.png"
    @bgPressed = "/Common/Framework/Images/Android/button-pressed-nine-patch.png"
    
    @button = Ti.UI.createView {
      height: Ti.UI.FILL
      width: Ti.UI.SIZE
      top: settings.top
      right: settings.right
      bottom: settings.bottom
      left: settings.left
    }
    
    @imageView = Ti.UI.createImageView {
      top: 0, right: 0, bottom: 0, left: 0
      image: @bg
      backgroundColor: '#000'
      opacity: 0
    }
    @button.add @imageView
    
    if settings.iconSettings?
      @icon = Ti.UI.createImageView(settings.iconSettings)
      @icon.setLeft '7dp'
      @icon.setRight '7dp'
      @icon.touchEnabled = false
      @icon.zIndex = 1000
      @button.add @icon
    
    if settings.text?
      @label = Ti.UI.createLabel {
        left: '7dp', right: '7dp'
        text: settings.text
        textAlign: "center"
        color: "#FFF"
        font: { fontSize: '14dp', fontWeight: "bold" }
        width: Ti.UI.SIZE
        zIndex: 1100
      }
      @button.add(@label)
    
    @setEnabled(settings.enabled)
    
    @button
    
  setTitle: (title) =>
    @label.setText title
    
  togglePressed: =>
    if @button.isPressed
      @button.isPressed = false
      @imageView.opacity = 0
    else
      @button.isPressed = true
      @imageView.opacity = 0.3
      
  onTouchStart: =>
    @imageView.opacity = 0.3
    
  onTouchEnd: =>
    @options.onClick()
    @imageView.opacity = 0 if !@button.isPressed
    
  onTouchCancel: =>
    @button.opacity = 0 if !@button.isPressed
     
  setEnabled: (enabled) =>
    if @enabled != enabled
      if enabled
        @button.addEventListener "touchstart", @onTouchStart
        @button.addEventListener "click", @onTouchEnd
        @button.addEventListener "touchcancel", @onTouchCancel
        if @label?
          @label.setOpacity(1)
        if @icon?
          @icon.setOpacity(1)
        @enabled = enabled
      else
        @button.removeEventListener "touchstart", @onTouchStart
        @button.removeEventListener "click", @onTouchEnd
        @button.addEventListener "touchcancel", @onTouchCancel
        if @label?
          @label.setOpacity(0.4)
        if @icon?
          @icon.setOpacity(0.4)
        @enabled = enabled
