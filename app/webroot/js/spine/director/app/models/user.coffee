Spine     = require("spine")
$         = Spine.$
Log       = Spine.Log
Model     = Spine.Model
Settings  = require("models/settings")
Clipboard = require("models/clipboard")
#Extender  = require("extensions/model_extender")

require('spine/lib/local')

class User extends Spine.Model

  @configure 'User', 'id', 'username', 'name', 'groupname', 'sessionid', 'hash'

#  @extend Extender
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
    
  logout: ->
    @constructor.logout()
    
  isValid: (callback) ->
    $.ajax
      headers: {'X-Requested-With': 'XMLHttpRequest'}
      url: base_url + 'users/isValid'
      type: 'GET'
      processData: false
      success: (json) => callback.call @, json
      error: (xhr, status) =>
        if status is "error" then @logout()
      
module?.exports = User