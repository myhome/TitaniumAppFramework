root.Refine.RefineView_iOS = class RefineView_iOS extends root.Refine.RefineView
  constructor: (options = {}) ->
    super root._.extend {
      backButtonTitle: 'Results'
    }, options
    
    if @settings.getTitleLabel?
      titleLabel = @settings.getTitleLabel(@settings.title)
      @window.setTitleControl titleLabel
      
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createCancelButton: =>
    cancelButton = root.app.create("ImageButton", {
      text: "Cancel"
      onClick: @cancelRefine
    })
    @window.leftNavButton = cancelButton.view
  
  createResetButton: =>
    resetButton = root.app.create("ImageButton", {
      text: "Reset"
      onClick: @reset
    })
    @window.RightNavButton = resetButton.view
  
  createTable: ->
    table = super
    table.updateLayout {
      backgroundColor: 'transparent'
      style: Ti.UI.iPhone.TableViewStyle.GROUPED
    }
    table
  
  createPropertyRow: (property) ->
    row = super(property)
    row.setHeight 44
    row
  
  ############################################################
  ### METHODS ################################################
  ############################################################
  
  updatePropertyRowStatus: (propertyRow, enabled) =>
    enabled = super(propertyRow, enabled)
    if enabled
      propertyRow.selectionStyle = Ti.UI.iPhone.TableViewCellSelectionStyle.BLUE
    else
      propertyRow.selectionStyle = Ti.UI.iPhone.TableViewCellSelectionStyle.NONE
