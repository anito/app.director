Spine           = require("spine")
$               = Spine.$
Root            = require("models/root")
Album           = require('models/album')
Gallery         = require('models/gallery')
AlbumsPhoto     = require('models/albums_photo')
GalleriesAlbum  = require('models/galleries_album')
Drag            = require("extensions/drag")
Extender        = require('extensions/controller_extender')

require("extensions/tmpl")

class SidebarList extends Spine.Controller

  @extend Drag
  @extend Extender
  
  elements:
    '.gal.item'               : 'item'

  events:
    "click      .item"            : 'click'
    "click      .expander"        : 'clickExpander'

  selectFirst: true
    
  contentTemplate: (items) ->
    $('#sidebarContentTemplate').tmpl(items)
    
  sublistTemplate: (items) ->
    $('#albumsSublistTemplate').tmpl(items)
    
  ctaTemplate: (item) ->
    $('#ctaTemplate').tmpl(item)
    
  constructor: ->
    super
    
#    @trace = false
    Gallery.bind('change:collection', @proxy @renderGallery)
    GalleriesAlbum.bind('update', @proxy @renderFromGalleriesAlbum)
    Album.bind('change:collection', @proxy @renderAlbum)
    Gallery.bind('change', @proxy @change)
    Album.bind('create destroy update', @proxy @renderSublists)
    Gallery.bind('change:selection', @proxy @exposeSublistSelection)
    Gallery.bind('current', @proxy @exposeSelection)
    Album.bind('current', @proxy @scrollTo)
    Gallery.bind('current', @proxy @scrollTo)
    
  template: -> arguments[0]
  
  change: (item, mode, e) =>
    @log 'change'
    
    switch mode
      when 'create'
        @current = item
        @create item
        @exposeSelection item
      when 'update'
        @current = item
        @update item
      when 'destroy'
        @current = false
        @destroy item
          
  create: (item) ->
    @append @template item
#    @closeAllOtherSublists item
    @reorder item
  
  update: (item) ->
    @updateTemplate item
    @reorder item
  
  destroy: (item) ->
    @children().forItem(item, true).detach()
  
  render: (items, mode) ->
    @log 'render'
    @children().addClass('invalid')
    for item in items
      galleryEl = @children().forItem(item)
      unless galleryEl.length
        @append @template item
        @reorder item
      else
        @updateTemplate(item).removeClass('invalid')
      @renderOneSublist item
    @children('.invalid').remove()
    
  reorder: (item) ->
    @log 'reorder'
    id = item.id
    index = (id, list) ->
      for itm, i in list
        return i if itm.id is id
      i
    
    children = @children()
    oldEl = @children().forItem(item)
    idxBeforeSort =  @children().index(oldEl)
    idxAfterSort = index(id, Gallery.all().sort(Gallery.nameSort))
    newEl = $(children[idxAfterSort])
    if idxBeforeSort < idxAfterSort
      newEl.after oldEl
    else if idxBeforeSort > idxAfterSort
      newEl.before oldEl
    
  updateSublist: (ga) ->
    gallery = Gallery.find ga.gallery_id
    @renderOneSublist gallery
    
  renderAllSublist: ->
    @log 'renderAllSublist'
    for gal, index in Gallery.records
      @renderOneSublist gal
      
  renderSublists: (album) ->
    @log 'renderSublists'
    gas = GalleriesAlbum.filter(album.id, key: 'album_id')
    for ga in gas
      @renderOneSublist gallery if gallery = Gallery.find ga['gallery_id']
      
  renderFromGalleriesAlbum: (ga) ->
    @log 'renderFromGalleriesAlbum'
    @renderOneSublist gallery if gallery = Gallery.find ga['gallery_id']
      
  renderOneSublist: (gallery = Gallery.record) ->
    @log 'renderOneSublist'
    filterOptions =
      model: 'Gallery'
      key:'gallery_id'
      sorted: 'sortByOrder'
      
    albums = Album.filterRelated(gallery.id, filterOptions)
    for album in albums
      album.count = AlbumsPhoto.filter(album.id, key: 'album_id').length
      album.ignore = !(GalleriesAlbum.isActiveAlbum(gallery.id, album.id))
      
    albums.push {flash: ' '} unless albums.length
    galleryEl = @children().forItem(gallery)
    gallerySublist = $('ul', galleryEl)
    gallerySublist.html @sublistTemplate(albums)
    gallerySublist.sortable('album')
    @exposeSublistSelection(null, gallery.id)
    
  updateTemplate: (item) ->
    @log 'updateTemplate'
    galleryEl = @children().forItem(item)
    galleryContentEl = $('.item-content', galleryEl)
    tmplItem = galleryContentEl.tmplItem()
    tmplItem.tmpl = $( "#sidebarContentTemplate" ).template()
    try
      tmplItem.update()
    catch e
    galleryEl
    
  renderItemFromGalleriesAlbum: (ga, mode) ->
    gallery = Gallery.find(ga.gallery_id)
    if gallery
      @updateTemplate gallery
      @renderOneSublist gallery
    
  renderGallery: (item) ->
    @updateTemplate item
    @renderOneSublist item
    
  renderAlbum: (item) ->
    gas = GalleriesAlbum.filter(item.id, key: 'album_id')
    for ga in gas
      if gallery = Gallery.find ga.gallery_id
        @renderGallery gallery
    
  renderItemFromAlbumsPhoto: (ap) ->
    @log 'renderItemFromAlbumsPhoto'
    gas = GalleriesAlbum.filter(ap.album_id, key: 'album_id')
    for ga in gas
      @renderItemFromGalleriesAlbum ga
  
  exposeSelection: (item = Gallery.record) ->
    @children().removeClass('active')
    @children().forItem(item).addClass("active") if item
    @expand item, true
    @exposeSublistSelection null, item?.id
    
  exposeSublistSelection: (selection = Gallery.selectionList(), id=Gallery.record?.id) ->
    @log 'exposeSublistSelection'
    item = Gallery.find id
    if item
      galleryEl = @children().forItem(item)
      albumsEl = galleryEl.find('li')
      albumsEl.removeClass('selected active')
      $('.glyphicon', galleryEl).removeClass('glyphicon-folder-open')
      
      for sel in item.selectionList()
        if album = Album.find(sel)
          albumsEl.forItem(album).addClass('selected')

      if activeAlbum = Album.find item.selectionList().first()
        activeEl = albumsEl.forItem(activeAlbum).addClass('active')
        $('.glyphicon', activeEl).addClass('glyphicon-folder-open')
        
    @refreshElements()

  click: (e) ->
    el = $(e.target).closest('li')
    item = el.item()
    
    switch item.constructor.className
      when 'Gallery'
        @expand(item, !(Gallery.record?.id is item.id) or !@isOpen(el))
        @navigate '/gallery', item.id
