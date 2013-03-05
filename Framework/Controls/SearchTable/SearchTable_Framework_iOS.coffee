root.SearchTable_Framework_iOS = class SearchTable_Framework_iOS extends root.SearchTable_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
    
  ## UI ##################################################################
  ########################################################################
  
  createNoResultsView: ->
    view = super
    view.applyProperties {
      left: 20, top: 20, right: 20, bottom: 20
      borderWidth: 1
      borderColor: '#bbb'
      borderRadius: 10
    }
    view
  createNoResultsViewImage: ->
    imageView = super
    imageView.applyProperties {
      width: 100, height: 100
    }
    imageView
  createNoResultsViewLabel: ->
    label = super
    label.applyProperties {
      top: 20, font: { fontSize: 18 }
      shadowColor: '#fff', shadowOffset: { x: 0, y: 1 }
    }
    label
  
  createTable: (options) ->
    table = super(options)
    table.applyProperties {
      separatorStyle: Titanium.UI.iPhone.TableViewSeparatorStyle.NONE
    }
    table
  
  createTableRow: (data) ->
    row = super(data)
    row.applyProperties {
      backgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray.png')
      selectedBackgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray-selected.png')
      backgroundLeftCap: 1
      backgroundTopCap: 1
    }
    row
  
  createPullViewLabel: ->
    label = super
    label.applyProperties {
      shadowColor: '#fff', shadowOffset: { x: 0, y: 1 }
    }
    label
  
  createFooterView: ->
    view = super
    view.applyProperties {
      height: 40
      backgroundImage: root.framework.getDeviceDependentImage('/Common/Framework/Images/Controls/SearchTable/gray.png')
      backgroundLeftCap: 1
      backgroundTopCap: 1
    }
    view
  createFooterViewLoader: ->
    activityIndicator = super
    activityIndicator.applyProperties {
      width: 30, height: 30
      style: Ti.UI.iPhone.ActivityIndicatorStyle.DARK
    }
    activityIndicator
  
  ## METHODS #############################################################
  ########################################################################
  
  
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
      
  
