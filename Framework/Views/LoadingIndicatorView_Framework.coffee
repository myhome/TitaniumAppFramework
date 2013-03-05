root.LoadingIndicatorView_Framework = class LoadingIndicatorView_Framework extends root.BaseView
  constructor:(options = {}) ->
    super root._.extend {}, options
    
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView = Ti.UI.createView {
        width: 100, height: 100
        zIndex: 1000
        backgroundColor: '#222'
        borderRadius: 10
        borderColor: '#fff'
        borderWidth: 5
      }
      
      @activityIndicator = Ti.UI.createActivityIndicator {
        top: 30,
        color: "#444"
        style: Ti.UI.iPhone.ActivityIndicatorStyle.LIGHT
      }
      
      @loadingView.add @activityIndicator
      @loadingView.add Ti.UI.createLabel {
        bottom: 20
        text: 'Loading'
        color: '#fff'
        font: { fontSize: 15, fontWeight: 'bold' }
      }
      @activityIndicator.show()
      
      @add(@loadingView)
    else if Ti.Platform.osname == "android"
      @activityIndicator = Ti.UI.createActivityIndicator({
        width: Ti.UI.SIZE, height: Ti.UI.SIZE
        color: "#333"
        cancelable: true
        style: Ti.UI.ActivityIndicatorStyle.BIG_DARK
        font: { fontSize: '20dp', fontWeight: 'bold' }
      })
      @add(@activityIndicator)
  
  ########################################################################
  ## METHODS #############################################################
  
  showLoadingIndicator: =>
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView.show() if @loadingView?
    else
      @activityIndicator.show() if @activityIndicator?
    
  hideLoadingIndicator: =>
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView.hide() if @loadingView?
    else
      @activityIndicator.hide() if @activityIndicator?
  
  dispose: =>
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView.remove @activityIndicator if @activityIndicator?
      @activityIndicator = null
      @remove @loadingView if @loadingView?
      @loadingView = null
    else
      @remove @activityIndicator if @activityIndicator?
      @activityIndicator = null
    super
