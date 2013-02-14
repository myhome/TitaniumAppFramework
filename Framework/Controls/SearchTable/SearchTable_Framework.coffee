root.SearchTable_Framework = class SearchTable_Framework
  constructor: (options = {}) ->
    @settings = root._.extend {
      backgroundColor: 'transparent'
      separatorColor: 'transparent'
      onTableClick: -> Ti.API.info 'SearchTable_Framework.onTableClick'
      pullToRefresh: false
      pullToRefreshCallback: -> Ti.API.info 'SearchTable_Framework.pullToRefreshCallback'
      infiniteScroll: false
      inifiniteScrollCallback: -> Ti.API.info 'SearchTable_Framework.inifiniteScrollCallback'
    }, options
    
    @pulling = false
    @reloading = false
    @offset = 0
    
    @table = @createTable(@settings)
    
  ## UI ##################################################################
  ########################################################################
  
  createTable: (options) =>
    if options.pullToRefresh
      options = root._.extend options, {
        headerPullView: @createPullView()
      }
    
    table = Ti.UI.createTableView options
    table.addEventListener('click', options.onTableClick)
    
    if options.pullToRefresh
      table.addEventListener('scroll', @onScroll)
      table.addEventListener('dragend', @onDragend)
    
    table
  
  createPullView: ->
    @view = Ti.UI.createView {
      width: 320, height: 60
      backgroundColor: '#bac5d3'
    }
    @view.add Ti.UI.createView {
      backgroundColor: '#91a3bc'
      bottom: 0
      height: 1
    }
    @imageArrow = Ti.UI.createImageView {
        image: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/whiteArrow.png')
        left: 20, bottom: 10
        width: 23, height: 60
    }
    @actInd = Ti.UI.createActivityIndicator {
        left: 20, bottom: 25
        width: 30, height: 30
    }
    @pullLabel = Ti.UI.createLabel {
      left: 55, bottom: 30
      text: 'Pull down to refresh...', color: '#576c89', font: { fontSize: 13, fontWeight: 'bold' }, shadowColor: '#fff', shadowOffset: { x: 0, y: 1 }
      textAlign: 'center'
      width: 200
    }
    @view.add @imageArrow
    @view.add @actInd
    @view.add @pullLabel
    @view
  
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
  
  update: (data, toTop = false) =>
    if toTop
      for item in data by -1
        row = @createTableRow(item)
        @table.insertRowBefore(0, row)
    else
      rows = []
      for item in data
        row = @createTableRow(item)
        rows.push row
      @table.setData rows
  
  show: =>
    @table.show()
    
  hide: =>
    @table.hide()
  
  resetPullHeader: (table) ->
    @reloading = false
    @actInd.hide()
    @imageArrow.transform = Ti.UI.create2DMatrix()
    @imageArrow.show()
    @pullLabel.setText 'Pull down to refresh...'
    table.setContentInsets { top: 0 }, { animated: true }
  
  dispose: =>
    @view.remove @imageArrow if @imageArrow?
    @imageArrow = null
    @view.remove @actInd if @actInd?
    @actInd = null
    @view.remove @pullLabel if @pullLabel?
    @pullLabel = null
   
  ## EVENTS ##############################################################
  ########################################################################
  
  onScroll: (e) =>
    @offset = e.contentOffset.y;
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

  onDragend: (e) =>
    if @pulling and !@reloading and @offset < -80
      @pulling = false
      @reloading = true
      @pullLabel.text = 'Updating...'
      @imageArrow.hide()
      @actInd.show()
      e.source.setContentInsets { top: 80 }, { animated: true }
      
      setTimeout ( =>
        @settings.pullToRefreshCallback( => @resetPullHeader(@table))
      ), 1500
      