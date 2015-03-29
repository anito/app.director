Spine           = require("spine")
$               = Spine.$
Model           = Spine.Model
Controller      = Spine.Controller
Gallery         = require('models/gallery')
Album           = require('models/album')
Photo           = require('models/photo')
AlbumsPhoto     = require('models/albums_photo')
GalleriesAlbum  = require('models/galleries_album')
Clipboard       = require("models/clipboard")
Settings        = require("models/settings")
ToolbarView     = require("controllers/toolbar_view")
WaitView        = require("controllers/wait_view")
AlbumsView      = require("controllers/albums_view")
PhotoHeader     = require('controllers/photo_header')
PhotosHeader    = require('controllers/photos_header')
PhotoView       = require('controllers/photo_view')
PhotosView      = require('controllers/photos_view')
AlbumsHeader    = require('controllers/albums_header')
AlbumsAddView   = require('controllers/albums_add_view')
PhotosAddView   = require('controllers/photos_add_view')
GalleriesView   = require('controllers/galleries_view')
GalleriesHeader = require('controllers/galleries_header')
SlideshowView   = require('controllers/slideshow_view')
SlideshowHeader = require('controllers/slideshow_header')
OverviewHeader  = require('controllers/overview_header')
OverviewView    = require('controllers/overview_view')
ModalSimpleView = require("controllers/modal_simple_view")
Extender        = require('plugins/controller_extender')
Drag            = require("plugins/drag")
require('spine/lib/manager')

