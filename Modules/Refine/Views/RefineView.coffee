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
    @propertyRows = []
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
        @propertyRows.push propertyRow
        @resetProperties[property.field] = { row: propertyRow, label: propertyRow.displayControl.getText(), value: property.value }
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
      
  createTable: ->
    Ti.UI.createTableView()
  
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
    row.property = property
    
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
  
  checkDependency: (propertyRow) =>
    if propertyRow.property.dependency?
      @updatePropertyRowStatus(propertyRow, true)
    else
      @updatePropertyRowStatus(propertyRow, false)
  
  updatePropertyRowStatus: (propertyRow, enabled) =>
    if enabled
      propertyRow.titleControl.color = '#ccc'
      propertyRow.removeEventListener('click', @onRowClicked)
    else
      propertyRow.titleControl.color = '#000'
      propertyRow.addEventListener('click', @onRowClicked)
  
  getPropertyDisplayLabel: (property, value) ->
    data = root._.find(property.data, (item) -> return item.value is value)
    if data?
      data.label
    else
      ' '
  
  cancelRefine: =>
    @userCancelled = true
    @close()
  
  reset: =>
    for field, obj of @resetProperties
      obj.row.displayControl.setText obj.label
      obj.row.property.value = obj.value
    
    @changeHistory = {}
    
    @settings.onReset()
  
  refine: =>
    @settings.onRefine ( =>
      updatedProperties= {}
      for property, obj of @changeHistory
        updatedProperties[obj.row.property.field] = obj.value
      updatedProperties
    )() # Returns a object with property names and their new values
    @close()
    
  ############################################################
  ### EVENTS #################################################
  ############################################################
  
  onClose: =>
    super
    if @userCancelled
      for property, obj of @changeHistory
        obj.row.displayControl.setText obj.originalLabel
        obj.row.property.value = obj.originalValue
      @changeHistory = {}
      @userCancelled = false
  
  onChange: (e) =>
    propertyRow = root._.find(@propertyRows, (propertyRow) -> return propertyRow.property.field is e.field)
    if propertyRow?
      @changeHistory[propertyRow.property.field] = {
        row: propertyRow
        originalLabel: propertyRow.displayControl.getText()
        originalValue: propertyRow.property.value
        value: e.value
      }
      propertyRow.property.value = e.value
      propertyRow.displayControl.setText e.label
    
  onRowClicked: (e) =>
    root.app.create('Refine.RefineSelectView', {
      getTitleLabel: @settings.getTitleLabel
      barImage: @settings.barImage
      rowSelectedBackgroundColor: @settings.rowSelectedBackgroundColor
      property: e.row.property
      onChange: @onChange
      onPropertyFetch: (field) => if @changeHistory[field]? then @changeHistory[field].value else null
    }).show()
    