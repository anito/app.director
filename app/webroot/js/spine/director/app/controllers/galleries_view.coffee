Spine         = require("spine")
$             = Spine.$
Drag          = require("extensions/drag")
Root          = require('models/root')
Gallery       = require('models/gallery')
GalleriesAlbum  = require('models/galleries_album')
GalleriesList = require("controllers/galleries_list")
AlbumsPhoto   = require('models/albums_photo')
Extender      = require('extensions/controller_extender')

class GalleriesView extends Spine.Controller
  
  @extend Drag
  @extend Extender
  
  elements:
    '.items'                  : 'items'
    
  events:
    'click .item'             : 'click'
    
  headerTemplate: (items) ->
    $("#headerGalleryTemplate").tmpl(items)

  template: (items) ->
    $("#galleriesTemplate").tmpl(items)

  constructor: ->
    super
    @bind('active', @proxy @active)
    @el.data('current',
      model: Root
      models: Gallery
    )
    @type = 'Gallery'
    @list = new GalleriesList
      el: @items
      template: @template
      parent: @
    @header.template = @headerTemplate
    @viewport = @list.el
    Gallery.one('refresh', @proxy @render)
    
    Gallery.bind('beforeDestroy', @proxy @beforeDestroy)
    Gallery.bind('destroy', @proxy @destroy)
#    Gallery.bind('refresh:gallery', @proxy @render)
#    Gallery.bind('create', @proxy @renderOne)

  render: (items) ->
    return unless @isActive()
    if Gallery.count()
      items = Gallery.records.sort Gallery.nameSort
      @list.render items
    else  
      @list.el.html '<label class="invite"><span class="enlightened">This Application has no galleries. &nbsp;<button class="opt-CreateGallery dark large">New Gallery</button>'
          
  renderOne: (gallery) ->
    @render [gallery]
          
  active: ->
    return unless @isActive()
    App.showView.trigger('change:toolbarOne', ['Default'])
    App.showView.trigger('change:toolbarTwo', ['Slideshow'])
    @render()
    
  click: (e, excl) ->
    e.preventDefault()
    e.stopPropagation()
    
    item = $(e.currentTarget).item()
    
    @select(e, item.id)
    
  select: (e, ids = []) ->
    ids = [ids] unless Array.isArray ids
    
    Root.updateSelection(ids)
    Gallery.updateSelection(Gallery.selectionList())
    
  beforeDestroy: (item) ->
    @list.findModelElement(item).detach()

  destroy: (item) ->
    if item
      Gallery.current() if Gallery.record?.id is item?.id
      item.removeSelectionID()
      Root.updateSelection []
      
    unless Gallery.count()
      #force to rerender
      if /^#\/galleries\//.test(location.hash)
        @navigate '/galleries', $().uuid()
    else
      unless /^#\/galleries\//.test(location.hash)
        @navigate '/gallery', Gallery.first().id
  
module?.exports = GalleriesView