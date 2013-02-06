root.Refine.RefineView_Android = class RefineView_Android extends root.Refine.RefineView
  constructor: (options = {}) ->
    super root._.extend {
      navBarHidden: true
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
  
  createResetButton: =>
    resetButton = root.app.create("ImageButton", {
      top: '4dp', right: '4dp', bottom: '4dp'
      text: "Reset"
      onClick: @reset
    })
    @header.rightView.add resetButton.view
  
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