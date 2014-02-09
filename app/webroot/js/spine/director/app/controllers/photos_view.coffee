Spine           = require("spine")
$               = Spine.$
Controller      = Spine.Controller
Album           = require('models/album')
Photo           = require('models/photo')
AlbumsPhoto     = require('models/albums_photo')
Gallery         = require('models/gallery')
GalleriesAlbum  = require('models/galleries_album')
Info            = require('controllers/info')
PhotosList      = require('controllers/photos_list')
Extender        = require("plugins/controller_extender")
Drag            = require("plugins/drag")

require("plugins/tmpl")

class PhotosView extends Spine.Controller
  
  @extend Drag
  @extend Extender
  
  elements:
    '.hoverinfo'      : 'infoEl'
    '.items'          : 'items'
  
  events:
    'dragstart  .items .thumbnail'    : 'dragstart'
    'dragover   .items .thumbnail'    : 'dragover'
    'sortupdate .items'               : 'sortupdate'
    
  template: (items) ->
    $('#photosTemplate').tmpl(items)
    
  preloaderTemplate: ->
    $('#preloaderTemplate').tmpl()
    
  headerTemplate: (items) ->
    $("#headerPhotosTemplate").tmpl items
    
  infoTemplate: (item) ->
    $('#photoInfoTemplate').tmpl item
    
  constructor: ->
    super
    @el.data current: Album
    @info = new Info
      el: @infoEl
      template: @infoTemplate
    @list = new PhotosList
      el: @items
      template: @template
      info: @info
      parent: @
    @header.template = @headerTemplate
    AlbumsPhoto.bind('change', @proxy @renderHeader)
    AlbumsPhoto.bind('destroy', @proxy @remove)
    AlbumsPhoto.bind('create', @proxy @addAlbumsPhoto)
    Photo.bind('created', @proxy @add)
    Gallery.bind('change', @proxy @renderHeader)
    Album.bind('change', @proxy @renderHeader)
    Photo.bind('refresh destroy', @proxy @renderHeader)
    Photo.bind('beforeDestroy', @proxy @remove)
    Photo.bind('create:join', @proxy @createJoin)
    Photo.bind('destroy:join', @proxy @destroyJoin)
    Photo.bind('ajaxError', Photo.errorHandler)
    AlbumsPhoto.bind('ajaxError', Photo.errorHandler)
    Spine.bind('destroy:photo', @proxy @destroy)
    Spine.bind('show:photos', @proxy @show)
    Spine.bind('change:selectedAlbum', @proxy @renderHeader)
    Spine.bind('change:selectedAlbum', @proxy @change)
    Spine.bind('album:updateBuffer', @proxy @updateBuffer)
    
  updateBuffer: (album=Album.record) ->
    filterOptions =
      key: 'album_id'
      joinTable: 'AlbumsPhoto'
      sorted: true
    
    if album
      items = Photo.filterRelated(album.id, filterOptions)
    else
      items = Photo.filter()
      
    @buffer = items
  
  change: (album) ->
    @updateBuffer album
    @render @buffer
  
  render: (items, mode) ->
    return unless @isActive()
    console.log 'PhotosView::render'
    # render only if necessary
    # if view is dirty but inactive we'll use the buffer next time
    list = @list.render(items || @updateBuffer(), mode)
    list.sortable('photo') #if Album.record
    delete @buffer
  
  renderHeader: ->
    return unless @isActive()
    console.log 'PhotosView::renderHeader'
    @header.change()
  
  clearPhotoCache: ->
    Photo.clearCache()
  
  # for AlbumsPhoto & Photo
  remove: (item) ->
    console.log 'PhotosView::remove'
    unless item.constructor.className is 'Photo'
      item = Photo.exists(item.photo_id)

    photoEl = @items.children().forItem(item, true)
    photoEl.remove()
    if Album.record
      @render() unless Album.contains(Album.record.id)

  redirect: (ga) ->
    @navigate '/gallery', Gallery.record.id if ga.destroyed
  
  next: (album) ->
    album.last()
  
  destroy: (e) ->
    console.log 'PhotosView::destroy'
    list = Album.selectionList().slice(0)
    photos = []
    Photo.each (record) =>
      photos.push record unless list.indexOf(record.id) is -1
      
    if album = Album.record
      Album.emptySelection()
      Photo.trigger('destroy:join', photos, Album.record)
    else
      # clean up joins first
      for photo in photos
        # 
        # we can destroy the join without telling the server
        # as long as cakephp handles photo HABTM as unique (default)
        # 
        # so the server-side join is automatically
        # removed upon photo deletion in the next step
        #
        aps = AlbumsPhoto.filter(photo.id, key: 'photo_id')
        for ap in aps
          album = Album.exists(ap.album_id) 
          Spine.Ajax.disable ->
            Photo.trigger('destroy:join', photo, album) if album
            
      # now remove photo originals
      for photo in photos
        Album.removeFromSelection photo.id
        photo.destroyCache()
        photo.destroy()
    
  show: ->
    App.showView.trigger('change:toolbarOne', ['Default', 'Slider', App.showView.initSlider])
    App.showView.trigger('change:toolbarTwo', ['Slideshow'])
    App.showView.trigger('canvas', @)
    @render @buffer if @buffer
  
  save: (item) ->

  # methods after uplopad
  
  addAlbumsPhoto: (ap) ->
    photo = Photo.find(ap.photo_id)
    @add photo
  
  add: (records) ->
    console.log 'PhotosView::add'
    unless Photo.isArray records
      photos = []
      photos.push(records)
    else photos = records
    for photo in photos
      if Photo.exists(photo.id)
        @render([photo], 'append')
        @list.el.sortable('destroy').sortable('photos')
      
  createJoin: (photos, album, deleteTarget) ->
    # photos must be an array filled with type Photo
    console.log 'PhotosView::createJoin'
#    alert 'no array' unless Photo.isArray(photos)
    return unless album and album.constructor.className is 'Album'
    photos = new Array(photos) unless Photo.isArray(photos)
    for photo in photos
      unless AlbumsPhoto.albumHasPhoto(album.id, photo.id)
        ap = new AlbumsPhoto
          album_id: album.id
          photo_id: photo.id
          order: AlbumsPhoto.photos(album.id).length
        ap.save()
      
    if deleteTarget and deleteTarget.constructor.className is 'Album'
      @destroyJoin photos, deleteTarget
  
  destroyJoin: (photos, target) ->
    console.log 'PhotosView::destroyJoin'
    return unless target and target.constructor.className is 'Album'
    aps = AlbumsPhoto.filter(target.id, key: 'album_id')
    photos = new Array(photos)  unless Photo.isArray(photos)
    for ap in aps
      unless photos.indexOf(ap.photo_id) is -1
        Album.removeFromSelection ap.photo_id
        Spine.Ajax.disable ->
          ap.destroy()

  sortupdate: ->
    @list.children().each (index) ->
      item = $(@).item()
#      console.log AlbumsPhoto.filter(item.id, func: 'selectPhoto').length
      if item #and Album.record
        ap = AlbumsPhoto.filter(item.id, func: 'selectPhoto')[0]
        if ap and ap.order isnt index
          ap.order = index
          ap.save()
        # set a *invalid flag*, so when we return to albums cover view, thumbnails can get regenerated
        Album.record.invalid = true
#        Album.record.save(ajax:false)
#      else if item
#        photo = (Photo.filter(item.id, func: 'selectPhoto'))[0]
#        photo.order = index
#        photo.save()
        
    @list.exposeSelection()
    
module?.exports = PhotosView