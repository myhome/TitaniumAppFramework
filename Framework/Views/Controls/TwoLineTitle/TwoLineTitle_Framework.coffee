root.TwoLineTitle_Framework = class TwoLineTitle_Framework
  constructor: (options = {}) ->
    options = root._.extend {
      title: null
      subTitle: null
    }, options
    
    @view = @createView()
    @title = @createTitle()
    @subtitle = @createSubTitle()
    @bigtitle = @createBigTitle()

    @view.add @title
    @view.add @subtitle
    @view.add @bigtitle
    
    @view.addEventListener('click', (e) => options.onClick(e) if options.onClick)
    
    @update(options.title, options.subTitle)
  
  ## UI ##################################################################
  ########################################################################
  
  createView: ->
    Ti.UI.createView {
      top: 0
      width: Ti.UI.FILL, height: Ti.UI.SIZE
    }
    
  createTitle: ->
    Ti.UI.createLabel {
      top: 5
      width: Ti.UI.SIZE, height: 18
      text: ' ', textAlign: 'center', color: '#FFF'
      font: { fontSize: 15, fontWeight: 'bold' }
    }
  
  createSubTitle: ->
    Ti.UI.createLabel {
      color:'#FFF'
      width: Ti.UI.SIZE, height: 14
      bottom: 7
      text: ' '
      textAlign: 'center'
      font: { fontSize: 11, fontWeight: 'bold' }
    }
  
  createBigTitle: ->
    Ti.UI.createLabel {
      color:'#FFF'
      width: Ti.UI.SIZE, height: '100%'
      text: ' '
      textAlign: 'center'
      font: { fontSize: 17, fontWeight: 'bold' }
    }
  
  ## METHODS #############################################################
  ########################################################################
  
  update: (title, subtitle) =>
    if !subtitle? || subtitle == ''
      @title.setText ' '
      @subtitle.setText ' '
      @bigtitle.setText title
    else
      @title.setText title
      @subtitle.setText subtitle
      @bigtitle.setText ' '

  clear: =>
    @update('', null)
  
  dispose: =>
    @view.remove @title
    @title = null
    
    @view.remove @subtitle
    @subtitle = null
    
    @view.remove @bigtitle
    @bigtitle = null
    
    @view = null