root.Refine.RefineView = class RefineView extends root.BaseView
  constructor: (options = {}) ->
    super root._.extend {
      title: 'Refine'
      rowSelectedBackgroundColor: null
      rowValueColor: '#000'
      groups: [
        {
          properties: [
            {
              title: 'Section'                                # Name given to row
              field: 'PropertyClassID'                        # Property send back with result object
              value: 4                                        # Default/Set value
              data: [                                         # Options (Take and array of objects with label, value properties)
                { label: 'Option 1', value: 1 }
                { label: 'Option 2', value: 2 }
                { label: 'Option 3', value: 3 }
                { label: 'Option 4', value: 4 }
                { label: 'Option 5', value: 5 }
              ]
              mode: root.Refine.RefineSelectView.Mode.SINGLE  # SINGLE, MULTI (Defaults to SINGLE)
              conditionalProperty: 'MaxPrice'                 # Must be used with conditon method
              condition: (conditionalValue, value) ->         # Evaluate conditional value against set value to return true | false
                Ti.API.info('Evaluate')
            }
          ]
        }
      ]
      onReset: -> Ti.API.info 'root.Refine.RefineView.onReset'
      onRefine: -> Ti.API.info 'root.Refine.RefineView.onRefine'
      onCancel: -> Ti.API.info 'root.Refine.RefineView.onCancel'
      closeOnCancel: true
      closeOnReset: true
      closeOnRefine: true
      refineButtonsEnabled: true
    }, options
    
    @userCancelled = false
    @propertyRows = {}
    @changeHistory = {}
    @resetProperties = {}
    @inSelectView = false
    
    @table = @build()
    @add @table
    @createCancelButton()
  
  ############################################################
  ### UI #####################################################
  ############################################################
  
  build: =>
    table = @createTable()
    
    groupsSections = []
    for group in @settings.groups
      section = @createGroupSection()
      for property in group.properties
        
        propertyRow = @createPropertyRow(property)
        @propertyRows[property.field] = propertyRow
        @resetProperties[property.field] = {
          row: propertyRow
          label: @getPropertyDisplayLabel(property, property.value)
          value: property.value
        }
        section.add propertyRow
        
      groupsSections.push section
    table.setData groupsSections
    
    table
  
  createCancelButton: ->
    
  createHeaderView: =>
    Ti.UI.createView()
  
  createResetButton: ->
    Ti.UI.createView()
    
  createRefineButton: ->
    Ti.UI.createView()
      
  createTable: =>
    tableView = Ti.UI.createTableView()
    if @settings.refineButtonsEnabled
      tableView.setHeaderView @createHeaderView()
    
    tableView
  
  createGroupSection: ->
    Ti.UI.createTableViewSection {}
  
  createPropertyRow: (property) =>
    options = {
      backgroundColor: '#fff'
      hasChild: ((property.type? and property.type is 1) or !property.type?)
    }
    
    if @settings.rowSelectedBackgroundColor?
      root._.extend options , {
        selectedBackgroundColor: @settings.rowSelectedBackgroundColor
      }

    row = Ti.UI.createTableViewRow options
    
    title = @createPropertyTitle(property.title)
    row.add title
    row.titleControl = title
    
    if property.type? and property.type is 2
      checkbox = @createPropertyCheckbox(property.value)
      row.add checkbox
      row.checkboxControl = checkbox
    else
      value = @createPropertyDisplay(@getDisplay(property))
      row.add value
      row.displayControl = value
    
    
    row.refineProperty = property
    
    @checkDependency(row)
    
    row
  
  createPropertyTitle: (title) ->
    Ti.UI.createLabel {
      left: 0
      text: title
      color: '#000'
      textAlign: Ti.UI.TEXT_ALIGNMENT_LEFT
    }
  
  createPropertyDisplay: (display) =>
    Ti.UI.createLabel {
      right: 0
      text: display
      color: @settings.rowValueColor
      textAlign: Ti.UI.TEXT_ALIGNMENT_RIGHT
    }
  
  createPropertyCheckbox: (value) =>
    Ti.UI.createSwitch {
      right: 10
      value: if value then value else false
    }
  
  createTableRow: ->
    Ti.UI.createTableViewRow {
      backgroundColor: '#fff'
    }

  ############################################################
  ### METHODS ################################################
  ############################################################
  
  rebuild: (propertyGroups) =>
    @propertyRows = {}
    @changeHistory = {}
    @resetProperties = {}
    
    @settings.groups = propertyGroups
    
    for resetProperty in @resetProperties
      exists = false
      for group in @settings.groups
        for property in group
          if resetProperty[property.field]?
            exists = true
      if !exists
        delete @resetProperties[resetProperty.field]
    
    for changedProperty in @changeHistory
      exists = false
      for group in @settings.groups
        for property in group
          if changedProperty[group.field]?
            exists = true
      if !exists
        delete @changeHistory[changedProperty.field]
    
    @remove @table
    @table = @build()
    @add @table
  
  refreshDependencies: =>
    for field, row of @propertyRows
      if row.refineProperty.dependency?
        @checkDependency(row)
  
  checkDependency: (propertyRow) =>
    if propertyRow.refineProperty.dependency?
      dependencyPropertyRow = @propertyRows[propertyRow.refineProperty.dependency]
      if dependencyPropertyRow? and dependencyPropertyRow.refineProperty.value?
        @updatePropertyRowStatus(propertyRow, false)
      else
        @updatePropertyRowStatus(propertyRow, true)
    else
      @updatePropertyRowStatus(propertyRow, false)
  
  updatePropertyRowStatus: (propertyRow, dependencyMissing) =>
    if dependencyMissing
      if propertyRow.refineProperty.type? and propertyRow.refineProperty.type is 2
        propertyRow.checkboxControl.setEnabled false
        propertyRow.checkboxControl.removeEventListener('change', (e) => @onChange { field: propertyRow.refineProperty.field, value: e.value }) if propertyRow.active
        propertyRow.active = false
      else
        propertyRow.titleControl.color = '#CCC'
        propertyRow.removeEventListener('click', @onRowClicked) if propertyRow.active
        propertyRow.active = false
    else
      if propertyRow.refineProperty.type? and propertyRow.refineProperty.type is 2
        propertyRow.checkboxControl.setEnabled true
        propertyRow.checkboxControl.addEventListener('change', (e) => @onChange { field: propertyRow.refineProperty.field, value: e.value }) if !propertyRow.active
        propertyRow.active = true
      else
        propertyRow.titleControl.color = '#000'
        propertyRow.addEventListener('click', @onRowClicked) if !propertyRow.active
        propertyRow.active = true
  
  getPropertyDisplayLabel: (property, value) ->
    data = root._.find(property.data, (item) ->
      return item.value is value
    )
    if data?
      data.label
    else
      ' '
  
  getDisplay: (property) =>
    if property.mode is root.Refine.RefineSelectView.Mode.MULTI
      if property.value?
        "Selected #{property.value.length}"
      else
        @getPropertyDisplayLabel(property, property.value)
    else
      item =  root._.find(property.data, (item) -> item.value is property.value)
      if !item?
        property.value = property.default
        item = root._.find(property.data, (item) -> item.value is property.default)
        if !item?
          ''
        else
          item.label
      else  
        item.label
  
  cancelRefine: =>
    @userCancelled = true
    @close() if @settings.closeOnCancel
    @settings.onCancel()
  
  reset: =>
    resetProperties = @settings.onReset()
    for field, value of resetProperties
      row = @propertyRows[field]
      if row?
        row.refineProperty = root._.extend row.refineProperty, { value: value }
        
        if row.refineProperty.type? and row.refineProperty.type is 2
          row.checkboxControl.setValue if row.refineProperty.value then row.refineProperty.value else false
        else
          row.displayControl.setText @getDisplay(row.refineProperty)
    
    @changeHistory = {}
    @refreshDependencies()
    @close() if @settings.closeOnReset
  
  refine: =>
    @settings.onRefine ( =>
      updatedProperties= {}
      
      # for field, obj of @changeHistory
        # updatedProperties[field] = obj.value
      
      for field, obj of @propertyRows
        Ti.API.info obj.refineProperty.value
        updatedProperties[field] = obj.refineProperty.value
        
      updatedProperties
    )() # Returns a object with property names and their new values
    @close() if @settings.closeOnRefine
    
  ############################################################
  ### EVENTS #################################################
  ############################################################
  
  onClose: =>
    super
    if @userCancelled
      for field, obj of @changeHistory
        propertyRow = @propertyRows[field]
          
        if propertyRow?
          if propertyRow.refineProperty.type? and propertyRow.refineProperty.type is 2
            propertyRow.checkboxControl.setValue if propertyRow.refineProperty.originalValue then propertyRow.refineProperty.originalValue else false
          else
            propertyRow.displayControl.setText obj.originalLabel
          propertyRow.refineProperty = root._.extend propertyRow.refineProperty, { value: obj.originalValue }
        
      @changeHistory = {}
      @userCancelled = false
  
    if !@settings.refineButtonsEnabled
      @settings.onRefine ( =>
        updatedProperties= {}
        for field, obj of @changeHistory
          updatedProperties[field] = obj.value
        updatedProperties
      )() # Returns a object with property names and their new values
  
  onFocus: =>
    super
    @inSelectView = false
    @refreshDependencies()
  
  onChange: (change) => # { field: 'name', value: [value], data: [] }
    propertyRow = @propertyRows[change.field]
    @changeHistory[change.field] = {
      originalLabel: if propertyRow.displayControl? then propertyRow.displayControl.getText() else ''
      originalValue: propertyRow.refineProperty.value
      value: change.value
    }
    
    if propertyRow.refineProperty.onChange?
      propertyRow.refineProperty.onChange(change.value)
    
    dynamicFields = root._.filter(@propertyRows, (row) ->
      row.refineProperty.dynamicDataDependency? and row.refineProperty.dynamicDataDependency is change.field
    )
    
    # Update all dependent properties
    for row in dynamicFields
      if row.refineProperty.value != change.value
        row.refineProperty = root._.extend row.refineProperty, {
          value: row.refineProperty.default
        }
        if row.refineProperty.type? and row.refineProperty.type is 2
          row.checkboxControl.setValue if row.refineProperty.value then row.refineProperty.value else false
        else
          row.displayControl.setText @getDisplay(row.refineProperty)
        delete @changeHistory[row.refineProperty.field]
    
    # Update Changed Property Label/Checkbox
    propertyRow.refineProperty = root._.extend propertyRow.refineProperty, {
      value: change.value
      data: change.data
    }
    if propertyRow.refineProperty.type? and propertyRow.refineProperty.type is 2
      propertyRow.checkboxControl.setValue if propertyRow.refineProperty.value then propertyRow.refineProperty.value else false
    else
      propertyRow.displayControl.setText @getDisplay(propertyRow.refineProperty)
  
  onRowClicked: (e) =>
    if !@inSelectView
      Ti.API.info '------------- CLICK -------------'
      @inSelectView = true
      refineSelectView = root.app.create('Refine.RefineSelectView', {
        getTitleLabel: @settings.getTitleLabel
        style: @settings.style
        fontThemeColor: @settings.fontThemeColor
        rowSelectedBackgroundColor: @settings.rowSelectedBackgroundColor
        onChange: @onChange
        enableSelectIndex: e.row.refineProperty.enableSelectIndex
        onPropertyFetch: (field) =>
          if @changeHistory[field]?
            @changeHistory[field].value
          else
            @propertyRows[field].refineProperty.value
        onClose: => @inSelectView = false
      })
      refineSelectView.update(e.row.refineProperty)
      refineSelectView.settings.navigationGroup = @settings.navigationGroup if @settings.navigationGroup
      refineSelectView.show()
    