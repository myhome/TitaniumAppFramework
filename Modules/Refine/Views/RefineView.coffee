root.Refine.RefineView = class RefineView extends root.BaseView
  constructor: (options = {}) ->
    super root._.extend {
      title: 'Refine'
      resetEnabled: false
      rowSelectedBackgroundColor: null
      rowValueColor: '#000'
      groups: [
        {
          properties: [
            {
              title: 'Section'                                # Name given to row
              field: 'PropertyClassID'                        # Property send back with result object
              value: 4                                        # Default/Set value
              data: [                                         # Options
                { title: 'For Sale', value: 1 }
                { title: 'New Homes', value: 2 }
                { title: 'To Rent', value: 3 }
                { title: 'To Share', value: 4 }
                { title: 'Commercial', value: 6 }
                { title: 'Irish Holiday Homes', value: 5 }
                { title: 'Overseas For Sale', value: 9 }
                { title: 'Overseas To Rent', value: 10 }
              ]
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
    
    if @settings.resetEnabled
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
      container = Ti.UI.createView {
        height: Ti.UI.SIZE
      }
      button = @settings.getRefineButton()
      button.addEventListener('click', @refine)
      container.add button
      table.setFooterView container
    
    table
  
  createCancelButton: =>
  
  createResetButton: =>
  
  createTable: ->
    Ti.UI.createTableView {
      
    }
  
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
    value = @createPropertyValue(@getPropertyDisplayLabel(property, property.value))
    
    row.add title
    row.add value
    
    row.titleControl = title
    row.valueControl = value
    row.property = property
    row
  
  createPropertyTitle: (title) ->
    Ti.UI.createLabel {
      left: 0
      text: title
    }
  
  createPropertyValue: (label) =>
    Ti.UI.createLabel {
      right: 0
      text: label
      color: @settings.rowValueColor
    }
  
  createTableRow: ->
    Ti.UI.createTableViewRow {
      backgroundColor: '#fff'
    }

  ############################################################
  ### METHODS ################################################
  ############################################################
  
  getPropertyRow: (field) =>
    propertyRow = root._.filter(@propertyRows, (propertyRow) ->
      return propertyRow.property.field is field
    )
    if propertyRow.length > 0
      propertyRow[0]
    else
      null
  
  getPropertyDisplayLabel: (property, value) ->
    values = root._.filter(property.data, (item) ->
      return item.value is value
    )
    if values.length > 0
      values[0].title
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
    propertyRow = @getPropertyRow(e.field)
    if propertyRow?
      propertyRow.valueControl.setText e.label
    
    @changedProperties[e.field] = e.value
    
    Ti. API.info @changedProperties
    
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
  
    