root.PhotoPicker.PhotoPickerTable = class PhotoPickerTable
  constructor:(options = {}) ->
    @settings = root._.extend({
      backgroundColor: '#eee'
      photos: []
      onUpdate: (photos, thumbnails) ->
    }, options)
    
    @photos = []
    @thumbnails = []

    @view = Ti.UI.createView @settings
    
    @buttons = Ti.UI.createView({
      width: "100%"
      height: Ti.UI.SIZE
      top: 0
      backgroundColor: "#F9F9F9"
    })
    
    @addFromCameraButton = Ti.UI.createButton { title: 'Take Photo', height: 30, right: 5, top: 5, bottom: 5 }
    @addFromCameraButton.addEventListener 'click', @addFromCamera
    @buttons.add @addFromCameraButton
    
    @addFromGalleryButton = Ti.UI.createButton { title: 'Choose From Gallery', height: 30, left: 5, top: 5, bottom: 5 }
    @addFromGalleryButton.addEventListener 'click', @addFromGallery
    @buttons.add @addFromGalleryButton
    
    @view.add(@buttons)
    
    @grid = root.app.create 'PhotoPicker.PhotoGrid', {
      top: 80
      cellWidth: 100
      cellHeight: 100
      cellMargin: 5
      onRemove: (photo, thumbnail) =>  #TODO: GJ: record existing image deletes
        @photos = @photos.without photo
        @thumbnails = @thumbnails.without thumbnail
        @update()
    }
    @view.add @grid.view
    
    for existingPhoto in @settings.photos
      @grid.addPhoto existingPhoto, existingPhoto #TODO: GJ: thumbnail?
    
    @update()
    
  update: =>
    @settings.onUpdate @photos, @thumbnails
  
  addFromGallery: =>
    Ti.Media.openPhotoGallery {
      mediaTypes:[Ti.Media.MEDIA_TYPE_PHOTO]
      success: (e) => @addMedia e.media
      cancel: ->
      error: ->
    }
    
  addFromCamera: =>
    Ti.Media.showCamera { #TODO: GJ: can we set the orientation to force landscape?
      success: (e) => @addMedia e.media
      cancel: ->
      error: ->
    }
      
  addMedia: (image) =>
    thumbnail = image.imageAsThumbnail(100)
    image = image.imageAsResized(1600, 1200) #TODO: GJ: support other orientations
    filename = "#{Ti.Filesystem.applicationDataDirectory}photoPicker#{new Date().getTime()}.png"
    thumbfilename = "#{Ti.Filesystem.applicationDataDirectory}photoPicker#{new Date().getTime()}-thumb.png"

    @saveImage image, filename
    @saveImage thumbnail, thumbfilename

    @photos.push filename
    @thumbnails.push thumbfilename
    @grid.addPhoto thumbfilename, filename
    @update()
    
  saveImage: (image, filename) ->
    Ti.API.info "saving image #{filename}"
    file = Ti.Filesystem.getFile filename
    if file.exists()
      file.deleteFile()
      file = Ti.Filesystem.getFile filename
    file.write image
