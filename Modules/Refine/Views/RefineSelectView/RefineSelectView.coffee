root.Refine.RefineSelectView = class RefineSelectView extends root.BaseView
  
  @MODE = {
    SINGLE: 1
    MULTI: 2
  }
  
  constructor: (options = {}) ->
    super root._.extend {
      title: if options.property? then options.property.title else 'Select'
      property: null
      mode: root.Refine.RefineSelectView.MODE.SINGLE
      onChange: -> 'root.Refine.RefineSelectView: onChange'
      onConditionCheck: -> 'root.Refine.RefineSelectView: onConditionCheck'
    }, options
    
    @selectedRows = []
    @property = @settings.property
    
    @table = @createTable()
    @add @table

    @createCancelButton()
    
    @update()
    
  ############################################################
  ### UI #####################################################
  ############################################################
  
  update: =>
    rows = []
    for item, index in @property.data
      
      addtoTable = true
      if @property.conditionalProperty?
        conditionalPropertyValue = @settings.onPropertyFetch(@property.conditionalProperty)
        if conditionalPropertyValue?
          addtoTable = @property.condition(conditionalPropertyValue, item.value)

      if addtoTable      
        row = Ti.UI.createTableViewRow {
          title: item.label
          hasCheck: item.value is @property.value
          selectedBackgroundColor: @settings.rowSelectedBackgroundColor
        }
        if item.value is @property.value
          row.setHasCheck true
          @selectedRows.push row
        row.value = item.value
        row.label = item.label
        row.index = index
        rows.push row
    
    @table.setData rows
  
  createCancelButton: =>
  
  createTable: ->
    table = Ti.UI.createTableView()
    table.addEventListener('click', @onTableClicked)
    table
  
  deselectedRow: (row) ->
    row.setHasCheck false
    
  focusSelected: =>
    if @settings.mode is root.Refine.RefineSelectView.MODE.SINGLE
      if @selectedRows.length > 0
        @table.scrollToIndex(@selectedRows[0].index)
        
  
  ############################################################
  ### EVENT ##################################################
  ############################################################
    
  onFocus: =>
    super
    @focusSelected()  
    
  onTableClicked: (e) =>
    switch @settings.mode
      when root.Refine.RefineSelectView.MODE.SINGLE
      
        @deselectedRow row for row in @selectedRows
        @selectedRows = []
        @selectedRows.push e.row
        e.row.setHasCheck true
        @property.value = @selectedRows[0].value
        @settings.onChange({ field: @property.field, label: @selectedRows[0].label, value: @selectedRows[0].value})
        @close()
        
      when root.Refine.RefineSelectView.MODE.MULTI
      
        if row in @selectedRows
          row.setHasCheck false
        else
          @selectedRows.push row
          row.setHasCheck true
   
