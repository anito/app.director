!function(e){if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.jade=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

/**
 * Merge two attribute objects giving precedence
 * to values in object `b`. Classes are special-cased
 * allowing for arrays and merging/joining appropriately
 * resulting in a string.
 *
 * @param {Object} a
 * @param {Object} b
 * @return {Object} a
 * @api private
 */

exports.merge = function merge(a, b) {
  if (arguments.length === 1) {
    var attrs = a[0];
    for (var i = 1; i < a.length; i++) {
      attrs = merge(attrs, a[i]);
    }
    return attrs;
  }
  var ac = a['class'];
  var bc = b['class'];

  if (ac || bc) {
    ac = ac || [];
    bc = bc || [];
    if (!Array.isArray(ac)) ac = [ac];
    if (!Array.isArray(bc)) bc = [bc];
    a['class'] = ac.concat(bc).filter(nulls);
  }

  for (var key in b) {
    if (key != 'class') {
      a[key] = b[key];
    }
  }

  return a;
};

/**
 * Filter null `val`s.
 *
 * @param {*} val
 * @return {Boolean}
 * @api private
 */

function nulls(val) {
  return val != null && val !== '';
}

/**
 * join array as classes.
 *
 * @param {*} val
 * @return {String}
 */
exports.joinClasses = joinClasses;
function joinClasses(val) {
  return Array.isArray(val) ? val.map(joinClasses).filter(nulls).join(' ') : val;
}

/**
 * Render the given classes.
 *
 * @param {Array} classes
 * @param {Array.<Boolean>} escaped
 * @return {String}
 */
exports.cls = function cls(classes, escaped) {
  var buf = [];
  for (var i = 0; i < classes.length; i++) {
    if (escaped && escaped[i]) {
      buf.push(exports.escape(joinClasses([classes[i]])));
    } else {
      buf.push(joinClasses(classes[i]));
    }
  }
  var text = joinClasses(buf);
  if (text.length) {
    return ' class="' + text + '"';
  } else {
    return '';
  }
};

/**
 * Render the given attribute.
 *
 * @param {String} key
 * @param {String} val
 * @param {Boolean} escaped
 * @param {Boolean} terse
 * @return {String}
 */
exports.attr = function attr(key, val, escaped, terse) {
  if ('boolean' == typeof val || null == val) {
    if (val) {
      return ' ' + (terse ? key : key + '="' + key + '"');
    } else {
      return '';
    }
  } else if (0 == key.indexOf('data') && 'string' != typeof val) {
    return ' ' + key + "='" + JSON.stringify(val).replace(/'/g, '&apos;') + "'";
  } else if (escaped) {
    return ' ' + key + '="' + exports.escape(val) + '"';
  } else {
    return ' ' + key + '="' + val + '"';
  }
};

/**
 * Render the given attributes object.
 *
 * @param {Object} obj
 * @param {Object} escaped
 * @return {String}
 */
exports.attrs = function attrs(obj, terse){
  var buf = [];

  var keys = Object.keys(obj);

  if (keys.length) {
    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i]
        , val = obj[key];

      if ('class' == key) {
        if (val = joinClasses(val)) {
          buf.push(' ' + key + '="' + val + '"');
        }
      } else {
        buf.push(exports.attr(key, val, false, terse));
      }
    }
  }

  return buf.join('');
};

/**
 * Escape the given string of `html`.
 *
 * @param {String} html
 * @return {String}
 * @api private
 */

exports.escape = function escape(html){
  var result = String(html)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
  if (result === '' + html) return html;
  else return result;
};

/**
 * Re-throw the given `err` in context to the
 * the jade in `filename` at the given `lineno`.
 *
 * @param {Error} err
 * @param {String} filename
 * @param {String} lineno
 * @api private
 */

exports.rethrow = function rethrow(err, filename, lineno, str){
  if (!(err instanceof Error)) throw err;
  if ((typeof window != 'undefined' || !filename) && !str) {
    err.message += ' on line ' + lineno;
    throw err;
  }
  try {
    str =  str || require('fs').readFileSync(filename, 'utf8')
  } catch (ex) {
    rethrow(err, null, lineno)
  }
  var context = 3
    , lines = str.split('\n')
    , start = Math.max(lineno - context, 0)
    , end = Math.min(lines.length, lineno + context);

  // Error context
  var context = lines.slice(start, end).map(function(line, i){
    var curr = i + start + 1;
    return (curr == lineno ? '  > ' : '    ')
      + curr
      + '| '
      + line;
  }).join('\n');

  // Alter exception message
  err.path = filename;
  err.message = (filename || 'Jade') + ':' + lineno
    + '\n' + context + '\n\n' + err.message;
  throw err;
};

},{"fs":2}],2:[function(require,module,exports){

},{}]},{},[1])
(1)
});


