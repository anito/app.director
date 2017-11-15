Spine                 = require("spine")
$                     = Spine.$

GalleriesAlbum        = require('models/galleries_album')
AlbumsPhoto           = require('models/albums_photo')
Extender              = require("extensions/controller_extender")

class GalleriesHeader extends Spine.Controller
  
  @extend Extender
  
  constructor: ->
    super
    @bind('active', @proxy @active)
    Gallery.bind('change', @proxy @render)
    Gallery.bind('refresh', @proxy @render)
    Gallery.bind('change:current', @proxy @render)
    
    Album.bind('change', @proxy @render)
    Album.bind('change:collection', @proxy @render)
    
    Photo.bind('refresh', @proxy @render)

  render: ->
    return unless @isActive()
    @html @template
      model       : Gallery
      modelAlbum  : Album
      modelPhoto  : Photo
      modelGas    : GalleriesAlbum
      modelAps    : AlbumsPhoto
      author  : User.first().name
    
  count: ->
    Gallery.count()
    
  active: ->
    @render()
  
  goUp: (e) ->
    @navigate '/overview', ''
    e.preventDefault()
    e.stopPropagation()
    
module?.exports = GalleriesHeader