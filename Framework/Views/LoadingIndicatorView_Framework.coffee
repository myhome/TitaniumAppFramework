root.LoadingIndicatorView_Framework = class LoadingIndicatorView_Framework extends root.BaseView
  constructor:(options = {}) ->
    super options
    
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
      
      label = Ti.UI.createLabel {
        bottom: 20
        text: 'Loading'
        color: '#fff'
        font: { fontSize: 15, fontWeight: 'bold' }
      }

      @loadingView.add @activityIndicator
      @loadingView.add label
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
  
  showLoadingIndicator: =>
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView.show()
    else
      @activityIndicator.show()
    
  hideLoadingIndicator: =>
    if Ti.Platform.osname == "iphone" || Ti.Platform.osname == "ipad"
      @loadingView.hide()
    else
      @activityIndicator.hide()