class ShowView extends Spine.Controller

  @extend Drag
  @extend Extender

  elements:
    '#views .views'           : 'views'
    '.contents'               : 'contents'
    '.items'                  : 'lists'
    '.header .galleries'      : 'galleriesHeaderEl'
    '.header .albums'         : 'albumsHeaderEl'
    '.header .photos'         : 'photosHeaderEl'
    '.header .photo'          : 'photoHeaderEl'
    '.header .overview'       : 'overviewHeaderEl'
    '.header .slideshow'      : 'slideshowHeaderEl'
    '.opt-Overview'           : 'btnOverview'
    '.opt-EditGallery'        : 'btnEditGallery'
    '.opt-Gallery .ui-icon'   : 'btnGallery'
    '.opt-AutoUpload'         : 'btnAutoUpload'
    '.opt-Previous'           : 'btnPrevious'
    '.opt-Sidebar'            : 'btnSidebar'
    '.opt-FullScreen'         : 'btnFullScreen'
    '.opt-SlideshowPlay'      : 'btnSlideshowPlay'
    '.toolbarOne'             : 'toolbarOneEl'
    '.toolbarTwo'             : 'toolbarTwoEl'
    '.props'                  : 'propsEl'
    '.content.galleries'      : 'galleriesEl'
    '.content.albums'         : 'albumsEl'
    '.content.photos'         : 'photosEl'
    '.content.photo'          : 'photoEl'
    '.content.wait'           : 'waitEl'
    '#slideshow'              : 'slideshowEl'
    '#modal-action'           : 'modalActionEl'
    '#modal-addAlbum'         : 'modalAddAlbumEl'
    '#modal-addPhoto'         : 'modalAddPhotoEl'
    '.overview'               : 'overviewEl'
    
    '.slider'                 : 'slider'
    '.opt-Album'               : 'btnAlbum'
    '.opt-Gallery'             : 'btnGallery'
    '.opt-Photo'               : 'btnPhoto'
    '.opt-Upload'              : 'btnUpload'
    
  events:
    'click .opt-AutoUpload:not(.disabled)'            : 'toggleAutoUpload'
    'click .opt-Overview:not(.disabled)'              : 'showOverview'
    'click .opt-Previous:not(.disabled)'              : 'back'
    'click .opt-ShowModal:not(.disabled)'             : 'showModal'
    'click .opt-Sidebar:not(.disabled)'               : 'toggleSidebar'
    'click .opt-FullScreen:not(.disabled)'            : 'toggleFullScreen'
    'click .opt-CreateGallery:not(.disabled)'         : 'createGallery'
    'click .opt-CreateAlbum:not(.disabled)'           : 'createAlbum'
    'click .opt-DuplicateAlbums:not(.disabled)'       : 'duplicateAlbums'
    'click .opt-CopyAlbumsToNewGallery:not(.disabled)': 'copyAlbumsToNewGallery'
    'click .opt-CopyPhotosToNewAlbum:not(.disabled)'  : 'copyPhotosToNewAlbum'
    'click .opt-CopyPhoto'                            : 'copyPhoto'
    'click .opt-CutPhoto'                             : 'cutPhoto'
    'click .opt-PastePhoto'                           : 'pastePhoto'
    'click .opt-CopyAlbum'                            : 'copyAlbum'
    'click .opt-CutAlbum'                             : 'cutAlbum'
    'click .opt-PasteAlbum'                           : 'pasteAlbum'
    'click .opt-EmptyAlbum'                           : 'emptyAlbum'
    'click .opt-CreatePhoto:not(.disabled)'           : 'createPhoto'
    'click .opt-DestroyGallery:not(.disabled)'        : 'destroyGallery'
    'click .opt-DestroyAlbum:not(.disabled)'          : 'destroyAlbum'
    'click .opt-DestroyPhoto:not(.disabled)'          : 'destroyPhoto'
    'click .opt-EditGallery:not(.disabled)'           : 'editGallery' # for the large edit view
    'click .opt-Gallery:not(.disabled)'               : 'toggleGalleryShow'
    'click .opt-Rotate-cw:not(.disabled)'             : 'rotatePhotoCW'
    'click .opt-Rotate-ccw:not(.disabled)'            : 'rotatePhotoCCW'
    'click .opt-Album:not(.disabled)'                 : 'toggleAlbumShow'
    'click .opt-Photo:not(.disabled)'                 : 'togglePhotoShow'
    'click .opt-Upload:not(.disabled)'                : 'toggleUploadShow'
    'click .opt-ShowAllAlbums:not(.disabled)'         : 'showAlbumMasters'
    'click .opt-AddAlbums:not(.disabled)'             : 'showAlbumMastersAdd'
    'click .opt-ShowAllPhotos:not(.disabled)'         : 'showPhotoMasters'
    'click .opt-AddPhotos:not(.disabled)'             : 'showPhotoMastersAdd'
    'click .opt-ActionCancel:not(.disabled)'          : 'cancelAdd'
    'click .opt-SlideshowAutoStart:not(.disabled)'    : 'toggleSlideshowAutoStart'
    'click .opt-SlideshowPreview:not(.disabled)'      : 'slideshowPreview'
    'click .opt-SlideshowPhoto:not(.disabled)'        : 'slideshowPhoto'
    'click .opt-SlideshowPlay:not(.disabled)'         : 'slideshowPlay'
    'click .opt-ShowPhotoSelection:not(.disabled)'    : 'showPhotoSelection'
    'click .opt-ShowAlbumSelection:not(.disabled)'    : 'showAlbumSelection'
    'click .opt-SelectAll:not(.disabled)'             : 'selectAll'
    'click .opt-SelectNone:not(.disabled)'            : 'selectNone'
    'click .opt-SelectInv:not(.disabled)'             : 'selectInv'
    'click .opt-CloseDraghandle'                      : 'toggleDraghandle'
    'click .deselector'                               : 'deselect'
    'click .opt-Help'                                 : 'help'
    'click .opt-Version'                              : 'version'
    'click .opt-Prev'                                 : 'prev'
    
    'dblclick .draghandle'                            : 'toggleDraghandle'
    
    'hidden.bs.modal'                                 : 'hiddenmodal'
    
    # you must define dragover yourself in subview !!!!!!important
    'dragstart .item'                                 : 'dragstart'
    'dragenter .view'                                 : 'dragenter'
    'dragend'                                         : 'dragend'
    'drop'                                            : 'drop'
    
    'keydown'                                         : 'keydown'
    'keyup'                                           : 'keyup'
    
  constructor: ->
    super
    @bind('active', @proxy @active)
    @silent = true
    @toolbarOne = new ToolbarView
      el: @toolbarOneEl
    @toolbarTwo = new ToolbarView
      el: @toolbarTwoEl
    @galleriesHeader = new GalleriesHeader
      el: @galleriesHeaderEl
    @albumsHeader = new AlbumsHeader
      el: @albumsHeaderEl
      parent: @
    @photosHeader = new PhotosHeader
      el: @photosHeaderEl
      parent: @
    @photoHeader = new PhotoHeader
      el: @photoHeaderEl
      parent: @
    @slideshowHeader = new SlideshowHeader
      header: @slideshowHeaderEl
    @slideshowView = new SlideshowView
      el: @slideshowEl
      className: 'items'
      header: @slideshowHeader
      parent: @
      parentModel: 'Photo'
      subview: true
    @galleriesView = new GalleriesView
      el: @galleriesEl
      className: 'items'
      assocControl: 'opt-Gallery'
      header: @galleriesHeader
      parent: @
    @albumsView = new AlbumsView
      el: @albumsEl
      className: 'items'
      header: @albumsHeader
      parentModel: Gallery
      parent: @
    @photosView = new PhotosView
      el: @photosEl
      className: 'items'
      header: @photosHeader
      parentModel: Album
      parent: @
      slideshow: @slideshowView
    @photoView = new PhotoView
      el: @photoEl
      className: 'items'
      header: @photoHeader
      photosView: @photosView
      parent: @
      parentModel: Photo
    @albumAddView = new AlbumsAddView
      el: @modalAddAlbumEl
      parent: @albumsView
    @photoAddView = new PhotosAddView
      el: @modalAddPhotoEl
      parent: @photosView
    @waitView = new WaitView
      el: @waitEl
      parent: @
    
    @modalHelpView = new ModalSimpleView
      el: $('#modal-view')
    
    @modalVersionView = new ModalSimpleView
      el: $('#modal-view')
    
