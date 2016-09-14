Spine         = require("spine")
$             = Spine.$
Drag          = require("plugins/drag")
Root          = require('models/root')
Gallery       = require('models/gallery')
GalleriesAlbum  = require('models/galleries_album')
GalleriesList = require("controllers/galleries_list")
AlbumsPhoto   = require('models/albums_photo')
Extender      = require('plugins/controller_extender')

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
    Gallery.bind('refresh:gallery', @proxy @render)

  render: (items) ->
    return unless @isActive()
    if Gallery.count()
      items = Gallery.records.sort Gallery.nameSort
      @list.render items
    else  
      @list.el.html '<label class="invite"><span class="enlightened">This Application has no galleries. &nbsp;<button class="opt-CreateGallery dark large">New Gallery</button>'
          
  active: ->
    return unless @isActive()
    unless Gallery.record
      Gallery.updateSelection()
    App.showView.trigger('change:toolbarOne', ['Default'])
    App.showView.trigger('change:toolbarTwo', ['Slideshow'])
    @render()
    
  click: (e) ->
    e.preventDefault()
    e.stopPropagation()
    
    App.showView.trigger('change:toolbarOne', ['Default'])
    item = $(e.currentTarget).item()
    @select(e, item.id) #one gallery selected at a time
    
  select_: (item) ->
    Gallery.trigger('activate', item.id)
    
  select__: (ids = [], exclusive) ->
    unless Array.isArray ids
      ids = [ids]
    Root.emptySelection() if exclusive
      
    selection = Root.selectionList()[..]
    for id in ids
      selection.addRemoveSelection(id)
    
    Root.updateSelection(selection)
    Gallery.updateSelection(Gallery.selectionList())
    Album.updateSelection(Album.selectionList())
    
  select: (e, items = []) ->
    unless Array.isArray items
      items = [items]
      
    Root.updateSelection(items.first())
    Gallery.updateSelection(Gallery.selectionList())
    Album.updateSelection(Album.selectionList())
    
  beforeDestroy: (item) ->
    @list.findModelElement(item).detach()

  destroy: (item) ->
    if item
      Gallery.current() if Gallery.record?.id is item?.id
      item.removeSelectionID()
      Root.removeFromSelection item.id
      
    unless Gallery.count()
      #force to rerender
      if /^#\/galleries\//.test(location.hash)
        @navigate '/galleries'
      @navigate '/galleries', ''
    else
      unless /^#\/galleries\//.test(location.hash)
        @navigate '/gallery', Gallery.first().id
  
  newAttributes: ->
    if User.first()
      name   : 'New Name'
      user_id : User.first().id
      author: User.first().name
    else
      User.ping()
  
module?.exports = GalleriesView