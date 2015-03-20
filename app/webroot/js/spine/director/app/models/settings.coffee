Spine = require('spine')
$       = Spine.$
Model   = Spine.Model
Log     = Spine.Log
require('spine/lib/local')

class Settings extends Spine.Model
  @configure 'Settings', 'id', 'user_id', 'autoupload', 'hash', 'previousHash'
  
  @extend Model.Local
  @include Log
  
  init: (instance) ->
  
  @findUserSettings: ->
    Settings.findByAttribute('user_id', User.first().id)
  
  @isAutoUpload: ->
    return unless user = User.first()
    setting = @findByAttribute('user_id', user.id)
    ret = setting?.autoupload or false
    ret
  
module.exports = Model.Settings = Settings