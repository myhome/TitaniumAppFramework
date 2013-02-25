root.TwoLineTitle_Framework_Android = class TwoLineTitle_Framework_Android extends root.TwoLineTitle_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
  
  ## UI ##################################################################
  ########################################################################
  
  createView: ->
    view = super
    view.setWidth '70%'
    view
    
  createTitle: =>
    label = super()
    label.applyProperties {
      top: '5dp'
      height: '20dp'
      font: { fontSize: '15dp' }
      ellipsize: true
    }
    label
    
  createSubTitle: =>
    label = super()
    label.applyProperties {
      top: '25dp'
      height: '20dp'
      font: { fontSize: '13dp' }
      ellipsize: true
    }
    label
  
  createBigTitle: =>
    label = super()
    label.applyProperties {
      top: 'auto'
      font: { fontSize: '17dp' }
      ellipsize: true
    }
    label