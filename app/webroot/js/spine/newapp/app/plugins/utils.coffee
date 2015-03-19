$ = jQuery ? require("jqueryify")

$.fn.isFormElement = (o=[]) ->
  str = Object::toString.call(o[0])
  formElements = ['[object HTMLInputElement]','[object HTMLTextAreaElement]']
  formElements.indexOf(str) isnt -1