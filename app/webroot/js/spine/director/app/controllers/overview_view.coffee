Spine   = require("spine")
$       = Spine.$
Recent  = require('models/recent')
Photo   = require('models/photo')
Settings= require('models/settings')
Extender= require("plugins/controller_extender")

require("plugins/tmpl")

class OverviewView extends Spine.Controller

  @extend Extender

  elements:
    '#overview-carousel'            : 'carousel'
    '.carousel-inner'               : 'content'
    '.recents .carousel-item'       : 'items'
    '.recents .item'                : 'item'
    '.summary'                      : 'summary'
    
  events:
    'click button.close'  : 'close'
    'click .item'         : 'showPhoto'
    'keyup'               : 'keyup'

  template: (photos) ->
    $("#overviewTemplate").tmpl
      photos: photos
      summary:
        galleries: Gallery.all()
        albums: Album.all()
        photos: Photo.all()

  toolsTemplate: (items) ->
    $("#toolsTemplate").tmpl items
    
  constructor: ->
    super
    @bind('active', @proxy @active)
#    @carousel.on('slide.bs.carousel', @proxy @focus)
    @el.data current: Recent
    @max = 18
    @bind('render:toolbar', @proxy @renderToolbar)
    
    Recent.bind('refresh', @proxy @render)
    
  active: ->
    @loadRecent()
    
  loadRecent: ->
    Recent.loadRecent(@max, @proxy @parse)
    
  parse: (json) ->
    recents = []
    for item in json
      recents.push item['Photo']
    Recent.refresh(recents, {clear:true})
    
  render: (tests) ->
    #validate fresh records against existing model collection
    items = []
    for test in tests
      items.push photo if photo = Photo.find(test.id)
      
    @content.html @template items
    @refreshElements()
    @uri items
    
#    @carousel.carousel @options
    
  thumbSize: (width = 70, height = 70) ->
    width: width
    height: height
    
  uri: (items) ->
    try
      Photo.uri @thumbSize(),
        (xhr, records) => @callback(xhr, items),
        items
    catch e
      @log e
      alert "New photos found. \n\nRestarting Application!"
      User.redirect 'director_app'
  
  callback: (json, items) =>
    @log 'callback'
    searchJSON = (id) ->
      for itm in json
        return itm[id] if itm[id]
        
    for item in items
      photo = item
      jsn = searchJSON photo.id
      photoEl = @items.children().forItem(photo)
      img = new Image
      img.element = photoEl
      if jsn
        img.src = jsn.src
      else
        img.src = '/img/nophoto.png'
      img.onload = @imageLoad
      
  imageLoad: ->
    css = 'url(' + @src + ')'
    $('.thumbnail', @element).css
      'backgroundImage': css
      'backgroundPosition': 'center, center'
    
  showPhoto: (e) ->
    index = @item.index($(e.currentTarget))
    @slideshow.trigger('play'
      index:index
      startSlideshow: false
      , Recent.all())
    e.preventDefault()
    e.stopPropagation()
  
  error: (xhr, statusText, error) ->
    @log xhr
    @record.trigger('ajaxError', xhr, statusText, error)
    
  close: (e) ->
    e.preventDefault()
    e.stopPropagation()
    
    if previousHash = Settings.findUserSettings().previousHash
      location.hash = previousHash
    else
      @navigate '/galleries/'
      
  keyup: (e) ->
    e.preventDefault()
    code = e.charCode or e.keyCode
    
    @log 'keyup', code
    
    @carousel.data('bs.carousel') || @carousel.carousel(keyboard:true)
    
    switch code
      when 27 #Esc
        @navigate '/galleries', ''
      when 32 #Space
        paused = @carousel.data('bs.carousel').paused
        if paused
          @carousel.carousel('next')
          @carousel.carousel('cycle')
        else
          @carousel.carousel('pause')
      when 39 #Right
        @carousel.carousel('next')
      when 37 #Left
        @carousel.carousel('prev')

module?.exports = OverviewView