(function(/*! Stitch !*/) {
  if (!this.require) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath]
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.require = function(name) {
      return require(name, '');
    }
    this.require.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.require.modules = modules;
    this.require.cache   = cache;
  }
  return this.require.define;
}).call(this)({
  "spine/index": function(exports, require, module) {module.exports = require('./lib/spine');}, "spine/lib/spine": function(exports, require, module) {// Generated by CoffeeScript 1.8.0

/*
Spine.js MVC library
Released under the MIT License
 */

(function() {
  var $, Controller, Events, Log, Model, Module, Spine, createObject, isArray, isBlank, makeArray, moduleKeywords,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Events = {
    bind: function(ev, callback) {
      var evs, name, _base, _i, _len;
      evs = ev.split(' ');
      if (!this.hasOwnProperty('_callbacks')) {
        this._callbacks || (this._callbacks = {});
      }
      for (_i = 0, _len = evs.length; _i < _len; _i++) {
        name = evs[_i];
        (_base = this._callbacks)[name] || (_base[name] = []);
        this._callbacks[name].push(callback);
      }
      return this;
    },
    one: function(ev, callback) {
      var handler;
      return this.bind(ev, handler = function() {
        this.unbind(ev, handler);
        return callback.apply(this, arguments);
      });
    },
    trigger: function() {
      var args, callback, ev, list, _i, _len, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ev = args.shift();
      list = (_ref = this._callbacks) != null ? _ref[ev] : void 0;
      if (!list) {
        return;
      }
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        callback = list[_i];
        if (callback.apply(this, args) === false) {
          break;
        }
      }
      return true;
    },
    listenTo: function(obj, ev, callback) {
      obj.bind(ev, callback);
      this.listeningTo || (this.listeningTo = []);
      this.listeningTo.push({
        obj: obj,
        ev: ev,
        callback: callback
      });
      return this;
    },
    listenToOnce: function(obj, ev, callback) {
      var handler, listeningToOnce;
      listeningToOnce = this.listeningToOnce || (this.listeningToOnce = []);
      obj.bind(ev, handler = function() {
        var i, idx, lt, _i, _len;
        idx = -1;
        for (i = _i = 0, _len = listeningToOnce.length; _i < _len; i = ++_i) {
          lt = listeningToOnce[i];
          if (lt.obj === obj) {
            if (lt.ev === ev && lt.callback === handler) {
              idx = i;
            }
          }
        }
        obj.unbind(ev, handler);
        if (idx !== -1) {
          listeningToOnce.splice(idx, 1);
        }
        return callback.apply(this, arguments);
      });
      listeningToOnce.push({
        obj: obj,
        ev: ev,
        callback: handler
      });
      return this;
    },
    stopListening: function(obj, events, callback) {
      var e, ev, evts, idx, listeningTo, lt, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _ref, _ref1, _ref2;
      if (arguments.length === 0) {
        _ref = [this.listeningTo, this.listeningToOnce];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listeningTo = _ref[_i];
          if (!listeningTo) {
            continue;
          }
          for (_j = 0, _len1 = listeningTo.length; _j < _len1; _j++) {
            lt = listeningTo[_j];
            lt.obj.unbind(lt.ev, lt.callback);
          }
        }
        this.listeningTo = void 0;
        this.listeningToOnce = void 0;
      } else if (obj) {
        _ref1 = [this.listeningTo, this.listeningToOnce];
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          listeningTo = _ref1[_k];
          if (!listeningTo) {
            continue;
          }
          events = events ? events.split(' ') : [void 0];
          for (_l = 0, _len3 = events.length; _l < _len3; _l++) {
            ev = events[_l];
            for (idx = _m = _ref2 = listeningTo.length - 1; _ref2 <= 0 ? _m <= 0 : _m >= 0; idx = _ref2 <= 0 ? ++_m : --_m) {
              lt = listeningTo[idx];
              if (lt.obj !== obj) {
                continue;
              }
              if (callback && lt.callback !== callback) {
                continue;
              }
              if ((!ev) || (ev === lt.ev)) {
                lt.obj.unbind(lt.ev, lt.callback);
                if (idx !== -1) {
                  listeningTo.splice(idx, 1);
                }
              } else if (ev) {
                evts = lt.ev.split(' ');
                if (__indexOf.call(evts, ev) >= 0) {
                  evts = (function() {
                    var _len4, _n, _results;
                    _results = [];
                    for (_n = 0, _len4 = evts.length; _n < _len4; _n++) {
                      e = evts[_n];
                      if (e !== ev) {
                        _results.push(e);
                      }
                    }
                    return _results;
                  })();
                  lt.ev = $.trim(evts.join(' '));
                  lt.obj.unbind(ev, lt.callback);
                }
              }
            }
          }
        }
      }
      return this;
    },
    unbind: function(ev, callback) {
      var cb, evs, i, list, name, _i, _j, _len, _len1, _ref;
      if (arguments.length === 0) {
        this._callbacks = {};
        return this;
      }
      if (!ev) {
        return this;
      }
      evs = ev.split(' ');
      for (_i = 0, _len = evs.length; _i < _len; _i++) {
        name = evs[_i];
        list = (_ref = this._callbacks) != null ? _ref[name] : void 0;
        if (!list) {
          continue;
        }
        if (!callback) {
          delete this._callbacks[name];
          continue;
        }
        for (i = _j = 0, _len1 = list.length; _j < _len1; i = ++_j) {
          cb = list[i];
          if (!(cb === callback)) {
            continue;
          }
          list = list.slice();
          list.splice(i, 1);
          this._callbacks[name] = list;
          break;
        }
      }
      return this;
    }
  };

  Events.on = Events.bind;

  Events.off = Events.unbind;

  Log = {
    trace: true,
    logPrefix: '(App)',
    log: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (!this.trace) {
        return;
      }
      if (this.logPrefix) {
        args.unshift(this.logPrefix);
      }
      if (typeof console !== "undefined" && console !== null) {
        if (typeof console.log === "function") {
          console.log.apply(console, args);
        }
      }
      return this;
    }
  };

  moduleKeywords = ['included', 'extended'];

  Module = (function() {
    Module.include = function(obj) {
      var key, value, _ref;
      if (!obj) {
        throw new Error('include(obj) requires obj');
      }
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this.prototype[key] = value;
        }
      }
      if ((_ref = obj.included) != null) {
        _ref.apply(this);
      }
      return this;
    };

    Module.extend = function(obj) {
      var key, value, _ref;
      if (!obj) {
        throw new Error('extend(obj) requires obj');
      }
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this[key] = value;
        }
      }
      if ((_ref = obj.extended) != null) {
        _ref.apply(this);
      }
      return this;
    };

    Module.proxy = function(func) {
      return (function(_this) {
        return function() {
          return func.apply(_this, arguments);
        };
      })(this);
    };

    Module.prototype.proxy = function(func) {
      return (function(_this) {
        return function() {
          return func.apply(_this, arguments);
        };
      })(this);
    };

    function Module() {
      if (typeof this.init === "function") {
        this.init.apply(this, arguments);
      }
    }

    return Module;

  })();

  Model = (function(_super) {
    __extends(Model, _super);

    Model.extend(Events);

    Model.include(Events);

    Model.records = [];

    Model.irecords = {};

    Model.attributes = [];

    Model.configure = function() {
      var attributes, name;
      name = arguments[0], attributes = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.className = name;
      this.deleteAll();
      if (attributes.length) {
        this.attributes = attributes;
      }
      this.attributes && (this.attributes = makeArray(this.attributes));
      this.attributes || (this.attributes = []);
      this.unbind();
      return this;
    };

    Model.toString = function() {
      return "" + this.className + "(" + (this.attributes.join(", ")) + ")";
    };

    Model.find = function(id, notFound) {
      var _ref;
      if (notFound == null) {
        notFound = this.notFound;
      }
      return ((_ref = this.irecords[id]) != null ? _ref.clone() : void 0) || (typeof notFound === "function" ? notFound(id) : void 0);
    };

    Model.findAll = function(ids, notFound) {
      var id, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = ids.length; _i < _len; _i++) {
        id = ids[_i];
        if (this.find(id, notFound)) {
          _results.push(this.find(id));
        }
      }
      return _results;
    };

    Model.notFound = function(id) {
      return null;
    };

    Model.exists = function(id) {
      return Boolean(this.irecords[id]);
    };

    Model.addRecord = function(record) {
      var root;
      if (root = this.irecords[record.id || record.cid]) {
        root.refresh(record);
      } else {
        record.id || (record.id = record.cid);
        this.irecords[record.id] = this.irecords[record.cid] = record;
        this.records.push(record);
      }
      return record;
    };

    Model.refresh = function(values, options) {
      var record, records, result, _i, _len;
      if (options == null) {
        options = {};
      }
      if (options.clear) {
        this.deleteAll();
      }
      records = this.fromJSON(values);
      if (!isArray(records)) {
        records = [records];
      }
      for (_i = 0, _len = records.length; _i < _len; _i++) {
        record = records[_i];
        this.addRecord(record);
      }
      this.sort();
      result = this.cloneArray(records);
      this.trigger('refresh', result, options);
      return result;
    };

    Model.select = function(callback) {
      var record, _i, _len, _ref, _results;
      _ref = this.records;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        record = _ref[_i];
        if (callback(record)) {
          _results.push(record.clone());
        }
      }
      return _results;
    };

    Model.findByAttribute = function(name, value) {
      var record, _i, _len, _ref;
      _ref = this.records;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        record = _ref[_i];
        if (record[name] === value) {
          return record.clone();
        }
      }
      return null;
    };

    Model.findAllByAttribute = function(name, value) {
      return this.select(function(item) {
        return item[name] === value;
      });
    };

    Model.each = function(callback) {
      var record, _i, _len, _ref, _results;
      _ref = this.records;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        record = _ref[_i];
        _results.push(callback(record.clone()));
      }
      return _results;
    };

    Model.all = function() {
      return this.cloneArray(this.records);
    };

    Model.slice = function(begin, end) {
      if (begin == null) {
        begin = 0;
      }
      return this.cloneArray(this.records.slice(begin, end));
    };

    Model.first = function(end) {
      var _ref;
      if (end == null) {
        end = 1;
      }
      if (end > 1) {
        return this.cloneArray(this.records.slice(0, end));
      } else {
        return (_ref = this.records[0]) != null ? _ref.clone() : void 0;
      }
    };

    Model.last = function(begin) {
      var _ref;
      if (typeof begin === 'number') {
        return this.cloneArray(this.records.slice(-begin));
      } else {
        return (_ref = this.records[this.records.length - 1]) != null ? _ref.clone() : void 0;
      }
    };

    Model.count = function() {
      return this.records.length;
    };

    Model.deleteAll = function() {
      this.records = [];
      return this.irecords = {};
    };

    Model.destroyAll = function(options) {
      var record, _i, _len, _ref, _results;
      _ref = this.records;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        record = _ref[_i];
        _results.push(record.destroy(options));
      }
      return _results;
    };

    Model.update = function(id, atts, options) {
      return this.find(id).updateAttributes(atts, options);
    };

    Model.create = function(atts, options) {
      var record;
      record = new this(atts);
      return record.save(options);
    };

    Model.destroy = function(id, options) {
      return this.find(id).destroy(options);
    };

    Model.change = function(callbackOrParams) {
      if (typeof callbackOrParams === 'function') {
        return this.bind('change', callbackOrParams);
      } else {
        return this.trigger.apply(this, ['change'].concat(__slice.call(arguments)));
      }
    };

    Model.fetch = function(callbackOrParams) {
      if (typeof callbackOrParams === 'function') {
        return this.bind('fetch', callbackOrParams);
      } else {
        return this.trigger.apply(this, ['fetch'].concat(__slice.call(arguments)));
      }
    };

    Model.toJSON = function() {
      return this.records;
    };

    Model.beforeFromJSON = function(objects) {
      return objects;
    };

    Model.fromJSON = function(objects) {
      var value, _i, _len, _results;
      if (!objects) {
        return;
      }
      if (typeof objects === 'string') {
        objects = JSON.parse(objects);
      }
      objects = this.beforeFromJSON(objects);
      if (isArray(objects)) {
        _results = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          value = objects[_i];
          if (value instanceof this) {
            _results.push(value);
          } else {
            _results.push(new this(value));
          }
        }
        return _results;
      } else {
        if (objects instanceof this) {
          return objects;
        }
        return new this(objects);
      }
    };

    Model.fromForm = function() {
      var _ref;
      return (_ref = new this).fromForm.apply(_ref, arguments);
    };

    Model.sort = function() {
      if (this.comparator) {
        this.records.sort(this.comparator);
      }
      return this;
    };

    Model.cloneArray = function(array) {
      var value, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        value = array[_i];
        _results.push(value.clone());
      }
      return _results;
    };

    Model.idCounter = 0;

    Model.uid = function(prefix) {
      var uid;
      if (prefix == null) {
        prefix = '';
      }
      uid = prefix + this.idCounter++;
      if (this.exists(uid)) {
        uid = this.uid(prefix);
      }
      return uid;
    };

    function Model(atts) {
      Model.__super__.constructor.apply(this, arguments);
      if ((this.constructor.uuid != null) && typeof this.constructor.uuid === 'function') {
        this.cid = this.constructor.uuid();
        if (!this.id) {
          this.id = this.cid;
        }
      } else {
        this.cid = (atts != null ? atts.cid : void 0) || this.constructor.uid('c-');
      }
      if (atts) {
        this.load(atts);
      }
    }

    Model.prototype.isNew = function() {
      return !this.exists();
    };

    Model.prototype.isValid = function() {
      return !this.validate();
    };

    Model.prototype.validate = function() {};

    Model.prototype.load = function(atts) {
      var key, value;
      if (atts.id) {
        this.id = atts.id;
      }
      for (key in atts) {
        value = atts[key];
        if (typeof this[key] === 'function') {
          if (typeof value === 'function') {
            continue;
          }
          this[key](value);
        } else {
          this[key] = value;
        }
      }
      return this;
    };

    Model.prototype.attributes = function() {
      var key, result, _i, _len, _ref;
      result = {};
      _ref = this.constructor.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        if (key in this) {
          if (typeof this[key] === 'function') {
            result[key] = this[key]();
          } else {
            result[key] = this[key];
          }
        }
      }
      if (this.id) {
        result.id = this.id;
      }
      return result;
    };

    Model.prototype.eql = function(rec) {
      return rec && rec.constructor === this.constructor && ((rec.cid === this.cid) || (rec.id && rec.id === this.id));
    };

    Model.prototype.save = function(options) {
      var error, record;
      if (options == null) {
        options = {};
      }
      if (options.validate !== false) {
        error = this.validate();
        if (error) {
          this.trigger('error', this, error);
          return false;
        }
      }
      this.trigger('beforeSave', this, options);
      record = this.isNew() ? this.create(options) : this.update(options);
      this.stripCloneAttrs();
      this.trigger('save', record, options);
      return record;
    };

    Model.prototype.stripCloneAttrs = function() {
      var key, value;
      if (this.hasOwnProperty('cid')) {
        return;
      }
      for (key in this) {
        if (!__hasProp.call(this, key)) continue;
        value = this[key];
        if (__indexOf.call(this.constructor.attributes, key) >= 0) {
          delete this[key];
        }
      }
      return this;
    };

    Model.prototype.updateAttribute = function(name, value, options) {
      var atts;
      atts = {};
      atts[name] = value;
      return this.updateAttributes(atts, options);
    };

    Model.prototype.updateAttributes = function(atts, options) {
      this.load(atts);
      return this.save(options);
    };

    Model.prototype.changeID = function(id) {
      var records;
      if (id === this.id) {
        return;
      }
      records = this.constructor.irecords;
      records[id] = records[this.id];
      if (this.cid !== this.id) {
        delete records[this.id];
      }
      this.id = id;
      return this.save();
    };

    Model.prototype.remove = function(options) {
      var i, record, records, _i, _len;
      if (options == null) {
        options = {};
      }
      records = this.constructor.records.slice(0);
      for (i = _i = 0, _len = records.length; _i < _len; i = ++_i) {
        record = records[i];
        if (!(this.eql(record))) {
          continue;
        }
        records.splice(i, 1);
        break;
      }
      this.constructor.records = records;
      if (options.clear) {
        delete this.constructor.irecords[this.id];
        return delete this.constructor.irecords[this.cid];
      }
    };

    Model.prototype.destroy = function(options) {
      if (options == null) {
        options = {};
      }
      if (options.clear == null) {
        options.clear = true;
      }
      this.trigger('beforeDestroy', this, options);
      this.remove(options);
      this.destroyed = true;
      this.trigger('destroy', this, options);
      this.trigger('change', this, 'destroy', options);
      if (this.listeningTo) {
        this.stopListening();
      }
      this.unbind();
      return this;
    };

    Model.prototype.dup = function(newRecord) {
      var atts, record;
      if (newRecord == null) {
        newRecord = true;
      }
      atts = this.attributes();
      if (newRecord) {
        delete atts.id;
      } else {
        atts.cid = this.cid;
      }
      record = new this.constructor(atts);
      if (!newRecord) {
        this._callbacks && (record._callbacks = this._callbacks);
      }
      return record;
    };

    Model.prototype.clone = function() {
      return createObject(this);
    };

    Model.prototype.reload = function() {
      var original;
      if (this.isNew()) {
        return this;
      }
      original = this.constructor.find(this.id);
      this.load(original.attributes());
      return original;
    };

    Model.prototype.refresh = function(atts) {
      atts = this.constructor.fromJSON(atts);
      if (atts.id && this.id !== atts.id) {
        this.changeID(atts.id);
      }
      this.constructor.irecords[this.id].load(atts);
      this.trigger('refresh', this);
      this.trigger('change', this, 'refresh');
      return this;
    };

    Model.prototype.toJSON = function() {
      return this.attributes();
    };

    Model.prototype.toString = function() {
      return "<" + this.constructor.className + " (" + (JSON.stringify(this)) + ")>";
    };

    Model.prototype.fromForm = function(form) {
      var checkbox, key, name, result, _i, _j, _k, _len, _len1, _len2, _name, _ref, _ref1, _ref2;
      result = {};
      _ref = $(form).find('[type=checkbox]:not([value])');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        checkbox = _ref[_i];
        result[checkbox.name] = $(checkbox).prop('checked');
      }
      _ref1 = $(form).find('[type=checkbox][name$="[]"]');
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        checkbox = _ref1[_j];
        name = checkbox.name.replace(/\[\]$/, '');
        result[name] || (result[name] = []);
        if ($(checkbox).prop('checked')) {
          result[name].push(checkbox.value);
        }
      }
      _ref2 = $(form).serializeArray();
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        key = _ref2[_k];
        result[_name = key.name] || (result[_name] = key.value);
      }
      return this.load(result);
    };

    Model.prototype.exists = function() {
      return this.constructor.exists(this.id);
    };

    Model.prototype.update = function(options) {
      var clone, records;
      this.trigger('beforeUpdate', this, options);
      records = this.constructor.irecords;
      records[this.id].load(this.attributes());
      this.constructor.sort();
      clone = records[this.id].clone();
      clone.trigger('update', clone, options);
      clone.trigger('change', clone, 'update', options);
      return clone;
    };

    Model.prototype.create = function(options) {
      var clone, record;
      this.trigger('beforeCreate', this, options);
      this.id || (this.id = this.cid);
      record = this.dup(false);
      this.constructor.addRecord(record);
      this.constructor.sort();
      clone = record.clone();
      clone.trigger('create', clone, options);
      clone.trigger('change', clone, 'create', options);
      return clone;
    };

    Model.prototype.bind = function() {
      var record;
      record = this.constructor.irecords[this.id] || this;
      return Events.bind.apply(record, arguments);
    };

    Model.prototype.one = function() {
      var record;
      record = this.constructor.irecords[this.id] || this;
      return Events.one.apply(record, arguments);
    };

    Model.prototype.unbind = function() {
      var record;
      record = this.constructor.irecords[this.id] || this;
      return Events.unbind.apply(record, arguments);
    };

    Model.prototype.trigger = function() {
      var _ref;
      Events.trigger.apply(this, arguments);
      if (arguments[0] === 'refresh') {
        return true;
      }
      return (_ref = this.constructor).trigger.apply(_ref, arguments);
    };

    return Model;

  })(Module);

  Model.prototype.on = Model.prototype.bind;

  Model.prototype.off = Model.prototype.unbind;

  Controller = (function(_super) {
    __extends(Controller, _super);

    Controller.include(Events);

    Controller.include(Log);

    Controller.prototype.eventSplitter = /^(\S+)\s*(.*)$/;

    Controller.prototype.tag = 'div';

    function Controller(options) {
      this.release = __bind(this.release, this);
      var context, key, parent_prototype, value, _ref;
      this.options = options;
      _ref = this.options;
      for (key in _ref) {
        value = _ref[key];
        this[key] = value;
      }
      if (!this.el) {
        this.el = document.createElement(this.tag);
      }
      this.el = $(this.el);
      if (this.className) {
        this.el.addClass(this.className);
      }
      if (this.attributes) {
        this.el.attr(this.attributes);
      }
      if (!this.events) {
        this.events = this.constructor.events;
      }
      if (!this.elements) {
        this.elements = this.constructor.elements;
      }
      context = this;
      while (parent_prototype = context.constructor.__super__) {
        if (parent_prototype.events) {
          this.events = $.extend({}, parent_prototype.events, this.events);
        }
        if (parent_prototype.elements) {
          this.elements = $.extend({}, parent_prototype.elements, this.elements);
        }
        context = parent_prototype;
      }
      if (this.events) {
        this.delegateEvents(this.events);
      }
      if (this.elements) {
        this.refreshElements();
      }
      Controller.__super__.constructor.apply(this, arguments);
    }

    Controller.prototype.release = function() {
      this.trigger('release', this);
      this.el.remove();
      this.unbind();
      return this.stopListening();
    };

    Controller.prototype.$ = function(selector) {
      return this.el.find(selector);
    };

    Controller.prototype.delegateEvents = function(events) {
      var eventName, key, match, method, selector, _results;
      _results = [];
      for (key in events) {
        method = events[key];
        if (typeof method === 'function') {
          method = (function(_this) {
            return function(method) {
              return function() {
                method.apply(_this, arguments);
                return true;
              };
            };
          })(this)(method);
        } else {
          if (!this[method]) {
            throw new Error("" + method + " doesn't exist");
          }
          method = (function(_this) {
            return function(method) {
              return function() {
                _this[method].apply(_this, arguments);
                return true;
              };
            };
          })(this)(method);
        }
        match = key.match(this.eventSplitter);
        eventName = match[1];
        selector = match[2];
        if (selector === '') {
          _results.push(this.el.bind(eventName, method));
        } else {
          _results.push(this.el.on(eventName, selector, method));
        }
      }
      return _results;
    };

    Controller.prototype.refreshElements = function() {
      var key, value, _ref, _results;
      _ref = this.elements;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this[value] = this.$(key));
      }
      return _results;
    };

    Controller.prototype.delay = function(func, timeout) {
      return setTimeout(this.proxy(func), timeout || 0);
    };

    Controller.prototype.html = function(element) {
      this.el.html(element.el || element);
      this.refreshElements();
      return this.el;
    };

    Controller.prototype.append = function() {
      var e, elements, _ref;
      elements = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      elements = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          e = elements[_i];
          _results.push(e.el || e);
        }
        return _results;
      })();
      (_ref = this.el).append.apply(_ref, elements);
      this.refreshElements();
      return this.el;
    };

    Controller.prototype.appendTo = function(element) {
      this.el.appendTo(element.el || element);
      this.refreshElements();
      return this.el;
    };

    Controller.prototype.prepend = function() {
      var e, elements, _ref;
      elements = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      elements = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          e = elements[_i];
          _results.push(e.el || e);
        }
        return _results;
      })();
      (_ref = this.el).prepend.apply(_ref, elements);
      this.refreshElements();
      return this.el;
    };

    Controller.prototype.replace = function(element) {
      var previous, _ref, _ref1;
      element = element.el || element;
      if (typeof element === "string") {
        element = $.trim(element);
      }
      _ref1 = [this.el, $(((_ref = $.parseHTML(element)) != null ? _ref[0] : void 0) || element)], previous = _ref1[0], this.el = _ref1[1];
      previous.replaceWith(this.el);
      this.delegateEvents(this.events);
      this.refreshElements();
      return this.el;
    };

    return Controller;

  })(Module);

  $ = (typeof window !== "undefined" && window !== null ? window.jQuery : void 0) || (typeof window !== "undefined" && window !== null ? window.Zepto : void 0) || function(element) {
    return element;
  };

  createObject = Object.create || function(o) {
    var Func;
    Func = function() {};
    Func.prototype = o;
    return new Func();
  };

  isArray = function(value) {
    return Object.prototype.toString.call(value) === '[object Array]';
  };

  isBlank = function(value) {
    var key;
    if (!value) {
      return true;
    }
    for (key in value) {
      return false;
    }
    return true;
  };

  makeArray = function(args) {
    return Array.prototype.slice.call(args, 0);
  };

  Spine = this.Spine = {};

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine;
  }

  Spine.version = '1.4.1';

  Spine.isArray = isArray;

  Spine.isBlank = isBlank;

  Spine.$ = $;

  Spine.Events = Events;

  Spine.Log = Log;

  Spine.Module = Module;

  Spine.Controller = Controller;

  Spine.Model = Model;

  Module.extend.call(Spine, Events);

  Module.create = Module.sub = Controller.create = Controller.sub = Model.sub = function(instances, statics) {
    var Result;
    Result = (function(_super) {
      __extends(Result, _super);

      function Result() {
        return Result.__super__.constructor.apply(this, arguments);
      }

      return Result;

    })(this);
    if (instances) {
      Result.include(instances);
    }
    if (statics) {
      Result.extend(statics);
    }
    if (typeof Result.unbind === "function") {
      Result.unbind();
    }
    return Result;
  };

  Model.setup = function(name, attributes) {
    var Instance;
    if (attributes == null) {
      attributes = [];
    }
    Instance = (function(_super) {
      __extends(Instance, _super);

      function Instance() {
        return Instance.__super__.constructor.apply(this, arguments);
      }

      return Instance;

    })(this);
    Instance.configure.apply(Instance, [name].concat(__slice.call(attributes)));
    return Instance;
  };

  Spine.Class = Module;

}).call(this);

