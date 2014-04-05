Spine             = require("spine")
$                 = Spine.$
Model             = Spine.Model
Gallery           = require('models/gallery')
Photo             = require('models/photo')
GalleriesAlbum    = require('models/galleries_album')
AlbumsPhoto       = require('models/albums_photo')
Filter            = require("plugins/filter")
Extender          = require("plugins/model_extender")
AjaxRelations     = require("plugins/ajax_relations")
Uri               = require("plugins/uri")
require("plugins/cache")
require("spine/lib/ajax")


class Album extends Spine.Model

  @configure "Album", 'id', 'title', 'description', 'count', 'user_id', 'invalid', 'active'

  @extend Model.Cache
  @extend Model.Ajax
  @extend Uri
  @extend AjaxRelations
  @extend Filter
  @extend Extender

  @selectAttributes: ['title']
  
  @parent: 'Gallery'
  
  @previousID: false

  @url: '' + base_url + @className.toLowerCase() + 's'

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
      key:'album_id'
      joinTable: 'AlbumsPhoto'
      sorted: true
    ret = Photo.filterRelated(id, filterOptions)
    ret[0...max || ret.length]
    ret
    
  @inactive: ->
    @findAllByAttribute('active', false)
    
  @createJoin: (items, target) ->
    unless @isArray items
      items = [items]

    return unless items.length
    
    for item in items
      ga = new GalleriesAlbum
        gallery_id  : target.id
        album_id    : item
        order       : GalleriesAlbum.albums(target.id).length
      ga.save()
      
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
      
  init: (instance) ->
    return unless id = instance.id
    s = new Object()
    s[id] = []
    @constructor.selection.push s
    
  selChange: (list) ->
  
  createJoin: (target) ->
    return unless target
    @constructor.createJoin [@id], target
  
  destroyJoin: (target) ->
    filterOptions =
      key:'gallery_id'
      joinTable: 'GalleriesAlbum'
      sorted: true
      
    gas = GalleriesAlbum.filter(target.id, filterOptions)
    
    for ga in gas
      if ga.album_id is @id
        target.removeSelection(ga.album_id)
        ga.destroy()
  
  count: (inc = 0) =>
    @constructor.contains(@id).length + inc
  
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
      return true if record.album_id is @id and (@['order'] = record.order)?
      
  selectAlbum: (id) ->
    return true if @id is id
    false
      
module?.exports = Model.Album = Album

