root.SearchTable_Framework_iPhone = class SearchTable_Framework_iPhone extends root.SearchTable_Framework_iOS
  constructor: (options = {}) ->
    super root._.extend {}, options
    
  ## UI ##################################################################
  ########################################################################
  
  createNoResultsViewLabel: ->
    label = super
    label.applyProperties {
      top: 20
      font: { fontSize: 18 }
    }
    label
  
  createPullView: ->
    view = super
    view.applyProperties {
      width: 320, height: 60
    }
    view
    
  createPullViewArrow: ->
    imageView = super
    imageView.applyProperties {
      left: 40, bottom: 10
      width: 23, height: 60
    }
    imageView
  
  createPullViewLoader: ->
    activityIndicator = super
    activityIndicator.applyProperties {
      left: 40, bottom: 25
      width: 30, height: 30
    }
    activityIndicator
    
  createPullViewLabel: ->
    label = super
    label.applyProperties {
      left: 55, bottom: 30
      font: { fontSize: 13, fontWeight: 'bold' }
      width: 200
    }
    label
  
  ## METHODS #############################################################
  ########################################################################
  
  
  ## EVENTS ##############################################################
  ########################################################################
  
  
