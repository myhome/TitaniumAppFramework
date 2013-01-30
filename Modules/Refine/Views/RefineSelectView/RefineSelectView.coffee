root.Refine.RefineSelectView = class RefineSelectView extends root.BaseView
  
  @Mode = {
    SINGLE: 1
    MULTI: 2
  }
  
  constructor: (options = {}) ->
    super root._.extend {
      title: if options.property? then options.property.title else 'Select'
      property: null
      onChange: -> 'root.Refine.RefineSelectView: onChange'
      onConditionCheck: -> 'root.Refine.RefineSelectView: onConditionCheck'
    }, options
    
    @selectedRows = []
    @rows = []
    @property = @settings.property
    @property.mode = root.Refine.RefineSelectView.Mode.SINGLE if !@property.mode?
    
    @table = @createTable()
    @add @table

    if @property.mode is root.Refine.RefineSelectView.Mode.MULTI
      @clearBackButton()
      @createDoneButton()
    else
      @createCancelButton()
      
    @update()
    
  ############################################################
  ### UI #####################################################
  ############################################################
  
  update: =>
    @rows = []
    for item, index in @property.data
      
      addtoTable = true
      if @property.conditionalProperty?
        conditionalPropertyValue = @settings.onPropertyFetch(@property.conditionalProperty)
        if conditionalPropertyValue?
          addtoTable = @property.condition(conditionalPropertyValue, item.value)

      if addtoTable      
        row = Ti.UI.createTableViewRow {
          title: item.label
          hasCheck: @hasCheck(item, @property.value)
          selectedBackgroundColor: @settings.rowSelectedBackgroundColor
        }
        
        if @property.default? and !@property.value?
          if item.value is @property.default
            row.setHasCheck true
            @selectedRows.push row
        else if item.value is @property.value
          row.setHasCheck true
          @selectedRows.push row
          
        row.value = item.value
        row.label = item.label
        row.index = index
        @rows.push row
    
    @table.setData @rows
  
  clearBackButton: =>
    
  createCancelButton: =>
    
  createDoneButton: =>
  
  createTable: ->
    table = Ti.UI.createTableView()
    table.addEventListener('click', @onTableClicked)
    table
  
  hasCheck: (item, value) =>
    if @property.mode is root.Refine.RefineSelectView.Mode.SINGLE
      item.value is value
    else if @property.mode is root.Refine.RefineSelectView.Mode.MULTI
      if value?
        if item.value in value
          return true
    false
  
  deselectedRow: (row) ->
    row.setHasCheck false
    
  focusSelected: =>
    if @property.mode is root.Refine.RefineSelectView.Mode.SINGLE
      if @selectedRows.length > 0
        @table.scrollToIndex(@selectedRows[0].index)
  
  getValue: =>
    if @property.mode is root.Refine.RefineSelectView.Mode.MULTI
      selectedValues = (() =>
        values = []
        for row in @selectedRows
          if row.value?
            values.push row.value
        values
      )()
    else
      @selectedRows[0].value
  
  getDisplay: =>
    if @property.mode is root.Refine.RefineSelectView.Mode.MULTI
      selectedValues = (() =>
        values = []
        for row in @selectedRows
          if row.value?
            values.push row.value
        values
      )()
      if selectedValues.length is 0
        @selectedRows[0].label
      else
        return "Selected #{selectedValues.length}"
    else
      @selectedRows[0].label
  
  ############################################################
  ### EVENT ##################################################
  ############################################################
    
  onFocus: =>
    super
    @focusSelected()  
    
  onTableClicked: (e) =>
    switch @property.mode
      when root.Refine.RefineSelectView.Mode.SINGLE
      
        @deselectedRow row for row in @selectedRows
        @selectedRows = []
        @selectedRows.push e.row
        e.row.setHasCheck true
        @property.value = @selectedRows[0].value
        @settings.onChange({ field: @property.field, label: @selectedRows[0].label, value: @selectedRows[0].value })
        @close()
        
      when root.Refine.RefineSelectView.Mode.MULTI
        
        if e.row.value is @property.default
          @deselectedRow row for row in @rows
          @selectedRows = []
          @selectedRows.push e.row
          @property.value = @getValue()
          e.row.setHasCheck true
        else
          defaultIndex = null
          for row, i in @selectedRows
            if row.value is @property.default
              row.setHasCheck false
              defaultIndex = i
          if defaultIndex?
            @selectedRows.splice(defaultIndex, 1)
          
          if e.row.getHasCheck()
            index = 0
            for row, i in @selectedRows
              if row.value is @property.default
                index = i
                
            @selectedRows.splice(index, 1)
            @property.value = @getValue()
            e.row.setHasCheck false
            
          else
            
            @selectedRows.push e.row
            @property.value = @getValue()
            e.row.setHasCheck true
        
        @settings.onChange({ field: @property.field, label: @getDisplay(), value: @property.value })
