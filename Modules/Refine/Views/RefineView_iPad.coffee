root.Refine.RefineView_iPad = class RefineView_iPad extends root.Refine.RefineView_iOS
  constructor: (options = {}) ->
    super root._.extend {}, options
      
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createPropertyTitle: (title) ->
    label = super(title)
    label.updateLayout {
      left: 10
      font: { fontSize: 16, fontWeight: 'bold' }
    }
    label
  
  createPropertyDisplay: (display) ->
    label = super(display)
    label.updateLayout {
      right: 10
      font: { fontSize: 16 }
      width: 300
    }
    label