//# sourceMappingURL=spine.js.map
}, "spine/lib/local": function(exports, require, module) {// Generated by CoffeeScript 1.8.0
(function() {
  var Spine;

  Spine = this.Spine || require('spine');

  Spine.Model.Local = {
    extended: function() {
      this.change(this.saveLocal);
      return this.fetch(this.loadLocal);
    },
    saveLocal: function() {
      var result;
      result = JSON.stringify(this);
      return localStorage[this.className] = result;
    },
    loadLocal: function(options) {
      var result;
      if (options == null) {
        options = {};
      }
      if (!options.hasOwnProperty('clear')) {
        options.clear = true;
      }
      result = localStorage[this.className];
      return this.refresh(result || [], options);
    }
  };

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine.Model.Local;
  }

}).call(this);

//# sourceMappingURL=local.js.map
}, "spine/lib/bindings": function(exports, require, module) {// Generated by CoffeeScript 1.8.0
(function() {
  var BindingsClass, BindingsInstance, ValueSetter;

  BindingsClass = {
    model: 'model',
    bindings: {}
  };

  ValueSetter = (function() {
    function ValueSetter(context) {
      this.context = context;
    }

    ValueSetter.prototype.setValue = function(element, value, setter) {
      if (typeof setter === 'string') {
        setter = this.context.proxy(this.context[setter]);
      }
      setter = setter || (function(_this) {
        return function(e, v) {
          return _this._standardSetter(e, v);
        };
      })(this);
      console.log('bindings setter')
      return setter(element, value);
    };

    ValueSetter.prototype.getValue = function(element, getter) {
      if (typeof getter === 'string') {
        getter = this.context.proxy(this.context[getter]);
      }
      getter = getter || (function(_this) {
        return function(e, v) {
          return _this._standardGetter(e, v);
        };
      })(this);
      console.log('bindings getter')
      return getter(element);
    };

    ValueSetter.prototype._standardGetter = function(element) {
      var self, _name;
      self = this;
      return (typeof self[_name = "_" + (element.attr('type')) + "Get"] === "function" ? self[_name](element) : void 0) || element.val();
    };

    ValueSetter.prototype._standardSetter = function(element, value) {
      var self;
      self = this;
      return element.each(function() {
        var el, _name;
        el = $(this);
        return (typeof self[_name = "_" + (el.attr('type')) + "Set"] === "function" ? self[_name](el, value) : void 0) || el.val(value);
      });
    };

    ValueSetter.prototype._checkboxSet = function(element, value) {
      if (value) {
        return element.prop('checked', 'checked');
      } else {
        return element.prop('checked', '');
      }
    };

    ValueSetter.prototype._checkboxGet = function(element) {
      return element.is(':checked');
    };

    return ValueSetter;

  })();

  BindingsInstance = {
    getModel: function() {
      return this[this.modelVar];
    },
    setModel: function(model) {
      return this[this.modelVar] = model;
    },
    walkBindings: function(fn) {
      var field, selector, _ref, _results;
      _ref = this.bindings;
      _results = [];
      for (selector in _ref) {
        field = _ref[selector];
        _results.push(fn(selector, field));
      }
      return _results;
    },
    applyBindings: function() {
      this.valueSetter = new ValueSetter(this);
      return this.walkBindings((function(_this) {
        return function(selector, field) {
          if (!field.direction || field.direction === 'model') {
            _this._bindModelToEl(_this.getModel(), field, selector);
          }
          if (!field.direction || field.direction === 'element') {
            return _this._bindElToModel(_this.getModel(), field, selector);
          }
        };
      })(this));
    },
    _getField: function(value) {
      if (typeof value === 'string') {
        return value;
      } else {
        return value.field;
      }
    },
    _forceModelBindings: function(model) {
      return this.walkBindings((function(_this) {
        return function(selector, field) {
          return _this.valueSetter.setValue(_this.$(selector), model[_this._getField(field)], field.setter);
        };
      })(this));
    },
    changeBindingSource: function(model) {
      this.getModel().unbind('change');
      this.walkBindings((function(_this) {
        return function(selector) {
          if (selector === 'self') {
            selector = false;
          }
          return _this.el.off('change', selector);
        };
      })(this));
      this.setModel(model);
      this._forceModelBindings(model);
      return this.applyBindings();
    },
    _bindModelToEl: function(model, field, selector) {
      var self;
      self = this;
      if (selector === 'self') {
        selector = false;
      }
      return this.el.on('change', selector, function() {
        return model[self._getField(field)] = self.valueSetter.getValue($(this), field.getter);
      });
    },
    _bindElToModel: function(model, field, selector) {
      return model.bind('change', (function(_this) {
        return function() {
          return _this.valueSetter.setValue(_this.$(selector), model[_this._getField(field)], field.setter);
        };
      })(this));
    }
  };

  Spine.Bindings = {
    extended: function() {
      this.extend(BindingsClass);
      return this.include(BindingsInstance);
    }
  };

}).call(this);

//# sourceMappingURL=bindings.js.map
}, "spine/lib/route": function(exports, require, module) {// Generated by CoffeeScript 1.8.0
(function() {
  var $, Path, Route, Spine, escapeRegExp, hashStrip, namedParam, splatParam,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Spine = this.Spine || require('spine');

  $ = Spine.$;

  hashStrip = /^#*/;

  namedParam = /:([\w\d]+)/g;

  splatParam = /\*([\w\d]+)/g;

  escapeRegExp = /[-[\]{}()+?.,\\^$|#\s]/g;

  Path = (function(_super) {
    __extends(Path, _super);

    function Path(path, callback) {
      var match;
      this.path = path;
      this.callback = callback;
      this.names = [];
      if (typeof path === 'string') {
        namedParam.lastIndex = 0;
        while ((match = namedParam.exec(path)) !== null) {
          this.names.push(match[1]);
        }
        splatParam.lastIndex = 0;
        while ((match = splatParam.exec(path)) !== null) {
          this.names.push(match[1]);
        }
        path = path.replace(escapeRegExp, '\\$&').replace(namedParam, '([^\/]*)').replace(splatParam, '(.*?)');
        this.route = new RegExp("^" + path + "$");
      } else {
        this.route = path;
      }
    }

    Path.prototype.match = function(path, options) {
      var i, match, param, params, _i, _len;
      if (options == null) {
        options = {};
      }
      if (!(match = this.route.exec(path))) {
        return false;
      }
      options.match = match;
      params = match.slice(1);
      if (this.names.length) {
        for (i = _i = 0, _len = params.length; _i < _len; i = ++_i) {
          param = params[i];
          options[this.names[i]] = param;
        }
      }
      Route.trigger('before', this);
      return this.callback.call(null, options) !== false;
    };

    return Path;

  })(Spine.Module);

  Route = (function(_super) {
    var _ref;

    __extends(Route, _super);

    Route.extend(Spine.Events);

    Route.historySupport = ((_ref = window.history) != null ? _ref.pushState : void 0) != null;

    Route.options = {
      trigger: true,
      history: false,
      shim: false,
      replace: false,
      redirect: false
    };

    Route.routers = [];

    Route.setup = function(options) {
      if (options == null) {
        options = {};
      }
      this.options = $.extend({}, this.options, options);
      if (this.options.history) {
        this.history = this.historySupport && this.options.history;
      }
      if (this.options.shim) {
        return;
      }
      if (this.history) {
        $(window).bind('popstate', this.change);
      } else {
        $(window).bind('hashchange', this.change);
      }
      return this.change();
    };

    Route.unbind = function() {
      var unbindResult;
      unbindResult = Spine.Events.unbind.apply(this, arguments);
      if (arguments.length > 0) {
        return unbindResult;
      }
      if (this.options.shim) {
        return;
      }
      if (this.history) {
        return $(window).unbind('popstate', this.change);
      } else {
        return $(window).unbind('hashchange', this.change);
      }
    };

    Route.navigate = function() {
      var args, lastArg, options, path, routes;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      options = {};
      lastArg = args[args.length - 1];
      if (typeof lastArg === 'object') {
        options = args.pop();
      } else if (typeof lastArg === 'boolean') {
        options.trigger = args.pop();
      }
      options = $.extend({}, this.options, options);
      path = args.join('/');
      if (this.path === path) {
        return;
      }
      this.path = path;
      if (options.trigger) {
        this.trigger('navigate', this.path);
        routes = this.matchRoutes(this.path, options);
        if (!routes.length) {
          if (typeof options.redirect === 'function') {
            return options.redirect.apply(this, [this.path, options]);
          } else {
            if (options.redirect === true) {
              this.redirect(this.path);
            }
          }
        }
      }
      if (options.shim) {
        return true;
      } else if (this.history && options.replace) {
        return history.replaceState({}, document.title, this.path);
      } else if (this.history) {
        return history.pushState({}, document.title, this.path);
      } else {
        return window.location.hash = this.path;
      }
    };

    Route.create = function() {
      var router;
      router = new this;
      this.routers.push(router);
      return router;
    };

    Route.add = function(path, callback) {
      return this.router.add(path, callback);
    };

    Route.prototype.add = function(path, callback) {
      var key, value, _results;
      if (typeof path === 'object' && !(path instanceof RegExp)) {
        _results = [];
        for (key in path) {
          value = path[key];
          _results.push(this.add(key, value));
        }
        return _results;
      } else {
        return this.routes.push(new Path(path, callback));
      }
    };

    Route.prototype.destroy = function() {
      var r;
      this.routes.length = 0;
      return this.constructor.routers = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = this.constructor.routers;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          r = _ref1[_i];
          if (r !== this) {
            _results.push(r);
          }
        }
        return _results;
      }).call(this);
    };

    Route.getPath = function() {
      var path;
      if (this.history) {
        path = window.location.pathname;
        if (path.substr(0, 1) !== '/') {
          path = '/' + path;
        }
      } else {
        path = window.location.hash;
        path = path.replace(hashStrip, '');
      }
      return path;
    };

    Route.getHost = function() {
      return "" + window.location.protocol + "//" + window.location.host;
    };

    Route.change = function() {
      var path;
      path = Route.getPath();
      if (path === Route.path) {
        return;
      }
      Route.path = path;
      return Route.matchRoutes(Route.path);
    };

    Route.matchRoutes = function(path, options) {
      var match, matches, router, _i, _len, _ref1;
      matches = [];
      _ref1 = this.routers.concat([this.router]);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        router = _ref1[_i];
        match = router.matchRoute(path, options);
        if (match) {
          matches.push(match);
        }
      }
      if (matches.length) {
        this.trigger('change', matches, path);
      }
      return matches;
    };

    Route.redirect = function(path) {
      return window.location = path;
    };

    function Route() {
      this.routes = [];
    }

    Route.prototype.matchRoute = function(path, options) {
      var route, _i, _len, _ref1;
      _ref1 = this.routes;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        route = _ref1[_i];
        if (route.match(path, options)) {
          return route;
        }
      }
    };

    Route.prototype.trigger = function() {
      var args, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      args.splice(1, 0, this);
      return (_ref1 = this.constructor).trigger.apply(_ref1, args);
    };

    return Route;

  })(Spine.Module);

  Route.router = new Route;

  Spine.Controller.include({
    route: function(path, callback) {
      if (this.router instanceof Spine.Route) {
        return this.router.add(path, this.proxy(callback));
      } else {
        return Spine.Route.add(path, this.proxy(callback));
      }
    },
    routes: function(routes) {
      var key, value, _results;
      _results = [];
      for (key in routes) {
        value = routes[key];
        _results.push(this.route(key, value));
      }
      return _results;
    },
    navigate: function() {
      return Spine.Route.navigate.apply(Spine.Route, arguments);
    }
  });

  Route.Path = Path;

  Spine.Route = Route;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Route;
  }

}).call(this);

