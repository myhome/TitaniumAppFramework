root.Refine.RefineSelectView = class RefineSelectView extends root.LoadingIndicatorView_Framework
  
  @Mode = {
    SINGLE: 1
    MULTI: 2
  }
  
  constructor: (options = {}) ->
    super root._.extend {
      style: 'brushedMetal'
      onChange: -> 'root.Refine.RefineSelectView: onChange'
      onConditionCheck: -> 'root.Refine.RefineSelectView: onConditionCheck'
      enableSelectIndex: false
    }, options
    
    @selectedRows = []
    @defaultRow = null
    @table = @createTable()
    @add @table
        
    @headers = []
    @index = []

    @createCancelButton()
    @createDoneButton()
    
  ############################################################
  ### UI #####################################################
  ############################################################
  
  createTable: ->
    table = Ti.UI.createTableView()
    table.addEventListener('click', @onTableClicked)
    table
  
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
        
        if values.length > 0
          values
        else
          null
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
        @selectedRows[0].title
      else
        return "Selected #{selectedValues.length}"
    else
      @selectedRows[0].title
  
  ############################################################
  ### METHODS ################################################
  ############################################################
  
  update: (property) =>
    @property = property
    @property.mode = root.Refine.RefineSelectView.Mode.SINGLE if !@property.mode?
    @updateTitle(@property.title)
    @updateNavButtons(@property.mode)
    
    if @property.dynamicData?
      @table.hide()
      @showLoadingIndicator()
      
      @property.dynamicData {
        dependencyValue: @settings.onPropertyFetch(@property.dynamicDataDependency)
        callback: (data) =>
          @property.data = data
          @populateTable(data)
      }
    else
      @populateTable(@property.data)
      
  populateTable: (data) =>
    @table.data =[]
    rows = []
    for item, index in data
      shouldAddRow = true
      
      if @property.conditionalProperty? and @property.condition?
        conditionalPropertyValue = @settings.onPropertyFetch(@property.conditionalProperty)
        if conditionalPropertyValue?
          shouldAddRow = @property.condition(conditionalPropertyValue, item.value)
      
      if shouldAddRow
      
        row = @createTableRow(item.label, index)
        
        if @hasCheck(@property, item.value)
          row.setHasCheck true
          @selectedRows.push row
        
        row.value = item.value
        row.index = index
        
        if item.value is @property.default
          @defaultRow = row
        
        rows.push row
    
    if @settings.enableSelectIndex
      @table.index = @index
    
    @table.setData rows
    
    @hideLoadingIndicator()
    @table.show()
  
  createTableRow: (label, index) =>
    options = {
      title: label
      backgroundColor: '#fff'
    }
    
    if @settings.enableSelectIndex
      letter = label.replace('-- ', '').substr(0, 1)
      if @headers.indexOf(letter) == -1
        @headers.push letter
        root._.extend options, { header: letter }
        @index.push { title: letter, index: index }
    
    if @settings.rowSelectedBackgroundColor?
      root._.extend options , {
        selectedBackgroundColor: @settings.rowSelectedBackgroundColor
      }
      
    row = Ti.UI.createTableViewRow options
    row
  
  isMulti: (property) -> property.mode is root.Refine.RefineSelectView.Mode.MULTI
  
  createCancelButton: ->
    
  createDoneButton: ->
  
  updateTitle: (title) => @window.setTitle if title? then title else 'Select'
  
  updateNavButtons: (mode) =>
    if mode is root.Refine.RefineSelectView.Mode.MULTI
      @showHideCancelButton false
      @showHideDoneButton true
    else
      @showHideCancelButton true
      @showHideDoneButton false
  
  showHideCancelButton: (show) =>
    
  showHideDoneButton: (show) =>

  hasCheck: (property, value) =>
    if property.mode is root.Refine.RefineSelectView.Mode.SINGLE
      property.value is value
    else
      if property.value?
        if root._.isArray(property.value)
          value in property.value
      else
        value is property.default

  selectRow: (row, clear) =>
    if clear
      @deselectRow selectedRow for selectedRow in @selectedRows
      @selectedRows = []

    @selectedRows.push row
    row.hasCheck = true
  
  deselectRow: (row) => row.setHasCheck false
  
  deselectDefault: =>
    defaultIndex = null
    for row, i in @selectedRows
      if row.value is @property.default
        row.setHasCheck false
        defaultIndex = i
    if defaultIndex?
      @selectedRows.splice(defaultIndex, 1)
  
  ############################################################
  ### EVENT ##################################################
  ############################################################
  
  onClose: =>
    super
    
    @property = null
    @selectedRows = []
    @table.data = []
    
    @settings.onClose() if @settings.onClose
    
  onFocus: =>
    super
    @focusSelected()  
    
  onTableClicked: (e) =>
    switch @property.mode
      when root.Refine.RefineSelectView.Mode.SINGLE
        @selectRow e.row, true
      when root.Refine.RefineSelectView.Mode.MULTI
        if e.row.value is @property.default
          @selectRow e.row, true
        else
          @deselectDefault()
          if e.row.getHasCheck()
            @deselectRow e.row
            
            index = 0
            for selectedRow, i in @selectedRows
              if selectedRow.value is e.row.value
                index = i
                   
            @selectedRows.splice(index, 1)
            
          else
            @selectRow e.row
    
    if @selectedRows.length == 0 and @property.default isnt 'undefined'
      @selectRow @defaultRow, true
    
    @property.value = @getValue()
    @settings.onChange { field: @property.field, value: @getValue(), data: @property.data }
    @close() if @property.mode is root.Refine.RefineSelectView.Mode.SINGLE
