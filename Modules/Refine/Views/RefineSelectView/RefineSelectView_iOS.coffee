root.Refine.RefineSelectView_iOS = class RefineSelectView_iOS extends root.Refine.RefineSelectView
  constructor: (options = {}) ->
    super root._.extend {}, options
    
    if @settings.getTitleLabel?
      titleLabel = @settings.getTitleLabel(@settings.title)
      @window.setTitleControl titleLabel
  
  ############################################################
  ### UI #####################################################
  ############################################################
    
  createCancelButton: =>
    cancelButton = root.app.create("ImageButton", {
      text: "Cancel"
      onClick: => @close()
    })
    @window.leftNavButton = cancelButton.view