#    @bind('canvas', @proxy @canvas)
    @bind('change:toolbarOne', @proxy @changeToolbarOne)
    @bind('change:toolbarTwo', @proxy @changeToolbarTwo)
    @bind('activate:editview', @proxy @activateEditView)
    
    @bind('drag:start', @proxy @dragStart)
    @bind('drag:enter', @proxy @dragEnter)
    @bind('drag:end', @proxy @dragEnd)
    @bind('drag:drop', @proxy @dragDrop)
    
    @toolbarOne.bind('refresh', @proxy @refreshToolbar)
    
    @bind('awake', @proxy @awake)
    @bind('sleep', @proxy @sleep)
    
    Gallery.bind('change', @proxy @changeToolbarOne)
    Gallery.bind('change:selection', @proxy @refreshToolbars)
    Album.bind('change:selection', @proxy @refreshToolbars)
    GalleriesAlbum.bind('error', @proxy @error)
    AlbumsPhoto.bind('error', @proxy @error)
    AlbumsPhoto.bind('create destroy', @proxy @refreshToolbars)
    Album.bind('change', @proxy @changeToolbarOne)
    Photo.bind('change', @proxy @changeToolbarOne)
    Photo.bind('refresh', @proxy @refreshToolbars)
    Album.bind('current', @proxy @refreshToolbars)
    Spine.bind('albums:copy', @proxy @copyAlbums)
    Spine.bind('photos:copy', @proxy @copyPhotos)
    
    @current = @controller = @galleriesView
    
    @sOutValue = 160 # initial thumb size (slider setting)
    @sliderRatio = 50
    @thumbSize = 240 # size thumbs are created serverside (should be as large as slider max for best quality)
    
    @canvasManager = new Spine.Manager(@galleriesView, @albumsView, @photosView, @photoView, @slideshowView, @waitView)
    @headerManager = new Spine.Manager(@galleriesHeader, @albumsHeader, @photosHeader, @photoHeader, @slideshowHeader)
    
    @canvasManager.bind('change', @proxy @changeCanvas)
    @headerManager.bind('change', @proxy @changeHeader)
    @trigger('change:toolbarOne')
    
    Gallery.bind('change:current', @proxy @scrollTo)
    Album.bind('change:current', @proxy @scrollTo)
    Photo.bind('change:current', @proxy @scrollTo)
    
    Settings.bind('change', @proxy @changeSettings)
    Settings.bind('refresh', @proxy @refreshSettings)
    
  active: (controller, params) ->
    # preactivate controller
    controller.trigger('active', params)
    controller.header?.trigger('active')
    @activated(controller)
    @focus()
    
  changeCanvas: (controller) ->
    $('.items', @el).removeClass('in')
    t = switch controller.type
      when "Gallery"
        true
      when "Album"
        unless Gallery.record
          true
        else false
      when "Photo"
        unless Album.record
          true
        else false
      else false
        
        
    _1 = =>
      if t
        @contents.addClass('all')
      else
        @contents.removeClass('all')
      _2()
        
    _2 = =>
      viewport = controller.viewport or controller.el
      viewport.addClass('in')
      
      
    window.setTimeout( =>
      _1()
    , 200)
    
  changeHeader: (controller) ->