//# sourceMappingURL=route.js.map
}, "spine/lib/manager": function(exports, require, module) {// Generated by CoffeeScript 1.8.0
(function() {
  var $, Spine,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Spine = this.Spine || require('spine');

  $ = Spine.$;

  Spine.Manager = (function(_super) {
    __extends(Manager, _super);

    Manager.include(Spine.Events);

    function Manager() {
      this.controllers = [];
      this.bind('change', this.change);
      this.add.apply(this, arguments);
    }

    Manager.prototype.add = function() {
      var cont, controllers, _i, _len, _results;
      controllers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = controllers.length; _i < _len; _i++) {
        cont = controllers[_i];
        _results.push(this.addOne(cont));
      }
      return _results;
    };

    Manager.prototype.addOne = function(controller) {
      controller.bind('active', (function(_this) {
        return function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.trigger.apply(_this, ['change', controller].concat(__slice.call(args)));
        };
      })(this));
      controller.bind('release', (function(_this) {
        return function() {
          var c;
          return _this.controllers = (function() {
            var _i, _len, _ref, _results;
            _ref = this.controllers;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              c = _ref[_i];
              if (c !== controller) {
                _results.push(c);
              }
            }
            return _results;
          }).call(_this);
        };
      })(this));
      return this.controllers.push(controller);
    };

    Manager.prototype.deactivate = function() {
      return this.trigger.apply(this, ['change', false].concat(__slice.call(arguments)));
    };

    Manager.prototype.change = function() {
      var args, cont, current, _i, _len, _ref;
      current = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.controllers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cont = _ref[_i];
        if (cont !== current) {
          cont.deactivate.apply(cont, args);
        }
      }
      if (current) {
        return current.activate.apply(current, args);
      }
    };

    return Manager;

  })(Spine.Module);

  Spine.Controller.include({
    active: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (typeof args[0] === 'function') {
        this.bind('active', args[0]);
      } else {
        args.unshift('active');
        this.trigger.apply(this, args);
      }
      return this;
    },
    isActive: function() {
      return this.el.hasClass('active');
    },
    activate: function() {
      this.el.addClass('active');
      return this;
    },
    deactivate: function() {
      this.el.removeClass('active');
      return this;
    }
  });

  Spine.Stack = (function(_super) {
    __extends(Stack, _super);

    Stack.prototype.controllers = {};

    Stack.prototype.routes = {};

    Stack.prototype.className = 'spine stack';

    function Stack() {
      this.release = __bind(this.release, this);
      var key, value, _fn, _ref, _ref1, _ref2;
      Stack.__super__.constructor.apply(this, arguments);
      this.manager = new Spine.Manager;
      this.router = (_ref = Spine.Route) != null ? _ref.create() : void 0;
      _ref1 = this.controllers;
      for (key in _ref1) {
        value = _ref1[key];
        if (this[key] != null) {
          throw Error("'@" + key + "' already assigned");
        }
        this[key] = new value({
          stack: this
        });
        this.add(this[key]);
      }
      _ref2 = this.routes;
      _fn = (function(_this) {
        return function(key, value) {
          var callback;
          if (typeof value === 'function') {
            callback = value;
          }
          callback || (callback = function() {
            var _ref3;
            return (_ref3 = _this[value]).active.apply(_ref3, arguments);
          });
          return _this.route(key, callback);
        };
      })(this);
      for (key in _ref2) {
        value = _ref2[key];
        _fn(key, value);
      }
      if (this["default"]) {
        this[this["default"]].active();
      }
    }

    Stack.prototype.add = function(controller) {
      this.manager.add(controller);
      return this.append(controller);
    };

    Stack.prototype.release = function() {
      var _ref;
      if ((_ref = this.router) != null) {
        _ref.destroy();
      }
      return Stack.__super__.release.apply(this, arguments);
    };

    return Stack;

  })(Spine.Controller);

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine.Manager;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports.Stack = Spine.Stack;
  }

}).call(this);

