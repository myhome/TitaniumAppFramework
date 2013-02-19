root.Refine.RefineView_Android = class RefineView_Android extends root.Refine.RefineView
  constructor: (options = {}) ->
    super root._.extend {
      navBarHidden: true
      rowSelectedBackgroundColor: '#ccc'
    }, options
    
  onInit: =>
    super
    
    @twoLineTitle = root.app.create('TwoLineTitle', { title: @settings.title })
    @header.centerView.add @twoLineTitle.view
  
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createCancelButton: =>
    cancelButton = root.app.create("ImageButton", {
      top: '4dp', left: '4dp', bottom: '4dp'
      text: "Cancel"
      onClick: @cancelRefine
    })
    @header.leftView.add cancelButton.view
  
  createTable: ->
    table = super()
    table.setSeparatorColor '#ddd'
    table
  
  createPropertyRow: (property) =>
    row = super(property)
    row.setHeight '50dp'
    row
  
  createPropertyTitle: (title) ->
    label = super(title)
    label.setLeft '10dp'
    label.setFont { fontSize: '15dp', fontWeight: 'bold' }
    label
  
  createPropertyDisplay: (display) ->
    label = super(display)
    label.setRight '10dp'
    label.setFont { fontSize: '15dp' }
    label.setWidth '150dp'
    label

  createHeaderView: =>
    container = Ti.UI.createView { height: '64dp', width: Ti.UI.FILL }
    container.add @createResetButton()
    container.add @createRefineButton()
    container
  
  createResetButton: =>
    root.app.create('Button', {
      text: "Reset"
      fontSize: '15dp'
      width: '145dp', height: '44dp'
      left: '10dp', top: '10dp'
      style:{
        gradient: ["#dfdfdf", "#a1a1a1"]
        labelShadowColor: "#000"
      }
      onClickStyle: {
        gradient: ["#dfdfdf", "#a1a1a1"]
        labelShadowColor: "#000"
      }
      onClick: @reset
    }).view
    
  createRefineButton: ->
    root.app.create('Button', {
      text: "Refine"
      fontSize: '15dp'
      width: '145dp', height: '44dp'
      right: '10dp', top: '10dp'
      style:{
        gradient: ["#0082cc", "#0045cc"]
        labelShadowColor: "#000"
      }
      onClickStyle: {
        gradient: ["#0082cc", "#0045cc"]
        labelShadowColor: "#000"
      }
      onClick: @refine
    }).view