root.TwoLineTitle_Framework_iOS = class TwoLineTitle_Framework_iOS extends root.TwoLineTitle_Framework
  constructor: (options = {}) ->
    options = root._.extend {}, options
    super options

  createTitle: =>
    title = super
    title.updateLayout { 
      shadowColor: '#222'
      shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
    }
    title.setMinimumFontSize 13
    
    title
    
  createSubTitle: =>
    subTitle = super
    subTitle.updateLayout { 
      shadowColor: '#222'
      shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
    }
    
    subTitle
  
  createBigTitle: =>
    bigTitle = super
    bigTitle.updateLayout { 
      shadowColor: '#222'
      shadowOffset: { x: 0, y: -1 }
      width: Ti.UI.FILL
    }
    bigTitle.setMinimumFontSize 15
    
    bigTitle