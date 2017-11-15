Spine     = require("spine")
$         = Spine.$
Extender  = require('extensions/controller_extender')

class MainView extends Spine.Controller

  @extend Extender
  
  constructor: ->
    super
    @bind('active', @proxy @active)
    
  active: ->
    
 module?.exports = MainView