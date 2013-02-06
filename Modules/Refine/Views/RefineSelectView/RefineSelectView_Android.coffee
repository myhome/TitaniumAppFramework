root.Refine.RefineSelectView_Android = class RefineSelectView_Android extends root.Refine.RefineSelectView
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
    @cancelButton = root.app.create("ImageButton", {
      top: '4dp', left: '4dp', bottom: '4dp'
      text: "Cancel"
      onClick: @close
    })
    @header.leftView.add @cancelButton.view
  
  createDoneButton: =>
    @doneButton = root.app.create("ImageButton", {
      top: '4dp', right: '4dp', bottom: '4dp'
      text: "Done"
      onClick: @close
    })
    @header.rightView.add @doneButton.view
  
  createTable: ->
    table = super()
    table.setSeparatorColor '#ddd'
    table
  
  createTableRow: (label) =>
    Ti.UI.createTableViewRow {
      height: '50dp'
      title: label
      font: { fontSize: '15dp', fontWeight: 'bold' }
      color: '#000'
      backgroundColor: '#fff'
      backgroundSelectedColor: if @settings.rowSelectedBackgroundColor? then @settings.rowSelectedBackgroundColor else '#ccc'
    }

  ############################################################
  ### METHODS ################################################
  ############################################################
  
  updateTitle: (title) =>
    # @twoLineTitle.update if title? then title else 'Select'