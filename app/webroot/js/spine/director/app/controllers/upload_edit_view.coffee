Spine     = require("spine")
$         = Spine.$
Album     = require("models/album")
Settings  = require("models/settings")

class UploadEditView extends Spine.Controller

  elements:
    '.delete:not(.files .delete)' : 'clearEl'
    '.files'                      : 'filesEl'
    '.uploadinfo'                 : 'uploadinfoEl'

  events:
    'fileuploaddone'              : 'done'
    'fileuploadsubmit'            : 'submit'
    'fileuploadfail'              : 'fail'
    'fileuploaddrop'              : 'drop'
    'fileuploadadd'               : 'add'
    'fileuploadpaste'             : 'paste'
    'fileuploadsend'              : 'send'
    'fileuploadprogressall'       : 'alldone'
    'fileuploadprogress'          : 'progress'
    'fileuploaddestroyed'         : 'destroyed'
    
  template: (item) ->
    $('#template-upload').tmpl item
    
  constructor: ->
    super
    @bind('active', @proxy @active)
    Album.bind('change:current', @proxy @changeDataLink)
    @data = fileslist: [link: false]
    @queue = []
    
  changeDataLink: (album) ->
    @data.link = album?.id
    
  change: (item) ->
    @render()
    
  active: ->
    
  render: ->
    selection = Gallery.selectionList()
    gallery = Gallery.record
    @album = Album.find(selection[0]) || false
    @uploadinfoEl.html @template
      gallery: gallery
      album: @album
    @refreshElements()
    @el
    
  destroyed: ->
    
  fail: (xhr, textStatus, errorThrown) ->
    album = Album.find(@data.link)
    Spine.trigger('loading:fail', album, textStatus, errorThrown)
      
  drop: (e, data) ->

  add: (e, data) ->
    @data.fileslist.push file for file in data.files
    
    @trigger('active')
    if !Settings.isAutoUpload()
      App.showView.openView()
      
    @clearEl.click()
        
  notify: ->
    App.modal2ButtonView.show
      header: 'No Album selected'
      body: 'Please select an album .'
      info: ''
      button_1_text: 'Hallo'
      button_2_text: 'Bye'
        
  send: (e, data) ->
    album = Album.find(@data.link)
    Spine.trigger('loading:start', album)
    
  alldone: (e, data) ->
    
  done: (e, data) ->
    album = Album.find(@data.link)
    raws = $.parseJSON(data.jqXHR.responseText)
    console.log raws
    selection = []
    photos = []
    photos.push new Photo(raw['Photo']).save(ajax: false) for raw in raws
    
    
    for photo in photos
      selection.addRemoveSelection photo.id
      
    if album
      options = $().extend {},
        photos: selection
        album: album
        
      Photo.trigger('create:join', options)
    else
      Photo.trigger('created', photos)
      @navigate '/gallery', '', ''
      
    Spine.trigger('loading:done', album)
    Album.updateSelection(selection)
    
    e.preventDefault()
    
  progress: (e, data) ->
    
  paste: (e, data) ->
    @log 'paste'
    @drop(e, data)
    
  submit: (e, data) ->
    
  changedSelected: (album) ->
    album = Album.find(album.id)
    if @data.fileslist.length
      $.extend @data, link: Album.record?.id
        
module?.exports = UploadEditView