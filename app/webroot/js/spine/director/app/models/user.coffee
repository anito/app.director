Spine     = require("spine")
$         = Spine.$
Log       = Spine.Log
Model     = Spine.Model
Settings  = require("models/settings")
Clipboard = require("models/clipboard")

require('spine/lib/local')

class User extends Spine.Model

  @configure 'User', 'id', 'username', 'name', 'groupname', 'sessionid', 'hash'

  @extend Model.Local
  @include Log
  
  @trace: true
  
  @ping: ->
    @fetch()
    if user = @first()
      user.confirm()
    else
      @redirect 'users/login'
    
  @logout: ->
    @destroyAll()
    Clipboard.destroyAll()
    $(window).off()
    @redirect 'logout'
  
  @redirect: (url='', hash='') ->
    location.href = base_url + url + hash

  init: (instance) ->
    
  confirm: ->
    $.ajax
      url: base_url + 'users/ping'
      data: JSON.stringify(@)
      type: 'POST'
      success: @success
      error: @error
  
  success: (json) =>
    @constructor.trigger('pinger', @, $.parseJSON(json))

  error: (xhr) =>
    @log 'error'
    @constructor.logout()
    @constructor.redirect 'users/login'
      
module?.exports = User