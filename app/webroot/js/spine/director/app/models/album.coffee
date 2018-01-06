Spine             = require("spine")
$                 = Spine.$
Model             = Spine.Model
Model.Gallery     = require('models/gallery')
GalleriesAlbum    = require('models/galleries_album')
AlbumsPhoto       = require('models/albums_photo')
Clipboard         = require('models/clipboard')
Filter            = require("extensions/filter")
Extender          = require("extensions/model_extender")
AjaxRelations     = require("extensions/ajax_relations")
Uri               = require("extensions/uri")

require("extensions/cache")
require("spine/lib/ajax")


class Album extends Spine.Model

  @configure "Album", 'id', 'title', 'description', 'count', 'user_id', 'invalid', 'active', 'selected'

  @extend Model.Cache
  @extend Model.Ajax
  @extend Uri
  @extend AjaxRelations
  @extend Filter
  @extend Extender

  @selectAttributes: ['title']
  
  @parent: 'Gallery'
  
  @childType = 'Photo'
  
  @previousID: false

  @url: '' + base_url + @className.toLowerCase() + 's'

  @fromJSON: (objects) ->
    super
    @createJoinTables objects
    key = @className
    json = @make(objects, key) #if Array.isArray(objects)# and objects[key]#test for READ or PUT !
    json

  @nameSort: (a, b) ->
    aa = (a or '').title?.toLowerCase()
    bb = (b or '').title?.toLowerCase()
    return if aa == bb then 0 else if aa < bb then -1 else 1

  @foreignModels: ->
    'Gallery':
      className             : 'Gallery'
      joinTable             : 'GalleriesAlbum'
      foreignKey            : 'album_id'
      associationForeignKey : 'gallery_id'
    'Photo':
      className             : 'Photo'
      joinTable             : 'AlbumsPhoto'
      foreignKey            : 'album_id'
      associationForeignKey : 'photo_id'
    
  @contains: (id=@record.id) ->
    return Photo.all() unless id
    @photos id
    
  @photos: (id, max) ->
    filterOptions =
      model: 'Album'
      key:'album_id'
      sorted: 'sortByOrder'
    ret = Photo.filterRelated(id, filterOptions)
    ret[0...max || ret.length]
    ret
    
  @activePhotos: ->
    if id = @record.id
      return @photos(id)
    return @contains()
    
  @inactive: ->
    @findAllByAttribute('active', false)
    
  @createJoin: (items=[], target, callback) ->
    @log 'createJoin'
    unless Array.isArray items
      items = [items]
    
    return unless items.length and target
    isValid = true
    cb = ->
      Gallery.trigger('change:collection', target)
      if typeof callback is 'function'
        callback.call(@)
    
    ids = items.toID()
    ret = for id in ids
      ga = new GalleriesAlbum
        id          : $().uuid()
        gallery_id  : target.id
        album_id    : id
        ignore      : false
        order_id    : parseInt(GalleriesAlbum.albums(target.id).last()?.order_id)+1 or 0
      valid = ga.save
        validate: true
        ajax: false
      isValid = valid unless valid
      
    if isValid
      target.save(done: cb)
    else
      Spine.trigger('refresh:all')
    ret
    
  @destroyJoin: (ids=[], target, cb) ->
    ids = [ids] unless Array.isArray ids
    
    return unless ids.length and target
    
    for id in ids
      gas = GalleriesAlbum.filter(id, key: 'album_id')
      ga = GalleriesAlbum.galleryAlbumExists(id, target.id)
      ga.destroy(done: cb) if ga
      
    Gallery.trigger('change:collection', target)
      
  @throwWarning: ->
  
  @gallerySelectionList: ->
    if Gallery.record and Album.record
      albumId = Gallery.selectionList()[0]
      return Album.selectionList(albumId)
    else# if Gallery.record and Gallery.selectionList().length
      return []
      
  @details: =>
    return @record.details() if @record
    $().extend @defaultDetails,
      iCount : Photo.count()
      sCount : Album.selectionList().length
      
  @findEmpties: ->
    ret = []
    @each (item) ->
      ret.push item unless item.photos().length
    ret
      
  init: (instance) ->
    return unless id = instance.id
    s = new Object()
    s[id] = []
    @constructor.selection.push s
    
  parent: -> @constructor.parent
    
  selChange: (list) ->
  
  createJoin: (target) ->
    @constructor.createJoin [@id], target
  
  destroyJoin: (target) ->
    @constructor.destroyJoin [@id], target
        
  count: (inc = 0) =>
    @constructor.contains(@id).length + inc
  
  contains: ->
    @constructor.contains @id
  
  photos: (max) ->
    @constructor.photos @id, max
  
  details: =>
    $().extend @defaultDetails,
      iCount : @photos().length
      sCount : Album.selectionList().length
      album  : Album.record
      gallery: Gallery.record
    
  selectAttributes: ->
    result = {}
    result[attr] = @[attr] for attr in @constructor.selectAttributes
    result
  
  # loops over each record and make sure to set the copy property
  select: (joinTableItems) ->
    for record in joinTableItems
      return true if record.album_id is @id and (@['order_id'] = record.order_id)?
      
  select_: (joinTableItems) ->
    return true if @id in joinTableItems
      
  selectAlbum: (id) ->
    return true if @id is id
      
module?.exports = Model.Album = Album

