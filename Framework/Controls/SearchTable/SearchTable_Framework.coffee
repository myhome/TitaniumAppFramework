root.SearchTable_Framework = class SearchTable_Framework
  constructor: (options = {}) ->
    @settings = root._.extend {
      backgroundColor: 'transparent'
      separatorColor: 'transparent'
      onTableClick: -> Ti.API.info 'SearchTable_Framework.onTableClick'
      pullToRefresh: false
      pullToRefreshCallback: -> Ti.API.info 'SearchTable_Framework.pullToRefreshCallback'
      infiniteScroll: false
      infiniteScrollCallback: -> Ti.API.info 'SearchTable_Framework.inifiniteScrollCallback'
    }, options
    
    @pulling = false
    @reloading = false
    @offset = 0
    @lastDistance = 0
    @hasMoreRows = false
    
    @table = @createTable(@settings)
    
  ## UI ##################################################################
  ########################################################################
  
  createTable: (options) =>
    table = Ti.UI.createTableView options
    table.addEventListener('click', options.onTableClick)
    table.addEventListener('scroll', @onScroll)
    table.addEventListener('dragend', @onDragend)
      
    if options.pullToRefresh
      table.setHeaderPullView @createPullView()
    
    if options.infiniteScroll
      @lastDistance = 0
      table.setFooterView @createFooterView()
    
    table
  
  createPullView: ->
    @headerView = Ti.UI.createView {
      width: 320, height: 60
      backgroundColor: '#bac5d3'
    }
    @headerView.add Ti.UI.createView {
      backgroundColor: '#91a3bc'
      bottom: 0
      height: 1
    }
    @imageArrow = Ti.UI.createImageView {
        image: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/whiteArrow.png')
        left: 20, bottom: 10
        width: 23, height: 60
    }
    @headerLoader = Ti.UI.createActivityIndicator {
        left: 20, bottom: 25
        width: 30, height: 30
    }
    @pullLabel = Ti.UI.createLabel {
      left: 55, bottom: 30
      text: 'Pull down to refresh...', color: '#576c89', font: { fontSize: 13, fontWeight: 'bold' }, shadowColor: '#fff', shadowOffset: { x: 0, y: 1 }
      textAlign: 'center'
      width: 200
    }
    @headerView.add @imageArrow
    @headerView.add @headerLoader
    @headerView.add @pullLabel
    @headerView
  
  createFooterView: ->
    @footerView = Ti.UI.createView {
      backgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray.png')
      backgroundLeftCap: 1
      backgroundTopCap: 1
      height: 40
      visible: false
      
    }
    @footerLoader = Ti.UI.createActivityIndicator {
      width: 30, height: 30
      style: Ti.UI.iPhone.ActivityIndicatorStyle.DARK
    }
    @footerLoader.show()
    @footerView.add @footerLoader
    @footerView
  
  createTableRow: (data) ->
    row = Ti.UI.createTableViewRow {
      className: data.className
      backgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray.png')
      selectedBackgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray-selected.png')
      backgroundLeftCap: 1
      backgroundTopCap: 1
    }
    row.id = data.id
    row.add data.view
    row
  
  ## METHODS #############################################################
  ########################################################################
  
  clear: =>
    @table.setData []
  
  update: (data, hasMoreRows = false, toTop = false) =>
    if toTop
      for item in data by -1
        row = @createTableRow(item)
        @table.insertRowBefore(0, row)
    else
      rows = []
      for item in data
        row = @createTableRow(item)
        rows.push row
      @table.appendRow rows
      
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
    @offset = e.contentOffset.y;
    if @settings.pullToRefresh
      if @pulling and !@reloading and @offset > -80 and @offset < 0
        @pulling = false
        unrotate = Ti.UI.create2DMatrix()
        @imageArrow.animate { transform: unrotate, duration: 180 }
        @pullLabel.setText 'Pull down to refresh...'
      else if !@pulling and !@reloading and @offset < -80
        @pulling = true
        rotate = Ti.UI.create2DMatrix().rotate(180)
        @imageArrow.animate { transform: rotate, duration: 180 }
        @pullLabel.setText 'Release to refresh...';
      
    if @settings.infiniteScroll
      height = e.size.height
      total = @offset + height
      theEnd = e.contentSize.height
      distance = theEnd - total
      if distance < @lastDistance
        if (total >= theEnd) && e.contentSize.height > e.size.height && @hasMoreRows
          @settings.infiniteScrollCallback()
          @footerView.show()
      @lastDistance = distance

  onDragend: (e) =>
    if @settings.pullToRefresh
      if @pulling and !@reloading and @offset < -80
        @pulling = false
        @reloading = true
        @pullLabel.text = 'Updating...'
        @imageArrow.hide()
        @headerLoader.show()
        e.source.setContentInsets { top: 80 }, { animated: true }
        
        setTimeout ( =>
          @settings.pullToRefreshCallback( => @resetPullHeader(@table))
        ), 1500
      