#    controller.trigger('active')
    
  activated: (controller) ->
    @previous = @current unless @current.subview
    @current = @controller = controller
    @currentHeader = controller.header
    @prevLocation = location.hash
    @el.data('current',
      model: controller.el.data('current').model
      models: controller.el.data('current').models
    )
    # the controller should already be active, however rendering hasn't taken place yet
    controller.trigger 'active'
    controller.header.trigger 'active'
    controller.focus()
    controller
    
  changeToolbarOne: (list) ->
    @toolbarOne.change list
    @toolbarTwo.refresh()
    @refreshElements()
    
  changeToolbarTwo: (list) ->
    @toolbarTwo.change list
    @refreshElements()
    
  refreshToolbar: (toolbar, lastControl) ->
    
  refreshToolbars: ->
    @log 'refreshToolbars'
    @toolbarOne.refresh()
    @toolbarTwo.refresh()
    
  renderViewControl: (controller) ->
    App.hmanager.change(controller)
  
  createGallery: (e) ->
    Spine.trigger('create:gallery')
    e.preventDefault()
  
  createPhoto: (e) ->
    Spine.trigger('create:photo')
    e.preventDefault()
  
  createAlbum: ->
    Spine.trigger('create:album')
    
    if Gallery.record
      @navigate '/gallery', Gallery.record.id, Album.last()
    else
      @showAlbumMasters()
  
  copyAlbums: (albums, gallery) ->
    hash = location.hash
    Album.trigger('create:join', albums, gallery)
      
  copyPhotos: (photos, album) ->
    hash = location.hash
    options =
      photos: photos
      album: album
    Photo.trigger('create:join', options)
      
  copyAlbumsToNewGallery: ->
    @albumsToGallery Gallery.selectionList()[..]
      
  copyPhotosToNewAlbum: ->
    @photosToAlbum Album.selectionList()[..]
      
  duplicateStart: ->
      
  donecallback: (rec) ->
    console.log 'DONE'
      
  failcallback: (t) ->
    console.log 'FAIL'
  
  progresscallback: (rec) ->
    console.log 'PROGRESS'
    console.log @state()
  
  duplicateAlbums: ->
    @deferred = $.Deferred()
    $.when(@duplicateAlbumsDeferred()).then(@donecallback,@failcallback,@progresscallback)
    
      
  duplicateAlbumsDeferred: ->
    deferred = @deferred or @deferred = $.Deferred()
    list = Gallery.selectionList()
    for id in list
      @duplicateAlbum id
    
    deferred.promise()
    
  duplicateAlbum: (id) ->
    return unless album = Album.find(id)
    callback = (a, def) => @deferred.always(->
      console.log 'completed with success ' + a.id
    )
    photos = album.photos().toID()
    @photosToAlbum photos, callback
      
  albumsToGallery: (albums, gallery) ->
    Spine.trigger('create:gallery',
      albums: albums
      gallery: gallery
      deleteFromOrigin: false
      relocate: true
    )
  
  photosToAlbum: (photos, callback) ->
    target = Gallery.record
    Spine.trigger('create:album', target,
      photos: photos
      deleteFromOrigin: false
      relocate: true
      deferred: @deferred
      cb: callback
    )
    
  createAlbumCopy: (albums=Gallery.selectionList(), target=Gallery.record) ->
    @log 'createAlbumCopy'
    for id in albums
      if Album.find(id)
        photos = Album.photos(id).toID()
        
        Spine.trigger('create:album', target
          photos: photos
        )
        
    if target
      target.updateSelection albums
      @navigate '/gallery', target.id
    else
      @showAlbumMasters()
      
  createAlbumMove: (albums=Gallery.selectionList(), target=Gallery.record) ->
    for id in albums
      if Album.find(id)
        photos = Album.photos(id).toID()
        Spine.trigger('create:album', target
          photos: photos
          from:Album.record
        )
    
    if Gallery.record
      @navigate '/gallery', target.id
    else
      @showAlbumMasters()
  
  emptyAlbum: (e) ->
    albums = Gallery.selectionList()
    for aid in albums
      if album = Album.find aid
        aps = AlbumsPhoto.filter(album.id, key: 'album_id')
        for ap in aps
          ap.destroy()
    
      Album.trigger('change:collection', album)
    
    e.preventDefault()
    e.stopPropagation()
    
  editGallery: (e) ->
    Spine.trigger('edit:gallery')

  editAlbum: (e) ->
    Spine.trigger('edit:album')

  destroySelected: (e) ->
    models = @controller.el.data('current').models
    @['destroy'+models.className]()
    e.stopPropagation()

  destroyGallery: (e) ->
    return unless Gallery.record
    Spine.trigger('destroy:gallery', Gallery.record.id)
  
  destroyAlbum: (e) ->
    Spine.trigger('destroy:album')

  destroyPhoto: (e) ->
    Spine.trigger('destroy:photo')

  toggleGalleryShow: (e) ->
    @trigger('activate:editview', 'gallery', e.target)
    e.preventDefault()
    
  toggleAlbumShow: (e) ->
    @trigger('activate:editview', 'album', e.target)
    @refreshToolbars()
    e.preventDefault()

  togglePhotoShow: (e) ->
    @trigger('activate:editview', 'photo', e.target)
    @refreshToolbars()
    e.preventDefault()

  toggleUploadShow: (e) ->
    @trigger('activate:editview', 'upload', e.target)
    e.preventDefault()
    @refreshToolbars()
    
  toggleGallery: (e) ->
    @changeToolbarOne ['Gallery']
    @refreshToolbars()
    e.preventDefault()
    
  toggleAlbum: (e) ->
    @changeToolbarOne ['Album']
    @refreshToolbars()
    e.preventDefault()
    
  togglePhoto: (e) ->
    @changeToolbarOne ['Photos', 'Slider']#, App.showView.initSlider
    @refreshToolbars()
    
  toggleUpload: (e) ->
    @changeToolbarOne ['Upload']
    @refreshToolbars()

  toggleSidebar: () ->
    App.sidebar.toggleDraghandle()
    
  toggleFullScreen: () ->
    App.trigger('chromeless')
    @refreshToolbars()
    
  toggleFullScreen: () ->
    @slideshowView.toggleFullScreen()
    @refreshToolbars()
    
  toggleSlideshow: ->
    active = @btnSlideshow.toggleClass('active').hasClass('active')
    @slideshowView.slideshowMode(active)
    @refreshToolbars()

  toggleSlideshowAutoStart: ->
    res = App.slideshow.data('bs.modal').options.toggleAutostart()
    @refreshToolbars()
    res
    
  isAutoplay: ->
    @slideshowView.autoplay
  
  toggleDraghandle: ->
    @animateView()
    
  toggleAutoUpload: ->
