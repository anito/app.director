Spine         = require("spine")
$             = Spine.$
Album         = require('models/album')
AlbumsPhoto   = require('models/albums_photo')
PhotoList     = require('controllers/photo_list')
Info          = require('controllers/info')
Drag          = require("plugins/drag")
Extender      = require('plugins/controller_extender')

require("plugins/tmpl")

class PhotoView extends Spine.Controller
  
  @extend Drag
  @extend Extender
  
  elements:
    '.hoverinfo'       : 'infoEl'
    '.items'           : 'itemsEl'
    '.item'            : 'item'
  
  events:
    'mousemove  .item'                : 'infoUp'
    'mouseleave .item'                : 'infoBye'
    
    'dragstart  .item'                : 'stopInfo'
    'dragstart .item'                 : 'dragstart'
    'drop .item'                      : 'drop'
    
    'click .dropdown-toggle'          : 'dropdownToggle'
    'click .delete'                   : 'deletePhoto'
    'click .zoom'                     : 'zoom'
    'click .rotate'                   : 'rotate'
    
  template: (item) ->
    $('#photoTemplate').tmpl(item)
    
  infoTemplate: (item) ->
    $('#photoInfoTemplate').tmpl item
    
  constructor: ->
    super
    @currentId = 0
    @bind('active', @proxy @active)
    @el.data('current',
      model: Album
      models: Photo
    )
    @list = new PhotoList
      el: @itemsEl
      parent: @
    #listen to a different view
    @list.listener = @parent.photosView.list
    @type = 'Photo'
    @info = new Info
      el: @infoEl
      template: @infoTemplate
    @viewport = @itemsEl
    
    AlbumsPhoto.bind('beforeDestroy', @proxy @back)
    Photo.bind('beforeDestroy', @proxy @back)
    Photo.one('refresh', @proxy @refresh)
    Album.bind('change:collection', @proxy @refresh)
#    Album.bind("change:selection", @proxy @changeNavigation)
    Photo.bind('change:current', @proxy @changeNavigation)
    
  change: (a, b) ->
    changed = !(@currentId is b[0])
    if changed
      @log b[0]
      @currentId = b[0]
      @render Photo.find(b)
    
  changeNavigation: (rec, changed) ->
    return unless @isActive()
    @navigate '/gallery', Gallery.record?.id or '', Album.record?.id or '', rec.id if changed
    
  render: (item=Photo.record) ->
    return unless @isActive()
    @itemsEl.html @template item
    $('.dropdown-toggle', @el).dropdown()
    @uri item
    @el
  
  active: ->
    return unless @isActive()
    App.showView.trigger('change:toolbarOne', ['Default'])
    App.showView.trigger('change:toolbarTwo', ['Test'])
    @render()
    
  refresh: ->
    @render()
    
  params: ->
    width: 600
    height: 451
    square: 2
    force: false
    
  uri: (item, mode = 'html') ->
    @log 'uri'
    Photo.uri @params(),
      (xhr, record) => @callback(xhr, item),
      [item]
  
  callback: (json, item) =>
    @log 'callback'
    img = new Image
    img.onload = @imageLoad
    
    searchJSON = (id) ->
      for itm in json
        return itm[id] if itm[id]
        
#    for item in items
    jsn = searchJSON item.id
    if jsn
      img.tmb = $('.thumbnail', @el)
      img.container = @itemsEl.removeClass('in')
      img.src = jsn.src
  
  imageLoad: ->
    tmb = @tmb
    container = @container
    w = @width
    h = @height
    
    if h > w
      @height = '100%'
      @width = 'auto'
    
    img = $(@)
    tmb.html img
    container.addClass('in')
  
  dropdownToggle: (e) ->
    el = $(e.currentTarget)
    el.dropdown()
    e.preventDefault()
    e.stopPropagation()
  
  deletePhoto: (e) ->
    item = $(e.currentTarget).item()
    return unless item?.constructor?.className is 'Photo' 
    
    Spine.trigger('destroy:photo', [item.id], @proxy @back)
    
    @stopInfo(e)
    
    e.stopPropagation()
    e.preventDefault()
  
  rotate: (e) ->
    @photosView.list.rotate(e)
  
  back: ->
    @navigate '/gallery', Gallery.record.id, Album.record.id
  
  zoom: (e) ->
    @parent.slideshowView.trigger('play', {}, [Photo.record])
    
  infoUp: (e) =>
    @info.up(e)
    el = $('.glyphicon-set' , $(e.currentTarget)).addClass('in').removeClass('out')
    e.preventDefault()
    
  infoBye: (e) =>
    @info.bye()
    el = $('.glyphicon-set' , $(e.currentTarget)).addClass('out').removeClass('in')
    e.preventDefault()
    
  stopInfo: (e) =>
    @info.bye()
    
module?.exports = PhotoView