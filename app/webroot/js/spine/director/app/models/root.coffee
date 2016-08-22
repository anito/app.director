Spine             = require("spine")
$                 = Spine.$
Model             = Spine.Model
Gallery           = require('models/gallery')
Filter            = require("plugins/filter")
Extender          = require("plugins/model_extender")

class Root extends Spine.Model

  @configure "Root", 'id'

  @extend Extender
  
  @childType = 'Gallery'
  
  init: (instance) ->
    return unless id = instance.id
    
    
module?.exports = Model.Root = Root

