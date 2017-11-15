Spine         = require("spine")
$             = Spine.$
Model         = Spine.Model
Filter        = require("extensions/filter")
Model.Gallery = require('models/gallery')
Model.Album   = require('models/album')
Photo         = require('models/photo')
AlbumsPhoto   = require('models/albums_photo')
Extender      = require("extensions/extender_model")

require("spine/lib/ajax")


class GalleriesAlbum extends Spine.Model

  @configure "GalleriesAlbum", 'id', 'cid', 'gallery_id', 'album_id', 'order_id', 'ignore'

  @extend Model.Ajax
  @extend Filter
  @extend Extender

  @url: 'galleries_albums'
  
  @galleryAlbumExists: (aid, gid) ->
    gas = @filter 'placeholder',
      album_id: aid
      gallery_id: gid
      func: 'selectUnique'
    gas[0] or false
    
  @galleries: (aid) ->
    Gallery.filterRelated(aid,
      model: 'Album'
      key: 'album_id'
      sorted: 'sortByOrder'
    )
    
  @albums: (gid) ->
    Album.filterRelated(gid,
      model: 'Gallery'
      key: 'gallery_id'
      sorted: 'sortByOrder'
    )
      
  @activeAlbums: (gid) ->
    @filter(gid, {key: 'gallery_id', func: 'selectNotIgnored'})
      
  @inactiveAlbums: (gid) ->
    @filter(gid, {key: 'gallery_id', func: 'selectIgnored'})
      
  @photos: (id) ->
    ret = []
    unless id
      @each (item) =>
        photos = AlbumsPhoto.albumPhotos item.album_id
        ret.push photo for photo in photos
    else
      albums = @albums id
      for album in albums
        photos = AlbumsPhoto.albumPhotos album.id
        ret.push photo for photo in photos
    ret
      
  @isActiveAlbum: (gid, aid) ->
    gas = @filter(gid, {key: 'gallery_id', func: 'selectNotIgnored'})
    for ga in gas
      return !ga.ignore if ga.album_id is aid
    return false
      
  @c: 0
  
  validate: ->
    valid_1 = (Album.find @album_id) and (Gallery.find @gallery_id)
    valid_2 = !(ga = @constructor.galleryAlbumExists(@album_id, @gallery_id) and @isNew())
    return 'No valid action!' unless valid_1
    return 'Album already exists in Gallery' unless valid_2
    false
    
  galleries: ->
    @constructor.galleries @album_id
      
  albums: ->
    @constructor.albums @gallery_id
      
  isActiveAlbum: (aid) ->
    @constructor.isActiveAlbum @gallery_id, aid
      
  select: (id, options) ->
    return true if @[options.key] is id
    
  selectAlbum: (id, gid) ->
    return true if @album_id is id and @gallery_id is Gallery.record.id
    
  selectUnique: (empty, options) ->
    return true if @album_id is options.album_id and @gallery_id is options.gallery_id
    
  selectNotIgnored: (id) ->
    return true if @gallery_id is id and @ignore is false
    
  selectIgnored: (id) ->
    return true if @gallery_id is id and @ignore is true
    
module.exports = Model.GalleriesAlbum = GalleriesAlbum