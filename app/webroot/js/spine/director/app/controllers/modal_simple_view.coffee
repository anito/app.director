Spine = require("spine")
$      = Spine.$

class ModalSimpleView extends Spine.Controller
  
  elements:
    '.modal-header'       : 'header'
    '.modal-body'         : 'body'
    '.modal-footer'       : 'footer'
  
  events:
    'click .opt-ShowAllAlbums'     : 'allAlbums'
    'click .btnClose'     : 'close'
    'hidden.bs.modal'     : 'hiddenmodal'
    'show.bs.modal'       : 'showmodal'
    'shown.bs.modal'      : 'shownmodal'
    'keydown'             : 'keydown'
  
  template: (item) ->
    $('#modalSimpleTemplate').tmpl(item)
    
  constructor: ->
    super
    @el = $('#modal-view')
    
    modalDefaults =
      keyboard: true
      show: false
      
    defaults =
      small: true
      body    : 'Default Body Text'
      
    @options = $.extend defaults, @options
    modals = $.extend modalDefaults, @modalOptions
    
    @render()
    
  allAlbums: ->
    @navigate '/gallery', ''
    
  hiddenmodal: ->
    @log 'hiddenmodal...'
  
  showmodal: ->
    @log 'showmodal...'
    
  shownmodal: ->
    @log 'shownmodal...'
    
  keydown: (e) ->
    @log 'keydown'
    
    code = e.charCode or e.keyCode
    @log code
        
    switch code
      when 32 # SPACE
        e.stopPropagation() 
      when 9 # TAB
        e.stopPropagation()
      when 27 # ESC
        e.stopPropagation()
      when 13 # RETURN
        @close()
        e.stopPropagation()
    
  render: (options = @options) ->
    @log 'render'
    @html @template options
    @refreshElements()
    @
      
  show: ->
    @el.modal('show')
    
  close: (e) ->
    @log 'close'
    @el.modal('hide')
    
module?.exports = ModalSimpleView