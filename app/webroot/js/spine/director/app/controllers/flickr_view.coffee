Spine           = require('spine')
$               = Spine.$
ToolbarView     = require("controllers/toolbar_view")
Settings        = require("models/settings")
Extender        = require("plugins/controller_extender")

class FlickrView extends Spine.Controller

  @extend Extender
  
  elements:
    '.links'      : 'links'
    '.content'    : 'content'
    '.toolbarOne' : 'toolbarOneEl'
    '.toolbarTwo' : 'toolbarTwoEl'
    
  events:
    'click button.close'  : 'close'
    'click .recent'       : 'navRecent'
    'click .inter'        : 'navInter'
    'click .links'        : 'click'
    'click .opt-Prev'     : 'prevPage'
    'click .opt-Next'     : 'nextPage'
    
  template: (items) ->
    $('#flickrTemplate').tmpl items
    
  toolsTemplate: (items) ->
    $("#toolsTemplate").tmpl items
    
  introTemplate: ->
    $('#flickrIntroTemplate').tmpl()
    
  constructor: ->
    super
    @bind('active', @proxy @active)
    @type = 'recent'
    @perpage = 100
    @spec = 
      recent:
        min     : 1
        page    : 1
        pages   : 5
        per_page: @perpage
      inter:
        min     : 1
        page    : 1
        pages   : 5
        per_page: @perpage
    @toolbar_one = new ToolbarView
      el: @toolbarOneEl
      template: @toolsTemplate
    @toolbar_two = new ToolbarView
      el: @toolbarTwoEl
      template: @toolsTemplate
      
    @bind('flickr:recent', @proxy @recent)
    @bind('flickr:inter', @proxy @interestingness)
      
  render: (items) ->
    @log 'render'
    if items
      @content.html @template items
    else
      @content.html @introTemplate()
      @toolbarOneEl.empty()
    
    @changeToolbar @toolbar_two, ['Close']
    
  active: ->
    if arguments.length
      @setup(arguments[0], arguments[1])
    else @render()
    
  url: ->
    protocol = if window.location.protocol is 'https:'
      'https://secure'
    else
      'http://api'
    protocol = 'https://secure'
    protocol + '.flickr.com/services/rest/'
                
  data:
    format  : 'json',
    method  : 'flickr.activity.userPhotos',
    api_key : '1cb992dd2b14ba97327aea602e3922e6'
    
  setup: (mode, page) ->
    @log 'setup'
    @type = mode
    switch mode
      when 'recent'
        toolsList_one = ['FlickrRecent']
        toolsList_two = ['Close']
        options =
          page  : page || @spec[mode].page
          method: 'flickr.photos.getRecent'
        @changeToolbar @toolbar_one, toolsList_one
      when 'inter'
        toolsList_one = ['FlickrInter']
        toolsList_two = ['Close']
        options =
          page  : page || @spec[mode].page
          method: 'flickr.interestingness.getList'
        @changeToolbar @toolbar_one, toolsList_one
      else
        return @render()
    options = $().extend @spec[mode], options
    @ajax(options)
    
  ajax: (options) ->
    @log 'ajax'
    data = $().extend @data, options
    $.ajax(
      url: @url()
      data: data
      dataType: 'jsonp',
      jsonp: 'jsoncallback'
    )
    .done(@doneResponse)
    .fail(@failResponse)
    
  doneResponse: (result) =>
    # update our own spec object with flickrs response
    @updateSpecs result
    @render result.photos.photo
    
  failResponse: (args...) ->
    @log args
    
  changeToolbar: (tb, list) ->
    tb.change list
    @refreshElements()
    
  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    
    target = $(e.target).parent()[0]
    options = index: target
    links = $('a', @links)
    blueimp.Gallery(links, options)
    
  prevPage: (e) ->
    e.stopPropagation()
    e.preventDefault()
    type = @type
    @spec[type].page = if (t = ((@spec[type].page || 1)-1)) >= 1 then t else 1
    @navigate '/flickr', type, @spec[type].page
  
  nextPage: (e) ->
    e.stopPropagation()
    e.preventDefault()
    type = @type
    @spec[type].page = if (t = ((@spec[type].page || 1)+1)) <= @spec[type].pages then t else @spec[type].pages
    @navigate '/flickr', type, @spec[type].page
    
  details: (type) ->
    page = (Number) @spec[type].page
    perpage = (Number) @spec[type].per_page
    from: ((page-1) * perpage) + 1
    to: ((page-1) * perpage) + perpage
    
  updateSpecs: (res) ->
    type = @type
    $().extend @spec[type], res.photos
    # prevent flickr from choking on nested objects
    delete @spec[type].photo

  recent: (page) ->
    @setup('recent', page)
    
  interestingness: (page) ->
    @setup('inter', page)
    
  navRecent: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @navigate '/flickr', 'recent/1'
    
  navInter: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @navigate '/flickr', 'inter/1'
    
  close: (e) ->
    e.preventDefault()
    e.stopPropagation()
    
    if previousHash = Settings.findUserSettings().previousHash
      location.hash = previousHash
    else
      @navigate '/galleries/'
    
module.exports = FlickrView