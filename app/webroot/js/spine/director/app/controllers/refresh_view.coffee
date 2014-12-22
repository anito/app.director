Spine = require("spine")
$     = Spine.$
Gallery  = require('models/gallery')
Album  = require('models/album')
Photo  = require('models/photo')

class RefreshView extends Spine.Controller

  elements:
    'button'              : 'logoutEl'

  events:
    'click .opt-Refresh'        : 'refresh'
    
    
  template:  (icon = 'repeat') ->
    $('#refreshTemplate').tmpl icon: icon
    
  constructor: ->
    super
    
  refresh: ->
    @render 'cloud-download'
    Gallery.trigger('refresh:one')
    Album.trigger('refresh:one')
    Photo.trigger('refresh:one')
    @fetchAll()
    
  fetchAll: ->
    Photo.fetch(null, clear:true)
    Album.fetch(null, clear:true)
    Gallery.fetch(null, clear:true)
    
  render: (icon) ->
    @html @template icon

module?.exports = RefreshView