#    active = !@isAutoUpload()
#    console.log first = Setting.first()
#    active = !first.autoupload
    @settings = Settings.findUserSettings()
    active = @settings.autoupload = !@settings.autoupload
    $('#fileupload').data('blueimpFileupload').options['autoUpload'] = active
    @settings.save()
    @refreshToolbars()
  
  refreshSettings: (records) ->
    @changeSettings settings if settings = Settings.findUserSettings()
    @refreshToolbars()
  
  changeSettings: (rec) ->
    active = rec.autoupload
    $('#fileupload').data('blueimpFileupload').options['autoUpload'] = active
    @refreshToolbars()
  
  isAutoUpload: ->
    $('#fileupload').data('blueimpFileupload').options['autoUpload']
  
  activateEditView: (controller) ->
    App[controller].trigger('active')
    @openView()
    
  closeView: ->
    return if !App.hmanager.el.hasClass('open')
    @animateView(close: true)
  
  openView: (val='300') ->
    return if App.hmanager.el.hasClass('open')
    @animateView(open: val)
    
  animateView: (options) ->
    min = 20
    
    options = $().extend {open: false}, options
    speed = if options.close or options.open then 600 else 400
    
    if options.open
      App.hmanager.el.removeClass('open')
      App.hmanager.el.addClass('forcedopen')
      
    
    isOpen = ->
      App.hmanager.el.hasClass('open')
    
    height = ->
      h = if !isOpen()# and !options.close
        parseInt(options.open or App.hmanager.currentDim)
      else
        parseInt(min)
      h
    
    @views.animate
      height: height()+'px'
      speed
      (args...) ->
        if $(@).height() is min
          $(@).removeClass('open forcedopen')
        else
          $(@).addClass('open')
    
  awake: -> 
    @views.addClass('open')
  
  sleep: ->
    @animateView()
    
  openPanel: (controller) ->
    return if @views.hasClass('open')
    App[controller].deactivate()
    ui = App.hmanager.externalClass(App[controller])
    ui.click()
    
  closePanel: (controller, target) ->
    App[controller].trigger('active')
    target.click()
    
  deselect: (e) =>
    return unless $(e.target).hasClass('deselector')
    model = @el.data('current').model
    models = @el.data('current').models
    models.trigger('activate', [])
    try
      @current.itemsEl.deselect()
    catch e
    
  selectAll: (e) ->
    try
      list = @select_()
      @current.select(list, true)
    catch e
    
  selectNone: (e) ->
    try
#      list = @select_()
      @current.select([], true)
    catch e
    
  selectInv: (e)->
    try
      list = @select_()
      @current.select(list)
    catch e
    
  select_: ->
    list = []
    root = @current.itemsEl
    items = $('.item', root)
    unless root and items.length
      return list
    items.each () ->
      list.unshift @.id
    list
    
  uploadProgress: (e, coll) ->
    
  uploadDone: (e, coll) ->
