Array.prototype.toID = ->
  res = []
  for item in @
    id = if typeof item is 'object' then item.id else if typeof item is 'string' then item
    res.push id if id
  res
  
Array.prototype.removeFromList = (list=[]) ->
  seq = []
  for id, idx in @ when id in list
    seq.push(idx)
  seq.reverse()
  for id in seq
    @splice(id, 1)
  @
  
Array.prototype.last = ->
  lastIndex = @.length-1
  @[lastIndex] or null
  
Array.prototype.first = ->
  @[0] or null
  


Array.prototype.update = (value) ->
  throw new Error('passed value requires an array') unless Object::toString.call(value) is '[object Array]'
  @[0...@length] = value
  @

Array.prototype.addRemoveSelection = (id) ->
  @toggleSelected(id)
  @
  
Array.prototype.add = (id) ->
  @toggleSelected(id, true)
  @
  
Array.prototype.toggleSelected = (id, addonly) ->
  return @ unless id
  unless id in @
    @unshift id
  else unless addonly
    index = @indexOf(id)
    @splice(index, 1) unless index is -1
  @
  
Array.prototype.contains = (string) ->
  for value in @
    Regex = new RegExp(value)
    return true if Regex.test(string)