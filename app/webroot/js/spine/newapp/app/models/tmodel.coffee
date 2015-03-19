Spine = require('spine')
Model = Spine.Model
require("spine/lib/local")

class Tmodel extends Spine.Model
  @configure 'Tmodel', 'firstname', 'lastname'
  
  @extend Model.Local
  
module.exports = Tmodel