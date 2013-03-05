root.Refine.RefineSelectView_iOS = class RefineSelectView_iOS extends root.Refine.RefineSelectView
  constructor: (options = {}) ->
    super root._.extend {}, options
    
    if @settings.getTitleLabel?
      @titleLabel = @settings.getTitleLabel(@settings.title)
      @window.setTitleControl @titleLabel
      
    @window.hideTabBar()
  
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createCancelButton: =>
    if !@cancelButton?
      @cancelButton = root.app.create("ImageButton", {
        left: 5
        text: "Cancel"
        onClick: => @close()
      })
    @window.leftNavButton = @cancelButton.view
  
  createDoneButton: =>
    if !@doneButton?
      @doneButton = root.app.create("ImageButton", {
        right: 5
        text: "Done"
        onClick: => @close()
      })
    @window.rightNavButton = @doneButton.view
  
  ############################################################
  ### METHODS ################################################
  ############################################################
  
  updateTitle: (title) =>
    if @titleLabel?
      @titleLabel.setText if title? then title else 'Select'
    else
      @window.setTitle if title? then title else 'Select'
    
  showHideCancelButton: (show) =>
    if show
      @cancelButton.view.show()
    else
      @cancelButton.view.hide()
  
  showHideDoneButton: (show) =>
    if show
      @doneButton.view.show()
    else
      @doneButton.view.hide()
