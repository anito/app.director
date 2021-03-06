Spine         = require("spine")
$             = Spine.$
Model         = Spine.Model
Filter        = require("extensions/filter")
Gallery       = require('models/gallery')
Album         = require('models/album')
Clipboard     = require("models/clipboard")
AlbumsPhoto   = require("models/albums_photo")
Extender      = require("extensions/model_extender")
AjaxRelations = require("extensions/ajax_relations")
Uri           = require("extensions/uri")
Dev           = require("extensions/dev")
Cache         = require("extensions/cache")
require("spine/lib/ajax")

class Photo extends Spine.Model
  @configure "Photo", 'id', 'title', "description", 'filesize', 'captured', 'exposure', "iso", 'longitude', 'aperture', 'software', 'model', 'user_id', 'active', 'src', 'selected'

  @extend Cache
  @extend Model.Ajax
  @extend Uri
  @extend Dev
  @extend AjaxRelations
  @extend Filter
  @extend Extender

  @selectAttributes: ['title', "description", 'user_id']
  
  @parent: 'Album'
  
  @foreignModels: ->
    'Album':
      className             : 'Album'
      joinTable             : 'AlbumsPhoto'
      foreignKey            : 'photo_id'
      associationForeignKey : 'album_id'

  @url: '' + base_url + @className.toLowerCase() + 's'

  @fromJSON: (objects) ->
    super
    @createJoinTables objects
    key = @className
    json = @make(objects, key) #if Array.isArray(objects)# and objects[key]#test for READ or PUT !
    json

  @nameSort: (a, b) ->
    aa = (a or '').name?.toLowerCase()
    bb = (b or '').name?.toLowerCase()
    return if aa == bb then 0 else if aa < bb then -1 else 1
  
  @defaults:
    width: 140
    height: 140
    square: 1
    quality: 70
  
  @success: (uri) =>
    @log 'success'
    Photo.trigger('uri', uri)
    
  @error: (json) =>
    Photo.trigger('ajaxError', json)
  
  @create: (atts) ->
    @__super__.constructor.create.call @, atts
  
  @refresh: (values, options = {}) ->
    @__super__.constructor.refresh.call @, values, options
    
  @trashed: ->
    res = []
    for item of @irecords
      res.push item unless AlbumsPhoto.find(item.id)
    res
    
  @inactive: ->
    @findAllByAttribute('active', false)
    
  @activePhotos: -> [ @record ]
    
  @createJoin: (ids=[], target, callback) ->
    ids = [ids] unless Array.isArray ids
      

    return unless ids.length
    isValid = true
    cb = ->
      Album.trigger('change:collection', target)
      if typeof callback is 'function'
        callback.call(@)
    
    ret = for id in ids
      ap = new AlbumsPhoto
        id          : $().uuid()
        album_id    : target.id
        photo_id    : id
        order_id    : parseInt(AlbumsPhoto.photos(target.id).last()?.order_id)+1 or 0
      valid = ap.save
        validate: true
        ajax: false
      isValid = valid unless valid
      
    if isValid
      target.save(done: cb)
    else
      Spine.trigger('refresh:all')
    ret
    
  @destroyJoin: (ids, target, cb) ->
    ids = [ids] unless Array.isArray ids
      
      
    return unless ids.length and target
    
    for id in ids
      aps = AlbumsPhoto.filter(id, key: 'photo_id')
      ap.destroy() if ap = AlbumsPhoto.albumPhotoExists(id, target.id)
      
    Album.trigger('change:collection', target)
      
  @albums: (id) ->
    filterOptions =
      model: 'Photo'
      key:'photo_id'
      sorted: 'sortByOrder'
    Album.filterRelated(id, filterOptions)
  
  init: (instance) ->
    return unless instance?.id
    @constructor.initCache instance.id
    
  parent: -> @constructor.parent
  
  createJoin: (target) ->
    @constructor.createJoin [@id], target
  
  destroyJoin: (target) ->
    @constructor.destroyJoin [@id], target
        
  albums: ->
    @constructor.albums @id
        
  selectAttributes: ->
    result = {}
    result[attr] = @[attr] for attr in @constructor.selectAttributes
    result

  select: (joinTableItems) ->
    for record in joinTableItems
      return true if record.photo_id is @id and (@['order_id'] = record.order_id)?
      
  select_: (joinTableItems) ->
    return true if @id in joinTableItems
      
  selectPhoto: (id) ->
    return true if @id is id
      
  details: =>
    gallery : Model.Gallery.record
    album   : Model.Album.record
    photo   : Model.Photo.record
    author  : User.first().name

module?.exports = Model.Photo = Photo
