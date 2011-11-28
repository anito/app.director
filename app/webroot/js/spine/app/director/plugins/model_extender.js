var $, Model;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
if (typeof Spine === "undefined" || Spine === null) {
  Spine = require("spine");
}
$ = Spine.$;
Model = Spine.Model;
Model.Extender = {
  extended: function() {
    var Extend, Include;
    Extend = {
      record: false,
      selection: [
        {
          global: []
        }
      ],
      fromJSON: function(objects) {
        var json, key;
        this.createJoinTables(objects);
        key = this.className;
        if (this.isArray(objects)) {
          json = this.fromArray(objects, key);
        }
        return json || this.__super__.constructor.fromJSON.call(this, objects);
      },
      createJoinTables: function(arr) {
        var joinTables, key, _i, _len, _results;
        if (!this.isArray(arr)) {
          return;
        }
        joinTables = this.joinTables();
        _results = [];
        for (_i = 0, _len = joinTables.length; _i < _len; _i++) {
          key = joinTables[_i];
          _results.push(Spine.Model[key].refresh(this.createJoin(arr, key)));
        }
        return _results;
      },
      joinTables: function() {
        var fModels, joinTables, key, value;
        fModels = this.foreignModels();
        joinTables = (function() {
          var _results;
          _results = [];
          for (key in fModels) {
            value = fModels[key];
            _results.push(fModels[key]['joinTable']);
          }
          return _results;
        })();
        return joinTables;
      },
      fromArray: function(arr, key) {
        var extract, obj, res, _i, _len;
        res = [];
        extract = __bind(function(obj) {
          var item, itm;
          if (!this.isArray(obj[key])) {
            item = __bind(function() {
              return res.push(new this(obj[key]));
            }, this);
            return itm = item();
          }
        }, this);
        for (_i = 0, _len = arr.length; _i < _len; _i++) {
          obj = arr[_i];
          extract(obj);
        }
        return res;
      },
      createJoin: function(json, tableName) {
        var introspect, obj, res, _i, _len;
        res = [];
        introspect = __bind(function(obj) {
          var key, val, _i, _len, _results;
          if (this.isObject(obj)) {
            for (key in obj) {
              val = obj[key];
              if (key === tableName) {
                res.push(obj[key]);
              } else {
                introspect(obj[key]);
              }
            }
          }
          if (this.isArray(obj)) {
            _results = [];
            for (_i = 0, _len = obj.length; _i < _len; _i++) {
              val = obj[_i];
              _results.push(introspect(val));
            }
            return _results;
          }
        }, this);
        for (_i = 0, _len = json.length; _i < _len; _i++) {
          obj = json[_i];
          introspect(obj);
        }
        return res;
      },
      selectionList: __bind(function(recordID) {
        var id, item, _i, _len, _ref, _ref2;
        id = recordID || ((_ref = this.record) != null ? _ref.id : void 0);
        if (!id) {
          return this.selection[0].global;
        }
        _ref2 = this.selection;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          item = _ref2[_i];
          if (item[id]) {
            return item[id];
          }
        }
      }, this),
      updateSelection: function(list, id) {
        return this.emptySelection(list, id);
      },
      emptySelection: function(list, id) {
        var originalList;
        if (list == null) {
          list = [];
        }
        originalList = this.selectionList(id);
        [].splice.apply(originalList, [0, originalList.length - 0].concat(list)), list;
        return originalList;
      },
      removeFromSelection: function(model, id) {
        var list, record;
        if (this.exists(id)) {
          record = this.find(id);
        }
        if (!record) {
          return;
        }
        list = model.selectionList();
        record.remove(list);
        return list;
      },
      isArray: function(value) {
        return Object.prototype.toString.call(value) === "[object Array]";
      },
      isObject: function(value) {
        return Object.prototype.toString.call(value) === "[object Object]";
      },
      current: function(recordOrID) {
        var id, rec;
        rec = false;
        id = (recordOrID != null ? recordOrID.id : void 0) || recordOrID;
        if (this.exists(id)) {
          rec = this.find(id);
        }
        return this.record = rec;
      },
      selected: function() {
        return this.record;
      },
      toID: function(records) {
        var ids, record;
        if (records == null) {
          records = this.records;
        }
        return ids = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = records.length; _i < _len; _i++) {
            record = records[_i];
            _results.push(record.id);
          }
          return _results;
        })();
      },
      errorHandler: function(record, xhr, statusText, error) {
        var status;
        status = xhr.status;
        if (status !== 200) {
          error = new Error({
            record: record,
            xhr: xhr,
            statusText: statusText,
            error: error
          });
          error.save();
          User.redirect('users/login');
        }
        console.log(record);
        console.log(xhr);
        console.log(statusText);
        return console.log(error);
      },
      customErrorHandler: function(xhr) {
        var error, status;
        console.log(xhr);
        status = xhr.status;
        if (status !== 200) {
          error = new Error({
            flash: '<strong style="color:red">Login failed</strong>',
            xhr: xhr
          });
          error.save();
          return User.redirect('users/login');
        }
      }
    };
    Include = {
      selectionList: function() {
        return this.constructor.selectionList(this.id);
      },
      updateSelection: function(list) {
        return this.constructor.updateSelection(list, this.id);
      },
      emptySelection: function(list) {
        return this.constructor.emptySelection(list, this.id);
      },
      addRemoveSelection: function(model, isMetaKey) {
        var list;
        list = model.selectionList();
        if (!list) {
          return;
        }
        if (!isMetaKey) {
          this.addUnique(list);
        } else {
          this.addRemove(list);
        }
        return list;
      },
      updateChangedAttributes: function(atts) {
        var invalid, key, origAtts, value;
        origAtts = this.attributes();
        for (key in atts) {
          value = atts[key];
          if (origAtts[key] !== value) {
            invalid = true;
            this[key] = value;
          }
        }
        if (invalid) {
          return this.save();
        }
      },
      addUnique: function(list) {
        var _ref;
        return ([].splice.apply(list, [0, list.length - 0].concat(_ref = [this.id])), _ref);
      },
      addRemove: function(list) {
        var index, _ref;
        if (_ref = this.id, __indexOf.call(list, _ref) < 0) {
          list.push(this.id);
        } else {
          index = list.indexOf(this.id);
          if (index !== -1) {
            list.splice(index, 1);
          }
        }
        return list;
      },
      remove: function(list) {
        var index;
        index = list.indexOf(this.id);
        if (index !== -1) {
          list.splice(index, 1);
        }
        return list;
      }
    };
    this.extend(Extend);
    return this.include(Include);
  }
};