#        @closeAllOtherSublists item
      when 'Album'
        gallery = $(e.target).closest('li.gal').item()
        @navigate '/gallery', gallery.id, item.id
    
  clickExpander: (e) ->
    galleryEl = $(e.target).closest('li.gal')
    isOpen = galleryEl.hasClass('open')
    unless isOpen
      galleryEl.addClass('manual')
    else
      galleryEl.removeClass('manual')
      
    item = galleryEl.item()
    if item
      @expand(item, !isOpen, e)
    
    e.stopPropagation()
    e.preventDefault()
    
  expand: (item, open, e) ->
    galleryEl = @galleryFromItem(item)
    expander = $('.expander', galleryEl)
    if e
      targetIsExpander = $(e.currentTarget).hasClass('expander')
    
    if open
      @openSublist(galleryEl)
    else
      @closeSublist(galleryEl) unless galleryEl.hasClass('manual')
        
  isOpen: (el) ->
    el.hasClass('open')
    
  openSublist: (el) ->
    el.addClass('open')
    
  closeSublist: (el) ->
    el.removeClass('open manual')
    
  closeAllSublists_: (item) ->
    for gallery in Gallery.all()
      parentEl = @galleryFromItem gallery
      unless parentEl.hasClass('manual')
        @expand gallery, item?.id is gallery.id
  
  closeAllSublists: ->
    for gallery in Gallery.all()
      @expand gallery
  
  closeAllOtherSublists: (item) ->
    for gallery in Gallery.all()
      @expand gallery, item?.id is gallery.id
  
  galleryFromItem: (item) ->
    @children().forItem(item)

  close: () ->
    
  show: (e) ->
    App.contentManager.change App.showView
    e.stopPropagation()
    e.preventDefault()
    
  scrollTo: (item) ->
    return unless item and Gallery.record
    el = @children().forItem(Gallery.record)
    clsName = item.constructor.className
    switch clsName
      when 'Gallery'
        queued = true
        ul = $('ul', el)
        # messuring galleryEl w/o sublist
        ul.hide()
        el_ = el[0]
        ohc = el_.offsetHeight if el_
        ul.show()
        speed = 300
      when 'Album'
        queued = false
        ul = $('ul', el)
        el = $('li', ul).forItem(item)
        el_ = el[0]
        ohc = el_.offsetHeight if el_
        speed = 700
      
    return unless el.length
      
    otc = el.offset().top
    stp = @el[0].scrollTop
    otp = @el.offset().top
    ohp = @el[0].offsetHeight  
    
    resMin = stp+otc-otp
    resMax = stp+otc-(otp+ohp-ohc)
    
    outOfRange = stp > resMin or stp < resMax
    
    return unless outOfRange
    
    outOfMinRange = stp > resMin
    outOfMaxRange = stp < resMax
    
    res = if outOfMinRange then resMin else if outOfMaxRange then resMax
    
    @el.animate scrollTop: res,
      queue: queued
      duration: speed
      complete: =>
    
module?.exports = SidebarList