root.Refine.RefineView_iPhone = class RefineView_iPhone extends root.Refine.RefineView_iOS
  constructor: (options = {}) ->
    super root._.extend {}, options
      
  ############################################################
  ### UI #####################################################
  ############################################################
  
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
    }
    label
