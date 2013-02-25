root.SearchTable_Framework = class SearchTable_Framework
  constructor: (options = {}) ->
    @settings = root._.extend {
      backgroundColor: 'transparent'
      separatorColor: 'transparent'
      pullToRefresh: false
      pullToRefreshCallback: -> Ti.API.info 'SearchTable_Framework.pullToRefreshCallback'
      infiniteScroll: false
      infiniteScrollCallback: -> Ti.API.info 'SearchTable_Framework.inifiniteScrollCallback'
    }, options
    
    @pulling = false
    @reloading = false
    @offset = 0
    @lastDistance = 200
    @hasMoreRows = false
    @rowCount = 0
    @table = @createTable(@settings)
    
    @noResultsView = @createNoResultsView()
    @table.add @noResultsView
    
  ## UI ##################################################################
  ########################################################################
  
  createTable: (options) =>
    table = Ti.UI.createTableView options
    table.addEventListener('scroll', @onScroll)
    table.addEventListener('dragend', @onDragend)
      
    if options.pullToRefresh
      table.setHeaderPullView @createPullView()
    
    if options.infiniteScroll
      @lastDistance = 0
      table.setFooterView @createFooterView()
    
    table
  
  createNoResultsView: ->
    view = Ti.UI.createView {
      width: Ti.UI.FILL, height: Ti.UI.FILL
      backgroundColor: '#f8f8f8'
    }
    content = @createNoResultsContent()
    content.add @createNoResultsViewImage()
    content.add @createNoResultsViewLabel()
    view.add content
    view.hide()
    view
  createNoResultsContent: ->
    Ti.UI.createView {
      layout: 'vertical'
      width: Ti.UI.SIZE, height: Ti.UI.SIZE
    }
  createNoResultsViewImage: ->
    Ti.UI.createImageView {
      width: 100, height: 100
      image: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/no-results.png')
    }
  createNoResultsViewLabel: ->
    Ti.UI.createLabel {
      text: 'No Results\nFound'
      width: Ti.UI.SIZE
      color: '#bbb'
      textAlign: Ti.UI.TEXT_ALIGNMENT_CENTER
    }
  
  createPullView: ->
    @headerView = Ti.UI.createView {
      backgroundColor: '#bac5d3'
    }
    @headerView.add @createPullViewBottomBorder()
    @imageArrow = @createPullViewArrow()
    @headerLoader = @createPullViewLoader()
    @pullLabel = @createPullViewLabel()
    
    @headerView.add @imageArrow
    @headerView.add @headerLoader
    @headerView.add @pullLabel
    @headerView
  
  createPullViewBottomBorder: ->
    Ti.UI.createView {
      backgroundColor: '#91a3bc'
      bottom: 0
      height: 1
    }
  createPullViewArrow: ->
    Ti.UI.createImageView {
      image: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/whiteArrow.png')
    }
  createPullViewLoader: ->
    Ti.UI.createActivityIndicator()
  createPullViewLabel: ->
    Ti.UI.createLabel {
      text: 'Pull down to refresh...', color: '#576c89'
      textAlign: 'center'
    }
  
  createFooterView: ->
    @footerView = Ti.UI.createView {
      visible: false
    }
    @footerLoader = @createFooterViewLoader()
    @footerLoader.show()
    @footerView.add @footerLoader
    @footerView
  createFooterViewLoader: ->
    Ti.UI.createActivityIndicator()
  
  ## METHODS #############################################################
  ########################################################################
  
  clear: =>
    @table.setData []
    @rowCount = 0
  
  update: (data, hasMoreRows = false, toTop = false) =>
    if toTop
      for item in data by -1
        @table.insertRowBefore 0, item
        @rowCount++
    else
      if @rowCount is 0
        if data.length > 0
          rows = []
          for item in data
            rows.push item
            @rowCount++
          @table.setData rows
          @noResultsView.hide()
          @table.show()
        else
          @table.hide()
          @noResultsView.show()
      else
        for item in data
          @table.appendRow item, { animated: false }
          @rowCount++
      
      if @settings.infiniteScroll
        @hasMoreRows = hasMoreRows
        @footerView.hide()
  
  show: =>
    @table.show()
    
  hide: =>
    @table.hide()
  
  resetPullHeader: (table) ->
    @reloading = false
    @headerLoader.hide()
    @imageArrow.transform = Ti.UI.create2DMatrix()
    @imageArrow.show()
    @pullLabel.setText 'Pull down to refresh...'
    table.setContentInsets { top: 0 }, { animated: true }
  
  dispose: =>
    if @headerView?
      @headerView.remove @imageArrow
      @imageArrow = null
      @headerView.remove @headerLoader
      @headerLoader = null
      @headerView.remove @pullLabel
      @pullLabel = null
    if @footerView?
      @footerView.remove @footerLoader
      @footerLoader = null
   
  ## EVENTS ##############################################################
  ########################################################################
  
  onScroll: (e) =>

  onDragend: (e) =>