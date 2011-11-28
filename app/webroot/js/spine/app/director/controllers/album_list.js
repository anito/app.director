var $, AlbumList;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
if (typeof Spine === "undefined" || Spine === null) {
  Spine = require("spine");
}
$ = Spine.$;
AlbumList = (function() {
  __extends(AlbumList, Spine.Controller);
  AlbumList.prototype.events = {
    'click .item': "click",
    'dblclick .item': 'dblclick'
  };
  AlbumList.prototype.selectFirst = true;
  function AlbumList() {
    this.callback = __bind(this.callback, this);    AlbumList.__super__.constructor.apply(this, arguments);
    Spine.bind('album:exposeSelection', this.proxy(this.exposeSelection));
  }
  AlbumList.prototype.template = function() {
    return arguments[0];
  };
  AlbumList.prototype.albumPhotosTemplate = function(items) {
    return $('#albumPhotosTemplate').tmpl(items);
  };
  AlbumList.prototype.change = function(items) {
    console.log('AlbumList::change');
    if (items.length) {
      return this.renderBackgrounds(items);
    }
  };
  AlbumList.prototype.select = function(item) {
    var previous, _ref;
    previous = this.current;
    this.current = item;
    this.exposeSelection();
    if (item && !item.destroyed) {
      Album.current(item);
    }
    if (((_ref = this.current) != null ? _ref.id : void 0) !== (previous != null ? previous.id : void 0)) {
      return Spine.trigger('change:selectedAlbum', item);
    }
  };
  AlbumList.prototype.exposeSelection = function() {
    var current, id, item, list, _i, _len;
    list = Gallery.selectionList();
    this.children().removeClass("active");
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      id = list[_i];
      if (Album.exists(id)) {
        item = Album.find(id);
        this.children().forItem(item).addClass("active");
      }
    }
    current = list.length === 1 ? list[0] : void 0;
    Album.current(current);
    if (Gallery.record) {
      return Spine.trigger('expose:sublistSelection', Gallery.record);
    }
  };
  AlbumList.prototype.render = function(items) {
    console.log('AlbumList::render');
    if (items.length) {
      this.html(this.template(items));
    } else {
      if (Album.count()) {
        this.html('<label class="invite"><span class="enlightened">This Gallery has no albums. &nbsp;</span></label><div class="invite"><button class="optCreateAlbum dark invite">New Album</button><button class="optShowAllAlbums dark invite">Show available Albums</button></div>');
      } else {
        this.html('<label class="invite"><span class="enlightened">Time to create a new album. &nbsp;</span></label><div class="invite"><button class="optCreateAlbum dark invite">New Album</button></div>');
      }
    }
    this.change(items);
    return this.el;
  };
  AlbumList.prototype.renderBackgrounds = function(albums) {
    var album, _i, _len, _results;
    console.log('AlbumList::renderBackgrounds');
    if (!App.ready) {
      return;
    }
    _results = [];
    for (_i = 0, _len = albums.length; _i < _len; _i++) {
      album = albums[_i];
      _results.push(album.uri({
        width: 50,
        height: 50
      }, 'html', __bind(function(xhr, album) {
        return this.callback(xhr, album);
      }, this), 3));
    }
    return _results;
  };
  AlbumList.prototype.callback = function(json, item) {
    var css, el, itm, o, searchJSON;
    console.log('AlbumList::callback');
    el = this.children().forItem(item);
    searchJSON = function(itm) {
      var key, res, value;
      return res = (function() {
        var _results;
        _results = [];
        for (key in itm) {
          value = itm[key];
          _results.push(value);
        }
        return _results;
      })();
    };
    css = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = json.length; _i < _len; _i++) {
        itm = json[_i];
        o = searchJSON(itm);
        _results.push('url(' + o[0].src + ')');
      }
      return _results;
    })();
    return el.css('backgroundImage', css);
  };
  AlbumList.prototype.create = function() {
    return Spine.trigger('create:album');
  };
  AlbumList.prototype.click = function(e) {
    var item;
    console.log('AlbumList::click');
    item = $(e.target).item();
    item.addRemoveSelection(Gallery, this.isCtrlClick(e));
    this.select(item);
    App.showView.trigger('change:toolbar', 'Album');
    e.stopPropagation();
    e.preventDefault();
    return false;
  };
  AlbumList.prototype.dblclick = function(e) {
    var item;
    item = $(e.currentTarget).item();
    Spine.trigger('show:photos', item);
    e.stopPropagation();
    e.preventDefault();
    return false;
  };
  AlbumList.prototype.edit = function(e) {
    var item;
    console.log('AlbumList::edit');
    item = $(e.target).item();
    return this.change(item);
  };
  return AlbumList;
})();
if (typeof module !== "undefined" && module !== null) {
  module.exports = AlbumList;
}