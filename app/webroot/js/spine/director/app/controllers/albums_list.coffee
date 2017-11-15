Spine           = require("spine")
$               = Spine.$
Model           = Spine.Model
Gallery         = require('models/gallery')
Album           = require('models/album')
Photo           = require('models/photo')
AlbumsPhoto     = require('models/albums_photo')
GalleriesAlbum  = require('models/galleries_album')
Extender        = require("extensions/controller_extender")
Drag            = require("extensions/drag")

require("extensions/tmpl")

class AlbumsList extends Spine.Controller
  
  @extend Drag
  @extend Extender
  
  events:
    'click .dropdown-toggle'       : 'dropdownToggle'
    'click .opt-AddAlbums'         : 'addAlbums'
    'click .opt-delete'            : 'deleteAlbum'
    'click .opt-ignore'            : 'ignoreAlbum'
    'click .opt-original'          : 'original'
    'click .zoom'                  : 'zoom'
    
  constructor: ->
    super
    @widows = []
    @add = @html
    Album.bind('update', @proxy @updateTemplate)
    Album.bind("ajaxError", Album.errorHandler)
    GalleriesAlbum.bind('change', @proxy @changeRelated)
    Gallery.bind('change:selection', @proxy @exposeSelection)
    
  changedAlbums: (gallery) ->
    
  changeRelated: (item, mode) ->
    return unless @parent and @parent.isActive()
    return unless Gallery.record
    return unless Gallery.record.id is item['gallery_id']
    return unless album = Album.find(item['album_id'])
    @log 'changeRelated'
    
    switch mode
      when 'create'
        @wipe()
        @append @template @mixinAttributes([album], ['ignore'])
        @renderBackgrounds [album]
        @el.sortable('destroy').sortable()
