root.TabGroup_Framework_iOS = class TabGroup_Framework_iOS
  constructor:(options = {}) ->
    options = root._.extend({
      items: []
    }, options)
    
    @tabs = Ti.UI.createTabGroup()
    
    for item in options.items
      tab = Ti.UI.createTab({
        title: item.tab.name
        icon: item.tab.icon
      })
      
      tab.window = item.view.window if item.view?
      
      @tabs.addTab(tab)
      #if item.onClick?
        #tab.addEventListener("click", item.onClick)
    
    @tabs.setActiveTab(0) if options.items.length > 0
    @tabs.open()


  setActiveTab: (index) -> @tabs.setActiveTab(index)