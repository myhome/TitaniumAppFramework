root.SearchTable_Framework_Android = class SearchTable_Framework_Android extends root.SearchTable_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
    
    @showingPullView = false
    
  ## UI ##################################################################
  ########################################################################
  
  createNoResultsView: ->
    view = super
    view.applyProperties {
      left: '20dp', top: '20dp', right: '20dp', bottom: '20dp'
    }
    view
  createNoResultsViewImage: ->
    imageView = super
    imageView.applyProperties {
      width: '100dp', height: '100dp'
    }
    imageView
    
  createTable: (options) =>
    table = Ti.UI.createTableView options
    table.addEventListener('scroll', @onScroll)
    table.addEventListener('dragend', @onDragend)
      
    if options.infiniteScroll
      @lastDistance = 0
      table.setFooterView @createFooterView()
    
    table
  
  createFooterView: ->
    view = super
    view.applyProperties {
      backgroundColor: '#f2f2f2'
      width: Ti.UI.FILL, height: '50dp'
    }
    view
  createFooterViewLoader: ->
    activityIndicator = super
    activityIndicator.applyProperties {
      width: '40dp', height: '40dp'
      style: Ti.UI.ActivityIndicatorStyle.DARK
    }
    activityIndicator
  
  ## METHODS #############################################################
  ########################################################################
  
  ## EVENTS ##############################################################
  ########################################################################
  
  onScroll: (e) =>
    if e.totalItemCount > e.visibleItemCount && e.firstVisibleItem + e.visibleItemCount == e.totalItemCount && @hasMoreRows
      @settings.infiniteScrollCallback()
      @footerView.show()
  
