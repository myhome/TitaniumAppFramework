root.SearchTable_Framework_iOS = class SearchTable_Framework_iOS extends root.SearchTable_Framework
  constructor: (options = {}) ->
    super root._.extend {}, options
    
  ## UI ##################################################################
  ########################################################################
  
  createTable: (options) ->
    table = super(options)
    table.applyProperties {
      separatorStyle: Titanium.UI.iPhone.TableViewSeparatorStyle.NONE
    }
    table
  
  createTableRow: (data) ->
    row = super(data)
    row.applyProperties {
      backgroundLeftCap: 1
      backgroundTopCap: 1
    }
    row
  
  ## METHODS #############################################################
  ########################################################################
  
  
  ## EVENTS ##############################################################
  ########################################################################
  
  
