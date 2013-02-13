root.SearchTable_Framework = class SearchTable_Framework
  constructor: (options = {}) ->
    @settings = root._.extend {
      backgroundColor: 'transparent'
      separatorColor: 'transparent'
      onTableClick: -> Ti.API.info 'SearchTable_Framework.onTableClick'
    }, options
    
    @table = @createTable(@settings)
    
  ## UI ##################################################################
  ########################################################################
  
  createTable: (options) ->
    table = Ti.UI.createTableView options
    table.addEventListener('click', options.onTableClick)
    table
  
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
  
  update: (data) =>
    rows = []
    for item in data
      row = @createTableRow(item)
      rows.push row
    @table.setData rows
  
  show: =>
    @table.show()
    
  hide: =>
    @table.hide()
    
  ## EVENTS ##############################################################
  ########################################################################
  
  