#    @log coll
    
  sliderInValue: (val) ->
    val = val or @sOutValue
    @sInValue=(val/2)-@sliderRatio
    
  sliderOutValue: (value) ->
    val = value || @slider.slider('value')
    @sOutValue=(val+@sliderRatio)*2
    
  initSlider: =>
    inValue = @sliderInValue()
    @refreshElements()
    @slider.slider
      orientation: 'horizonatal'
      value: inValue
      slide: (e, ui) =>
        @sliderSlide ui.value
    
  sliderSlide: (val) =>
    newVal = @sliderOutValue val  
    Spine.trigger('slider:change', newVal)
    newVal
    
  slideshowPlay: (e) =>
    @slideshowView.trigger('play')
    
  slideshowPreview: (e) ->
    @navigate '/slideshow', ''
    
  slideshowPhoto: (e) ->
    if Photo.record
      @slideshowView.trigger('play', {}, [Photo.record])
    
  showOverview: (e) ->
    @navigate '/overview', ''

  showModal: (options) ->
#    opts =
#      header: 'New Header'
#      body  : Gallery.all()
#      footer: 'New Footer'
#      info  : 'Test Info'
#    opts = $.extend({}, opts, options)
#    @actionWindow.show(opts)
    
  showPhotosTrash: ->
    Photo.inactive()
    
  showAlbumsTrash: ->
    Album.inactive()

  showAlbumMasters: ->
    @navigate '/gallery', ''
    
  showPhotoMasters: ->
    @navigate '/gallery', '/'
    
  showAlbumMastersAdd: (e) ->
    e.preventDefault()
    e.stopPropagation()
    Spine.trigger('albums:add')
    
  showPhotoMastersAdd: (e) ->
    e.preventDefault()
    e.stopPropagation()
    Spine.trigger('photos:add')
    
  cancelAdd: (e) ->
    @back()
    App.sidebar.filter()
    @el.removeClass('add')
    e.preventDefault()
    
  showPhotoSelection: ->
    if Gallery.record
      @navigate '/gallery', Gallery.record.id, Gallery.selectionList()[0] or ''
    else
      @navigate '/gallery','', Gallery.selectionList()[0] or ''
    
  showAlbumSelection: ->
    @navigate '/gallery', Gallery.record.id or ''
      
  copy: (e) ->
    #type of copied objects depends on view
    model = @current.el.data('current').models.className
    switch model
      when 'Photo'
        @copyPhoto()
      when 'Album'
        @copyAlbum()
  
  cut: (e) ->
    #type of copied objects depends on view
    model = @current.el.data('current').models.className
    switch model
      when 'Photo'
        @cutPhoto()
      when 'Album'
        @cutAlbum()
  
  paste: (e) ->
    #type of pasted objects depends on clipboard items
    return unless first = Clipboard.first()
    model = first.item.constructor.className
    switch model
      when 'Photo'
        @pastePhoto()
      when 'Album'
        @pasteAlbum()
      
  copyPhoto: ->
    Clipboard.deleteAll()
    for id in Album.selectionList()
      Clipboard.create
        item: Photo.find id
        type: 'copy'
        
    @refreshToolbars()
    
  cutPhoto: ->
    Clipboard.deleteAll()
    for id in Album.selectionList()
      Clipboard.create
        item: Photo.find id
        type: 'copy'
        cut: Album.record
        
    @refreshToolbars()
    
  pastePhoto: ->
    return unless album = Album.record
    clipboard = Clipboard.findAllByAttribute('type', 'copy')
    items = []
    for clb in clipboard
      items.push clb.item
      
    callback = =>
      cut = Clipboard.last().cut
      origin = Clipboard.last().origin
      if cut
        Clipboard.destroyAll()
        options =
          photos: items
          album: cut
        Photo.trigger('destroy:join', options)
      @refreshToolbars()
      
    options = 
      photos: items
      album: album
    Photo.trigger('create:join', options, callback)
      
  rotatePhotoCW: (e) ->
    Spine.trigger('rotate', false, -90)
    @refreshToolbars()
    false
      
  rotatePhotoCCW: (e) ->
    Spine.trigger('rotate', false, 90)
    @refreshToolbars()
    false
      
  copyAlbum: ->
    Clipboard.deleteAll()
    for item in Gallery.selectionList()
      Clipboard.create
        item: Album.find item
        type: 'copy'
        
    @refreshToolbars()
    
  cutAlbum: ->
    Clipboard.deleteAll()
    for id in Gallery.selectionList()
      Clipboard.create
        item: Album.find id
        type: 'copy'
        cut: Gallery.record
        
    @refreshToolbars()
    
  error: (record, err) ->
    alert err
    
  pasteAlbum: ->
    return unless gallery = Gallery.record
    clipboard = Clipboard.findAllByAttribute('type', 'copy')
    
    callback = =>
      cut = Clipboard.last().cut
      origin = Clipboard.last().origin
      if cut
        Clipboard.deleteAll()
        Album.trigger('destroy:join', items, cut)
      @refreshToolbars()
    
    items = []
    for clb in clipboard
      items.push clb.item
      
    Album.trigger('create:join', items.toID(), gallery, callback)
      
  help: (e) ->
    @modalHelpView.el.one('hidden.bs.modal', @proxy @hiddenmodal)
    @modalHelpView.el.one('hide.bs.modal', @proxy @hidemodal)
    @modalHelpView.el.one('show.bs.modal', @proxy @showmodal)
    @modalHelpView.el.one('shown.bs.modal', @proxy @shownmodal)
    
    carousel_id = 'help-carousel'
    options = interval: 1000
    slides =
      [
        img: "/img/keyboard.png"
        width: '700px'
      ,
        items: [
            'What is Photo Director?',
            'Photo Director is a (experimental) content management tool for your photos',
            'Manage your photo content using different types of sets, such as albums and galleries',
            'As a result albums can than be used to present your content in slideshows'
          ]
      ,
        items: [
            'Importing content',
            items: [
              'To import your content, you can:',
              'Drag photos from the desktop to your browser, or',
              'Use the appropriate upload menu item',
            ],
            'Director currently supports JPG, JPE, GIF and PNG'
          ]
      ,
        items: [
            'Arrange your content',
            'Host your photo content in albums'
            'On the other hand, albums are supposed to be hosted in galleries'
            'This also gives you the flexibility to reuse identical albums in different places (galleries)'
          ]
      ,
        items: [
            'Order to your content'
            'After the content is part of a set, it will become sortable'
          ]
      ,
        items: [
            'Interaction',
            items: [
              'Organize your albums or photos in sets'
              'Drag your content from your main view to your sidebar or vice versa'
              'You can also quickly reorder albums within the sidebar only, without opening another gallery'
            ]
          ]
      ,
        items: [
            'Navigation'
            items: [
              'You can navigate through objects using arrow keys:',
              'To open the active object (dark blue border) hit Enter',
              'To close it again hit Esc'
            ]
          ]
      ,
        items: [
            'Selecting content',
            items: [
              'You can easily select one or more items. To do this, either...'
              'Select multiple objects using both ctrl-key and arrow key(s), or'
              'Single click multiple objects'
            ]
          ]
      ,
        items: [
            'Clipboard support'
            'You can copy, paste or cut objects just as you would do on a regular PC (by keybord or mouse)'
          ]
      ]
    
    @modalHelpView.show
      header: 'Quick Help'
      body: -> require("views/carousel")
        slides: slides
        id: carousel_id
      footerButtonText: 'Close'
    
    @carousel = $('.carousel', @el)
    @carousel.carousel options
    @log @carousel
        
  version: (e) ->
    @modalVersionView.el.one('hidden.bs.modal', @proxy @hiddenmodal)
    @modalVersionView.el.one('hide.bs.modal', @proxy @hidemodal)
    @modalVersionView.el.one('show.bs.modal', @proxy @showmodal)
    @modalVersionView.el.one('shown.bs.modal', @proxy @shownmodal)
    
    @modalVersionView.show
      small: true
      body: -> require("views/version")
        copyright     : 'Axel Nitzschner'
        spine_version : Spine.version
        app_version   : App.version
        bs_version    : $.fn.tooltip.Constructor.VERSION
      
  hidemodal: (e) ->
    @log 'hidemodal'
    
  hiddenmodal: (e) ->
    @log 'hiddenmodal'
    
  showmodal: (e) ->
    @log 'showmodal'
      
  shownmodal: (e) ->
    @log 'shownmodal'
      
  selectByKey: (direction, e) ->
    isMeta = e.metaKey or e.ctrlKey
    index = false
    lastIndex = false
    list = @controller.list.listener or @controller.list
    elements = if list then $('.item', list.el) else $()
    models = @controller.el.data('current').models
    parent = @controller.el.data('current').model
    record = models.record
    
    try
      activeEl = list.findModelElement(record) or $()
    catch e
      return
      
    elements.each (idx, el) =>
      lastIndex = idx
      if $(el).is(activeEl)
        index = idx
        
    index = parseInt(index)
        
    first   = elements[0] or false
    active  = elements[index] or first
    prev    = elements[index-1] or elements[index] or active
    next    = elements[index+1] or elements[index] or active
    last    = elements[lastIndex] or active
    
    switch direction
      when 'left'
        el = $(prev)
      when 'up'
        el = $(first)
      when 'right'
        el = $(next)
      when 'down'
        el = $(last)
      else
        @log active
        return unless active
        el = $(active)
        
    id = el.attr('data-id')
    if isMeta
      #support for multiple selection
      if parent
        selection = parent.selectionList()
        unless id in selection
          selection.addRemoveSelection(id)
        else
          selection.addRemoveSelection(selection.first())
          
        models.trigger('activate', selection)
    else
      models.trigger('activate', id)
        
  scrollTo: (item) ->
    return unless @controller.isActive() and item
    return unless item.constructor.className is @controller.el.data('current').models.className
    parentEl = @controller.el
    
    try
      el = @controller.list.findModelElement(item) or $()
      return unless el.length
    catch e
      # some controller don't have a list
      return
      
    marginTop = 55
    marginBottom = 10
    
    ohc = el[0].offsetHeight
    otc = el.offset().top
    stp = parentEl[0].scrollTop
    otp = parentEl.offset().top
    ohp = parentEl[0].offsetHeight  
    
    resMin = stp+otc-(otp+marginTop)
    resMax = stp+otc-(otp+ohp-ohc-marginBottom)
    
    outOfRange = stp > resMin or stp < resMax
    return unless outOfRange
    
    outOfMinRange = stp > resMin
    outOfMaxRange = stp < resMax

    res = if outOfMinRange then resMin else if outOfMaxRange then resMax
    return if Math.abs(res-stp) <= ohc/2
    
    parentEl.animate scrollTop: res,
      queue: false
      duration: 'slow'
      complete: =>
        
  zoom: ->
    controller = @controller
    models = controller.el.data('current').models
    record = models.record
    
    return unless controller.list
    activeEl = controller.list.findModelElement(record)
    $('.zoom', activeEl).click()
        
  back: (e) ->
    @controller.list?.back(e) or @controller.back?(e)
  
  prev: (e) ->
    history.back()
    e.preventDefault()
    e.stopPropagation()
  
  keydown: (e) ->
    code = e.charCode or e.keyCode
    
    el=$(document.activeElement)
    isFormfield = $().isFormElement(el)
    @controller.focus() unless isFormfield
    
    @log 'keydown' + code
    
    switch code
      when 13 #Return
        unless isFormfield
          @zoom(e)
          e.stopPropagation()
          e.preventDefault()
      when 27 #Esc
        unless isFormfield
          @back(e)
          e.preventDefault()
      when 37 #Left
        unless isFormfield
          @selectByKey('left', e)
          e.preventDefault()
      when 38 #Up
        unless isFormfield
          @selectByKey('up', e)
          e.preventDefault()
      when 39 #Right
        unless isFormfield
          @selectByKey('right', e)
          e.preventDefault()
      when 40 #Down
        unless isFormfield
          @selectByKey('down', e)
          e.preventDefault()
      
  keyup: (e) ->
    e.preventDefault()
    code = e.charCode or e.keyCode
    
    el=$(document.activeElement)
    isFormfield = $().isFormElement(el)
    
    @log 'keyup', code
    
    switch code
      when 8 #Backspace
        unless isFormfield
          @destroySelected(e)
          e.preventDefault()
      when 32 #Space
        unless isFormfield
          @slideshowView.play()
      when 27 #Esc
        @slideshowView.onclosedGallery()
      when 65 #CTRL A
        unless isFormfield
          if e.metaKey or e.ctrlKey
            @selectAll(e)
      when 73 #CTRL I
        unless isFormfield
          if e.metaKey or e.ctrlKey
            @selectInv(e)
      when 67 #CTRL C
        unless isFormfield
          if e.metaKey or e.ctrlKey
            @copy(e)
      when 86 #CTRL V
        unless isFormfield
          if e.metaKey or e.ctrlKey
            @paste(e)
      when 88 #CTRL X
        unless isFormfield
          if e.metaKey or e.ctrlKey
            @cut(e)
      when 82 #CTRL R
        unless isFormfield
          if e.metaKey or e.ctrlKey
            Spine.trigger('rotate', false, -90)

module?.exports = ShowView