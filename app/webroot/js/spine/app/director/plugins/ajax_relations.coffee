Spine ?= require("spine")
$      = Spine.$
Model  = Spine.Model

class Builder
  constructor: (record) ->
    @data = {}
    @record = record
    @model = record.constructor
    @foreignModels = @model.foreignModels()

  newWrapper: (key) ->
    throw('No classname found') unless key.className
    data = {}
    data[key.className] = {}
    data
    

  build: ->
    @fModels = for key, value of @foreignModels
      @foreignModels[key]

    for key in @fModels
      model = Spine.Model[key.className]
      records = model.filter(@record.id)

      selected = @newWrapper model
      selected[model.className] = @model.toID(records)
      @data[model.className] = selected

    @data[@model.className] = @record
    @data

class Request extends Singleton
  constructor: (@record) ->
    super
    @data = new Builder(@record).build()
  
  create: (params) ->
    @queue =>
      @ajax(
        params,
        type: "POST"
        data: JSON.stringify(@data)
        url:  Ajax.getURL(@model)
      ).success(@recordResponse)
       .error(@errorResponse)

  update: (params) ->
    @queue =>
      @ajax(
        params,
        type: "PUT"
        data: JSON.stringify(@data)
        url:  Ajax.getURL(@record)
      ).success(@recordResponse)
       .error(@errorResponse)

Model.AjaxRelations =
  
  extended: ->
    
    Include =
      ajax: -> new Request @
      
    @include Include
    
Spine.Builder = Builder