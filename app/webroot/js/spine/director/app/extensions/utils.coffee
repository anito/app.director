# jQuery.tmpl.js utilities

$ = jQuery ? require("jqueryify")

$.fn.guid = ->
  mask = [8, 4, 4, 4, 12]

  ret = []
  ret = for sub in mask
    res = null
    milli = new Date().getTime();
    back = new Date().setTime(milli*(-200))
    diff = milli - back
    re1 = diff.toString(16).split('')
    re2 = re1.slice(sub*(-1))
    re3 = re2.join('')
    re3

  re4 = ret.join('-')
  re4

$.fn.uuid = ->
  s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

$.fn.deselect = (sel) ->
  $(@).children(sel).removeClass('active hot')
  
$.extend jQuery.tmpl.tag,
  "for": 
    _default: {$2: "var i=1;i<=1;i++"},
    open: 'for ($2){',
    close: '};'
  
$.fn.isFormElement = (o=[]) ->
  str = Object::toString.call(o[0])
  formElements = ['[object HTMLInputElement]','[object HTMLTextAreaElement]']
  formElements.indexOf(str) isnt -1

$.fn.state = (state) ->
  d = 'disabled'
  @each ->
    $this = $(@)
    $this.html( $this.data()[state] )
    if state is 'loading'
      return $this.addClass(d).attr(d,d)
    else
      return $this.removeClass(d).removeAttr(d)
    
$.fn.unparam = (value) ->
  # Object that holds names => values.
  params = {}
  # Get query string pieces (separated by &)
  pieces = value.split('&')

  for piece in pieces
    pair = piece.split('=', 2)
    params[decodeURIComponent(pair[0])] = if pair.length is 2 then decodeURIComponent(pair[1].replace(/\+|false/g, '')) else true
  params