#        $('.tooltips', @el).tooltip()
        $('.dropdown-toggle', @el).dropdown()
      when 'destroy'
        el = @findModelElement(album)
        el.detach()
        
      when 'update'
        @updateTemplate album
        @el.sortable('destroy').sortable()
    
    @refreshElements()
    @el
  
  mixinAttributes: (items, atts) ->
    for item in items
      ga = GalleriesAlbum.galleryAlbumExists(item.id, Gallery.record.id)
      for att in atts 
        item[att] = ga[att]
    items
    
  render: (items=[], mode) ->
    @log 'render', mode
        
    if items.length
      @wipe()
      items = @mixinAttributes(items, ['ignore']) unless @modal
      @[mode] @template items
      @renderBackgrounds items
      @exposeSelection()
      $('.dropdown-toggle', @el).dropdown()
    else if mode is 'add'
      @html '<label class="invite"><span class="enlightened">Nothing to add.  &nbsp;</span></label>'
      @append '<h3><label class="invite label label-default"><span class="enlightened">Either no more albums can be added or there is no gallery selected.</span></label></h3>'
    else
      if Gallery.record
        if Album.count()
          @html '<label class="invite"><span class="enlightened">This Gallery has no albums. &nbsp;</span><br><br>
          <button class="opt-CreateAlbum dark large"><i class="glyphicon glyphicon-asterisk"></i><span>New Album</span></button>
          <button class="opt-AddAlbums dark large"><span style="font-size: .6em; position: absolute; top: -18px;">import from</span><i class="glyphicon glyphicon-book"></i><span>Library</span></button>
          </label>'
        else
          @html '<label class="invite"><span class="enlightened">This Gallery has no albums.<br>It\'s time to create one.</span><br><br>
          <button class="opt-CreateAlbum dark large"><i class="glyphicon glyphicon-asterisk"></i><span>New Album</span></button>
          </label>'
      else
        @html '<label class="invite"><span class="enlightened">You don\'t have any albums yet</span><br><br>
        <button class="opt-CreateAlbum dark large"><i class="glyphicon glyphicon-asterisk"></i><span>New Album</span></button>
        </label>'
    
    @el
    
  updateTemplate: (album) ->
    albumEl = @children().forItem(album)
    contentEl = $('.thumbnail', albumEl)
    active = albumEl.hasClass('active')
    hot = albumEl.hasClass('hot')
    if Gallery.record
      ignore = GalleriesAlbum.galleryAlbumExists(album.id, Gallery.record.id)?.ignore
    else
      ignore = false
    style = contentEl.attr('style')
    tmplItem = contentEl.tmplItem()
    alert 'no tmpl item' unless tmplItem
    if tmplItem
      tmplItem.tmpl = $( "#albumsTemplate" ).template()
      tmplItem.update?()
      albumEl = @children().forItem(album)
      contentEl = $('.thumbnail', albumEl)
      albumEl.toggleClass('active', active)
      albumEl.toggleClass('hot', hot)
      albumEl.toggleClass('ignore', ignore)
      contentEl.attr('style', style)
    @el.sortable()
  
  exposeSelection: (selection=Gallery.selectionList(), id=Gallery.record?.id) ->
    if Gallery.record
      return unless Gallery.record.id is id
    @deselect()
    for sel in selection
      $('#'+sel, @el).addClass("active")
    if first = selection.first()
      $('#'+first, @el).addClass("hot")
      
  # workaround:
  # remember the Album since
  # after last AlbumPhoto is destroyed the Album container cannot be retrieved anymore
  widowedAlbumsPhoto: (ap) ->
    @log 'widowedAlbumsPhoto'
    list = ap.albums()
    @widows.push item for item in list
    @widows
  
  renderBackgrounds: (albums) ->
    @log 'renderBackgrounds'
    albums = [albums] unless Album.isArray(albums)
    @removeWidows @widows
    for album in albums
      $.when(@processAlbumDeferred(album)).done (xhr, rec) =>
        @callback xhr, rec
        
  removeWidows: (widows=[]) ->
    Model.Uri.Ajax.cache = false
    for widow in widows
      $.when(@processAlbumDeferred(widow)).done (xhr, rec) =>
        @callback xhr, rec
    @widows = []
    Model.Uri.Ajax.cache = true
  
  processAlbum: (album) ->
    data = album.photos(4)
  
    Photo.uri
      width: 50
      height: 50,
      (xhr, rec) => @callback(xhr, album)
      data
  
  processAlbumDeferred: (album) ->
    @log 'processAlbumDeferred'
    deferred = $.Deferred()
    data = album.photos(4)
    
    Photo.uri
      width: 50
      height: 50,
      (xhr, rec) -> deferred.resolve(xhr, album)
      data
      
    deferred.promise()
      
  callback: (json, album) ->
    el = $('#'+album.id, @el)
    thumb = $('.thumbnail', el)
    
    res = for jsn in json
      ret = for key, val of jsn
        val.src
      ret[0]
    
    
    sources = []
    css = []
    for jsn in json
      for key, val of jsn
        sources.push src if src = val.src
        css.push 'url('+src+')'
    
    if sources.length
      @snap thumb, src, css for src in sources
    else
      thumb.css('backgroundImage', ['url(/img/drag_info.png)'])
      
  snap: (el, src, css) ->
    img = @createImage()
    img.el = el
    img.me = @
    img.css = css
    img.src = src
    img.onload = @onLoad
    img.onerror = @onError
    
      
  onLoad: ->
      console.log 'image loaded'
      @el.css('backgroundImage', @css)
    
  onError: (e) ->
    console.log 'could not load image, trying again'
    @onload = this.onload
    @src =  '/img/drag_info.png' #could be any existing image
      
  original: (e) ->
    id = $(e.currentTarget).item().id
    Gallery.selection[0].global.update [id]
    @navigate '/gallery', ''
    
    e.preventDefault()
    e.stopPropagation()
      
  zoom: (e) ->
    item = $(e.currentTarget).item()

    @parent.stopInfo()
    @navigate '/gallery', (Gallery.record?.id or ''), item.id
    
    e.preventDefault()
    e.stopPropagation()
    
  back: (e) ->
    @navigate '/galleries', ''
    
    e.preventDefault()
    e.stopPropagation()
    
  dropdownToggle: (e) ->
    el = $(e.currentTarget)
    el.dropdown()
    e.preventDefault()

  ignoreAlbum: (e) ->
    e.preventDefault()
    item = $(e.currentTarget).item()
    return unless item?.constructor?.className is 'Album'
    if ga = GalleriesAlbum.galleryAlbumExists(item.id, Gallery.record.id)
      GalleriesAlbum.trigger('ignore', ga, !ga.ignore)
    
  deleteAlbum: (e) ->
    @log 'deleteAlbum'
    item = $(e.currentTarget).item()
    return unless item?.constructor?.className is 'Album'
    
    Spine.trigger('destroy:album', [item.id])
    
    e.stopPropagation()
    e.preventDefault()
    
  addAlbums: (e) ->
    @log 'add'
#    e.stopPropagation()
#    e.preventDefault()
    
    Spine.trigger('albums:add')
    
  wipe: ->
    if Gallery.record
      first = Gallery.record.count() is 1
    else
      first = Album.count() is 1
    @el.empty() if first
    @el
    
module?.exports = AlbumsList