//# sourceMappingURL=manager.js.map
}, "index": function(exports, require, module) {(function() {
  var App, Spine, Tmodel, Utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require('lib/setup');

  Spine = require('spine');

  Utils = require("plugins/utils");

  Tmodel = require('models/tmodel');

  App = (function(_super) {
    __extends(App, _super);

    App.extend(Spine.Bindings);

    App.prototype.elements = {
      'select.form-control': 'selector'
    };

    App.prototype.events = {
      'blur input': 'blur',
      'keyup': 'saveOnEnter',
      'change select': 'select'
    };

    App.prototype.modelVar = 'tmodel';

    App.prototype.bindings = {
      'input.firstName': {
        field: 'firstname',
        setter: function(element, value) {
          return element.val(value);
        },
        getter: function(element) {
          return element.val();
        }
      },
      'input.lastName': {
        field: 'lastname',
        setter: function(element, value) {
          return element.val(value);
        },
        getter: function(element) {
          return element.val();
        }
      },
      'span.firstName': {
        field: 'firstname',
        setter: function(element, value) {
          return element.html(value);
        }
      },
      'span.lastName': {
        field: 'lastname',
        setter: function(element, value) {
          return element.html(value);
        }
      }
    };

    function App() {
      App.__super__.constructor.apply(this, arguments);
      Tmodel.bind('change', this.proxy(this.change));
      if (Tmodel.count()) {
        this.tmodel = Tmodel.first();
      }
      this.applyBindings();
      this.render();
    }

    App.prototype.change = function(rec) {};

    App.prototype.render = function() {
      this.html(require("views/sample")({
        version: Spine.version,
        firstname: this.tmodel.firstname,
        lastname: this.tmodel.lastname,
        id: this.tmodel.id,
        tmodels: Tmodel.records
      }));
      return this.refreshElements();
    };

    App.prototype.save = function() {
      return this.tmodel.save();
    };

    App.prototype.select = function(e) {
      this.tmodel = Tmodel.find(this.selector.val());
      this.changeBindingSource(this.tmodel);
      return this.render();
    };

    App.prototype.blur = function(e) {
      var el, isFormfield;
      el = $(document.activeElement);
      isFormfield = $().isFormElement(el);
      return this.save();
    };

    App.prototype.saveOnEnter = function(e) {
      var code, el, isFormfield;
      code = e.charCode || e.keyCode;
      el = $(document.activeElement);
      isFormfield = $().isFormElement(el);
      switch (code) {
        case 13:
          if (isFormfield) {
            return this.save();
          }
      }
    };

    return App;

  })(Spine.Controller);

  module.exports = App;

}).call(this);
}, "lib/setup": function(exports, require, module) {(function() {
  require('spine');

  require('spine/lib/local');

  require('spine/lib/bindings');

  require('spine/lib/manager');

  require('spine/lib/route');

}).call(this);
}, "models/tmodel": function(exports, require, module) {(function() {
  var Model, Spine, Tmodel,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Spine = require('spine');

  Model = Spine.Model;

  require("spine/lib/local");

  Tmodel = (function(_super) {
    __extends(Tmodel, _super);

    function Tmodel() {
      return Tmodel.__super__.constructor.apply(this, arguments);
    }

    Tmodel.configure('Tmodel', 'firstname', 'lastname');

    Tmodel.extend(Model.Local);

    return Tmodel;

  })(Spine.Model);

  module.exports = Tmodel;

}).call(this);
}, "plugins/utils": function(exports, require, module) {(function() {
  var $;

  $ = typeof jQuery !== "undefined" && jQuery !== null ? jQuery : require("jqueryify");

  $.fn.isFormElement = function(o) {
    var formElements, str;
    if (o == null) {
      o = [];
    }
    str = Object.prototype.toString.call(o[0]);
    formElements = ['[object HTMLInputElement]', '[object HTMLTextAreaElement]'];
    return formElements.indexOf(str) !== -1;
  };

}).call(this);
}, "views/sample": function(exports, require, module) {module.exports = function template(locals) {
var jade_debug = [{ lineno: 1, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" }];
try {
var buf = [];
var jade_mixins = {};
var jade_interp;
;var locals_for_with = (locals || {});(function (firstname, id, lastname, text, tmodels, undefined, version) {
jade_debug.unshift({ lineno: 0, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 1, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<h2>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<div>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: jade_debug[0].filename });
buf.push("Test " + (jade.escape((jade_interp = version) == null ? '' : jade_interp)) + "");
jade_debug.shift();
jade_debug.shift();
buf.push("</div>");
jade_debug.shift();
jade_debug.unshift({ lineno: 3, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<span>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 3, filename: jade_debug[0].filename });
buf.push("Welcome");
jade_debug.shift();
jade_debug.shift();
buf.push("</span>");
jade_debug.shift();
jade_debug.unshift({ lineno: 4, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<span class=\"firstName\">");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 4, filename: jade_debug[0].filename });
buf.push("" + (jade.escape((jade_interp = firstname) == null ? '' : jade_interp)) + " ");
jade_debug.shift();
jade_debug.shift();
buf.push("</span>");
jade_debug.shift();
jade_debug.unshift({ lineno: 5, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<span class=\"lastName\">");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 5, filename: jade_debug[0].filename });
buf.push("" + (jade.escape((jade_interp = lastname) == null ? '' : jade_interp)) + "");
jade_debug.shift();
jade_debug.shift();
buf.push("</span>");
jade_debug.shift();
jade_debug.shift();
buf.push("</h2>");
jade_debug.shift();
jade_debug.unshift({ lineno: 7, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<div id=\"form\">");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 8, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<form>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 9, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<select class=\"form-control\">");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 10, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<option>none");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.shift();
buf.push("</option>");
jade_debug.shift();
jade_debug.unshift({ lineno: 11, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
// iterate tmodels
;(function(){
  var $$obj = tmodels;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var val = $$obj[$index];

jade_debug.unshift({ lineno: 11, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 12, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
if ( id === val.id)
{
jade_debug.unshift({ lineno: 13, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 13, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<option selected=\"selected\">" + (jade.escape(null == (jade_interp = val.id) ? "" : jade_interp)));
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.shift();
buf.push("</option>");
jade_debug.shift();
jade_debug.shift();
}
else
{
jade_debug.unshift({ lineno: 15, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 15, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<option>" + (jade.escape(null == (jade_interp = val.id) ? "" : jade_interp)));
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.shift();
buf.push("</option>");
jade_debug.shift();
jade_debug.shift();
}
jade_debug.shift();
jade_debug.shift();
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var val = $$obj[$index];

jade_debug.unshift({ lineno: 11, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 12, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
if ( id === val.id)
{
jade_debug.unshift({ lineno: 13, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 13, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<option selected=\"selected\">" + (jade.escape(null == (jade_interp = val.id) ? "" : jade_interp)));
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.shift();
buf.push("</option>");
jade_debug.shift();
jade_debug.shift();
}
else
{
jade_debug.unshift({ lineno: 15, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
jade_debug.unshift({ lineno: 15, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<option>" + (jade.escape(null == (jade_interp = val.id) ? "" : jade_interp)));
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.shift();
buf.push("</option>");
jade_debug.shift();
jade_debug.shift();
}
jade_debug.shift();
jade_debug.shift();
    }

  }
}).call(this);

jade_debug.shift();
jade_debug.shift();
buf.push("</select>");
jade_debug.shift();
jade_debug.shift();
buf.push("</form>");
jade_debug.shift();
jade_debug.shift();
buf.push("</div>");
jade_debug.shift();
jade_debug.unshift({ lineno: 18, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<div id=\"content\">");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 19, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<input" + (jade.attr("type", text, true, false)) + (jade.attr("value", '' + (firstname) + '', true, false)) + " class=\"firstName\"/>");
jade_debug.shift();
jade_debug.unshift({ lineno: 20, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<input" + (jade.attr("type", text, true, false)) + (jade.attr("value", '' + (lastname) + '', true, false)) + " class=\"lastName\"/>");
jade_debug.shift();
jade_debug.unshift({ lineno: 21, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<input" + (jade.attr("type", text, true, false)) + (jade.attr("value", '' + (firstname) + '', true, false)) + " class=\"firstName\"/>");
jade_debug.shift();
jade_debug.unshift({ lineno: 22, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<input" + (jade.attr("type", text, true, false)) + (jade.attr("value", '' + (lastname) + '', true, false)) + " class=\"lastName\"/>");
jade_debug.shift();
jade_debug.shift();
buf.push("</div>");
jade_debug.shift();
jade_debug.unshift({ lineno: 24, filename: "/Library/Server/Web/Data/Sites/webpremiere.dev/gap.webpremiere.de/app.director/app/webroot/js/spine/newapp/app/views/sample.jade" });
buf.push("<p>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 24, filename: jade_debug[0].filename });
buf.push("Time to get busy with this magic!");
jade_debug.shift();
jade_debug.shift();
buf.push("</p>");
jade_debug.shift();
jade_debug.shift();}.call(this,"firstname" in locals_for_with?locals_for_with.firstname:typeof firstname!=="undefined"?firstname:undefined,"id" in locals_for_with?locals_for_with.id:typeof id!=="undefined"?id:undefined,"lastname" in locals_for_with?locals_for_with.lastname:typeof lastname!=="undefined"?lastname:undefined,"text" in locals_for_with?locals_for_with.text:typeof text!=="undefined"?text:undefined,"tmodels" in locals_for_with?locals_for_with.tmodels:typeof tmodels!=="undefined"?tmodels:undefined,"undefined" in locals_for_with?locals_for_with.undefined:typeof undefined!=="undefined"?undefined:undefined,"version" in locals_for_with?locals_for_with.version:typeof version!=="undefined"?version:undefined));;return buf.join("");
} catch (err) {
  jade.rethrow(err, jade_debug[0].filename, jade_debug[0].lineno, "h2\n  div Test #{version}\n  span Welcome\n  span.firstName #{firstname} \n  span.lastName #{lastname}\n\n#form\n  form\n    select.form-control\n        option='none'\n        each val in tmodels\n          if id === val.id\n            option(selected='selected')=val.id\n          else\n            option=val.id\n          \n\n#content\n  input(type=text, value='#{firstname}').firstName\n  input(type=text, value='#{lastname}').lastName\n  input(type=text, value='#{firstname}').firstName\n  input(type=text, value='#{lastname}').lastName\n    \np Time to get busy with this magic!\n");
}
};}
});

jade.rethrow = function rethrow(err, filename, lineno){ throw err; } 