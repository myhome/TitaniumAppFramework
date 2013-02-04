root.Refine.RefineView = class RefineView extends root.BaseView
  constructor: (options = {}) ->
    super root._.extend {
      title: 'Refine'
      rowSelectedBackgroundColor: null
      rowValueColor: '#000'
      # groups: [
        # {
          # properties: [
            # {
              # title: 'Section'                                # Name given to row
              # field: 'PropertyClassID'                        # Property send back with result object
              # value: 4                                        # Default/Set value
              # data: [                                         # Options (Take and array of objects with label, value properties)
                # { label: 'Option 1', value: 1 }
                # { label: 'Option 2', value: 2 }
                # { label: 'Option 3', value: 3 }
                # { label: 'Option 4', value: 4 }
                # { label: 'Option 5', value: 5 }
              # ]
              # mode: root.Refine.RefineSelectView.Mode.SINGLE  # SINGLE, MULTI (Defaults to SINGLE)
              # conditionalProperty: 'MaxPrice'                 # Must be used with conditon method
              # condition: (conditionalValue, value) ->         # Evaluate conditional value against set value to return true | false
                # Ti.API.info('Evaluate')
            # }
          # ]
        # }
      # ]
      onReset: -> Ti.API.info 'root.Refine.RefineView.onReset'
      onRefine: -> Ti.API.info 'root.Refine.RefineView.onRefine'
    }, options
    
    @userCancelled = false
    @propertyRows = {}
    @changeHistory = {}
    @resetProperties = {}
    
    @add @build()
    @createCancelButton()
    @createResetButton()
  
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
    
    if @settings.getRefineButton?
      table.setFooterView @createFooterView()
    
    table
  
  createCancelButton: ->
  
  createResetButton: ->
    
  createFooterView: =>
    container = Ti.UI.createView { height: Ti.UI.SIZE }
    button = @settings.getRefineButton()
    button.addEventListener('click', @refine)
    container.add button
    container
      
  createTable: -> Ti.UI.createTableView()
  
  createGroupSection: ->
    Ti.UI.createTableViewSection {
      headerView: Ti.UI.createView { height: 1 }
    }
  
  createPropertyRow: (property) =>
    row = Ti.UI.createTableViewRow {
      backgroundColor: '#fff'
      hasChild: true
    }
    
    if @settings.rowSelectedBackgroundColor?
      row.setSelectedBackgroundColor @settings.rowSelectedBackgroundColor
    
    title = @createPropertyTitle(property.title)
    value = @createPropertyDisplay(@getPropertyDisplayLabel(property, property.value))
    
    row.add title
    row.add value
    
    row.titleControl = title
    row.displayControl = value
    row.refineProperty = property
    
    @checkDependency(row)
    
    row
  
  createPropertyTitle: (title) ->
    Ti.UI.createLabel {
      left: 0
      text: title
      textAlign: Ti.UI.TEXT_ALIGNMENT_LEFT
    }
  
  createPropertyDisplay: (display) =>
    Ti.UI.createLabel {
      right: 0
      text: display
      color: @settings.rowValueColor
      textAlign: Ti.UI.TEXT_ALIGNMENT_RIGHT
    }
  
  createTableRow: ->
    Ti.UI.createTableViewRow {
      backgroundColor: '#fff'
    }

  ############################################################
  ### METHODS ################################################
  ############################################################
  
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
      propertyRow.titleControl.color = '#ccc'
      propertyRow.removeEventListener('click', @onRowClicked) if propertyRow.active
      propertyRow.active = false
    else
      propertyRow.titleControl.color = '#000'
      propertyRow.addEventListener('click', @onRowClicked) if !propertyRow.active
      propertyRow.active = true
  
  getPropertyDisplayLabel: (property, value) ->
    data = root._.find(property.data, (item) -> return item.value is value)
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
      item.label
  
  cancelRefine: =>
    @userCancelled = true
    @close()
  
  reset: =>
    for field, obj of @resetProperties
      obj.row.displayControl.setText obj.label
      obj.row.refineProperty = root._.extend obj.row.refineProperty, { value: obj.value }
    
    @changeHistory = {}
    @refreshDependencies()
    @settings.onReset()
  
  refine: =>
    @settings.onRefine ( =>
      updatedProperties= {}
      for field, obj of @changeHistory
        updatedProperties[field] = obj.value
      updatedProperties
    )() # Returns a object with property names and their new values
    @close()
    
  ############################################################
  ### EVENTS #################################################
  ############################################################
  
  onClose: =>
    super
    if @userCancelled
      for field, obj of @changeHistory
        propertyRow = @propertyRows[field]
        if propertyRow?
          propertyRow.displayControl.setText obj.originalLabel
          propertyRow.refineProperty = root._.extend propertyRow.refineProperty, { value: obj.originalValue }
        
      @changeHistory = {}
      @userCancelled = false
  
  onFocus: =>
    super
    @refreshDependencies()
  
  onChange: (change) => # { field: 'name', value: [value] }
    propertyRow = @propertyRows[change.field]
    @changeHistory[change.field] = {
      originalLabel: propertyRow.displayControl.getText()
      originalValue: propertyRow.refineProperty.value
      value: change.value
    }
    
    dynamicFields = root._.filter(@propertyRows, (row) ->
      row.refineProperty.dynamicDataDependency? and row.refineProperty.dynamicDataDependency is change.field
    )
    
    for row in dynamicFields
      row.refineProperty = root._.extend row.refineProperty, {
        value: @resetProperties[row.refineProperty.field].value
      }
      row.displayControl.setText @getDisplay(row.refineProperty)
      delete @changeHistory[row.refineProperty.field]
    
    propertyRow.refineProperty = root._.extend propertyRow.refineProperty, { value: change.value }
    propertyRow.displayControl.setText @getDisplay(propertyRow.refineProperty)
 
  onRowClicked: (e) =>
    if !@refineSeletView?
      @refineSeletView = root.app.create('Refine.RefineSelectView', {
        getTitleLabel: @settings.getTitleLabel
        barImage: @settings.barImage
        rowSelectedBackgroundColor: @settings.rowSelectedBackgroundColor
        onChange: @onChange
        onPropertyFetch: (field) =>
          if @changeHistory[field]?
            @changeHistory[field].value
          else
            @propertyRows[field].refineProperty.value
        onClose: => @inSelectView = false
      })
    @refineSeletView.update(e.row.refineProperty)
    @inSelectView = true
    @refineSeletView.show()
    