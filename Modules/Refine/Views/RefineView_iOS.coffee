root.Refine.RefineView_iOS = class RefineView_iOS extends root.Refine.RefineView
  constructor: (options = {}) ->
    super root._.extend {
      backButtonTitle: 'Results'
    }, options
    
    if @settings.getTitleLabel?
      titleLabel = @settings.getTitleLabel(@settings.title)
      @window.setTitleControl titleLabel
    
    @window.hideTabBar()
    
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createCancelButton: =>
    cancelButton = root.app.create("ImageButton", {
      text: "Cancel"
      onClick: @cancelRefine
    })
    @window.leftNavButton = cancelButton.view
  
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
  
  createHeaderView: =>
    container = Ti.UI.createView { height: 64, width: Ti.UI.FILL }
    container.add @createResetButton()
    container.add @createRefineButton()
    container
  
  createResetButton: =>
    root.app.create('Button', {
      text: "Reset"
      fontSize: 15
      width: 145, height: 44
      left: 10, top: 10
      style:{
        gradient: ["#dfdfdf", "#a1a1a1"]
        borderColor: '#aaaaaa'
        labelShadowColor: "#000"
      }
      onClickStyle: {
        gradient: ["#dfdfdf", "#a1a1a1"]
        borderColor: '#888888'
        labelShadowColor: "#000"
      }
      onClick: @reset
    }).view
    
  createRefineButton: ->
    root.app.create('Button', {
      text: "Refine"
      fontSize: 15
      width: 145, height: 44
      right: 10, top: 10
      style:{
        gradient: ["#444", "#222"]
        borderColor: '#111'
        labelShadowColor: "#000"
      }
      onClickStyle: {
        gradient: ["#444", "#222"]
        borderColor: '#111'
        labelShadowColor: "#000"
      }
      onClick: @refine
    }).view
  
  ############################################################
  ### METHODS ################################################
  ############################################################
  
  updatePropertyRowStatus: (propertyRow, dependencyMissing) =>
    super(propertyRow, dependencyMissing)
    if dependencyMissing
      propertyRow.setSelectionStyle Ti.UI.iPhone.TableViewCellSelectionStyle.NONE
    else
      propertyRow.setSelectionStyle Ti.UI.iPhone.TableViewCellSelectionStyle.BLUE
