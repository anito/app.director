Photo = (function(_super){
  var __hasProp = {}.hasOwnProperty, $, Photo
  _extend = function(child, parent) {
    for(var key in parent) {
      
      if(__hasProp.call(parent, key)) {
        child[key] = parent[key];
      //console.log(child[key])
      }
    }
  }
  
  _extend(Photo, _super)
  
  function Photo() {
    this.drive = function(){}
    return Photo.__super__.constructor.apply(this, arguments);
  }
  return Photo;

})(Spine.Model)
p = new Photo