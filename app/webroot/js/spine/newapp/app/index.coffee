require('lib/setup')

Spine = require('spine')
Utils = require("plugins/utils")
Tmodel = require('models/tmodel');

class App extends Spine.Controller

  @extend Spine.Bindings
  
  elements:
    'select.form-control'  : 'selector'
  
  events:
    'blur input'     : 'blur'
    'keyup'          : 'saveOnEnter'
    'change select'  : 'select'
  
  modelVar: 'tmodel'
  
  bindings:
    'input.firstName':
      field: 'firstname'
      setter: (element, value) ->
        element.val(value)
      getter: (element) ->
        element.val()
    'input.lastName':
      field: 'lastname'
      setter: (element, value) ->
        element.val(value)
      getter: (element) ->
        element.val()
    'span.firstName':
      field: 'firstname'
      setter: (element, value) ->
        element.html(value)
    'span.lastName':
      field: 'lastname'
      setter: (element, value) ->
        element.html(value)
      
  constructor: ->
    super
    
    Tmodel.bind('change', @proxy @change)
    
    @tmodel = Tmodel.first() if Tmodel.count()
    
    do @applyBindings
    @render()
    
  change: (rec) ->
  
  render: ->
    @html require("views/sample")
      version: Spine.version
      firstname: @tmodel.firstname
      lastname: @tmodel.lastname
      id: @tmodel.id
      tmodels: Tmodel.records
    @refreshElements()
    
  save: ->
    @tmodel.save()
    
  select: (e) ->
    @tmodel = Tmodel.find(@selector.val())
    @changeBindingSource(@tmodel)
    @render()
    
  blur: (e) ->
    
    el=$(document.activeElement)
    isFormfield = $().isFormElement(el)
    
    @save()
    
  saveOnEnter: (e) ->
    code = e.charCode or e.keyCode
    
    el=$(document.activeElement)
    isFormfield = $().isFormElement(el)
    
    switch code
      when 13 #Return
        if isFormfield
          @save()
    
module.exports = App