root.TwoLineTitle_Framework_iOS = class TwoLineTitle_Framework_iOS extends root.TwoLineTitle_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
  
  ## UI ##################################################################
  ########################################################################
  
  createTitle: =>
    label = super
    label.applyProperties { 
      shadowColor: '#222', shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
      minimumFontSize: 13
    }
    label
    
  createSubTitle: =>
    label = super
    label.applyProperties { 
      shadowColor: '#222', shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
    }
    
    label
  
  createBigTitle: =>
    label = super
    label.applyProperties { 
      shadowColor: '#222', shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
      minimumFontSize: 15
    }
    label