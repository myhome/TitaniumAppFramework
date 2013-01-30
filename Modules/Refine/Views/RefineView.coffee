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
      onReset: ->
      onRefine: ->
    }, options
    
    @refineViews = []
    @propertyRows = []
    @changedProperties = {}
    
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
        section.add propertyRow
      groupsSections.push section
    
    table.setData groupsSections
    
    if @settings.getRefineButton?
      container = Ti.UI.createView { height: Ti.UI.SIZE }
      button = @settings.getRefineButton()
      button.addEventListener('click', @refine)
      container.add button
      table.setFooterView container
    
    table
  
  createCancelButton: ->
  
  createResetButton: ->
  
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
    row.addEventListener('click', @onRowClicked)
    
    if @settings.rowSelectedBackgroundColor?
      row.setSelectedBackgroundColor @settings.rowSelectedBackgroundColor
    
    title = @createPropertyTitle(property.title)
    value = @createPropertyDisplay(@getPropertyDisplayLabel(property, property.value))
    
    row.add title
    row.add value
    
    row.titleControl = title
    row.displayControl = value
    row.property = property
    row
  
  createPropertyTitle: (title) ->
    Ti.UI.createLabel {
      left: 0
      text: title
    }
  
  createPropertyDisplay: (display) =>
    Ti.UI.createLabel {
      right: 0
      text: display
      color: @settings.rowValueColor
    }
  
  createTableRow: ->
    Ti.UI.createTableViewRow {
      backgroundColor: '#fff'
    }

  ############################################################
  ### METHODS ################################################
  ############################################################
  
  getPropertyDisplayLabel: (property, value) ->
    data = root._.find(property.data, (item) -> return item.value is value)
    if data?
      data.label
    else
      ' '
  
  reset: =>
    @settings.onReset()
    @close()
  
  refine: =>
    @settings.onRefine(@changedProperties)
    @close()
    
  ############################################################
  ### EVENTS #################################################
  ############################################################
  
  onChange: (e) =>
    propertyRow = root._.find(@propertyRows, (propertyRow) -> return propertyRow.property.field is e.field)
    propertyRow.displayControl.setText e.label if propertyRow?
    @changedProperties[e.field] = e.value
    
  onRowClicked: (e) =>
    refineViews = root._.filter(@refineViews, (view) ->
      return view.settings.property.title is e.row.property.title
    )
    
    if refineViews.length > 0
      refineViews[0].update()
      refineViews[0].show()
    else
      view = root.app.create('Refine.RefineSelectView', {
        getTitleLabel: @settings.getTitleLabel
        barImage: @settings.barImage
        rowSelectedBackgroundColor: @settings.rowSelectedBackgroundColor
        property: e.row.property
        onChange: @onChange
        onPropertyFetch: (field) => @changedProperties[field]
      })
      if view?
        @refineViews.push view
        view.show()
  
    