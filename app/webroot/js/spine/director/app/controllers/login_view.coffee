Spine = require("spine")
$     = Spine.$
User  = require('models/user')

class LoginView extends Spine.Controller

  elements:
    'button'              : 'logoutEl'

  events:
    'click .opt-logout'        : 'logout'
    'click .opt-trace'         : 'toggleTrace'
    
  constructor: ->
    super
    
  template: ->
    $('#loginTemplate').tmpl
      user: User.first()
      trace: !Spine.isProduction
    
  logout: ->
    User.logout()
    
  toggleTrace: ->
    Spine.isProduction = localStorage.isProduction = localStorage.isProduction is 'false'
    alert 'Trace: ' + (if Spine.isProduction then 'Off' else 'On') + '\nApplication will now restart'
    $(window).off()
    User.redirect('director_app')
    
  render: ->
    @html @template()

module?.exports = LoginView