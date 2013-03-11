root.SearchTable_Framework_Android = class SearchTable_Framework_Android extends root.SearchTable_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
    
    @showingPullView = false
    
  ## UI ##################################################################
  ########################################################################
  
  createNoResultsView: ->
    view = Ti.UI.createView {
      width: '300dp', height: '300dp'
      backgroundColor: '#f8f8f8'
    }
    content = @createNoResultsContent()
    content.add @createNoResultsViewImage()
    content.add @createNoResultsViewLabel()
    view.add content
    view.hide()
    view
    
  createNoResultsViewImage: ->
    imageView = super
    imageView.applyProperties {
      width: '100dp', height: '100dp'
    }
    imageView
  createNoResultsViewLabel: ->
    label = super
    label.applyProperties {
      top: '20dp', font: { fontSize: '18dp' }
    }
    label
    
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
  
