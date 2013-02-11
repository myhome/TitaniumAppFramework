root.Refine.RefineView_iPhone = class RefineView_iPhone extends root.Refine.RefineView_iOS
  constructor: (options = {}) ->
    super root._.extend {}, options
      
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createGroupSection: ->
    Ti.UI.createTableViewSection {
      headerView: Ti.UI.createView { height: 1 }
    }
  
  createPropertyRow: (property) =>
    row = super(property)
    if property.type is 2
      row.setSelectionStyle Ti.UI.iPhone.TableViewCellSelectionStyle.NONE
    row
  
  createPropertyTitle: (title) ->
    label = super(title)
    label.updateLayout {
      left: 10
      font: { fontSize: 15, fontWeight: 'bold' }
    }
    label
  
  createPropertyDisplay: (display) ->
    label = super(display)
    label.updateLayout {
      right: 10
      font: { fontSize: 15 }
      width: 150
    }
    label
