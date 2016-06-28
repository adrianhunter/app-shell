
app-shell = require '../../src/app-shell.ls'
yo = require 'yo-yo'
h = require 'hyperscript'
_ = require 'underscore'
window.h = h
window.yo = yo
{App, SERVICES} = app-shell!

TEMPLATE_NAMES = 
    home: 'hjgfjhgfh'
    not-found: 'not-found'
    header: 'header'
    layout: 'layout'
ROUTE_NAMES = 
    home: 'home'
    not-found: 'not-found'
    about: 'about'
 
STYLE =
    active: '.active'
    item: '.item'
    link-item: 'a.item'
    header: 
        container: '.ui .three .item .menu'
        
    

TEMPLATES = {
    (TEMPLATE_NAMES.header):
        template:(state = {}, props = {})-> h STYLE.header.container, 'foo',
            h STYLE.link-item, {href: '/home'}, ROUTE_NAMES.home
            h STYLE.link-item, {href: '/about'}, ROUTE_NAMES.about
            
            
            
    (TEMPLATE_NAMES.layout):
        template:(state = {}, props = {})-> h '#root',
            h '#header'
            h '#content'
            h '#footer'
            
            
    (TEMPLATE_NAMES.about):
        template:(state = {}, props = {})-> h '#about',
            h 'p', "
                some really nice info!
            "
            
    (TEMPLATE_NAMES.home):
        template: (state = {}, props = {})-> h '.home',
            h 'p', "
                Wow! this is nice !
            "
}
                    
window.TEMPLATES = TEMPLATES

COLLECTIONS =
    MESSAGES:
        name: 'messages' 
        _class: class Message
            _template:(state,props)-> yo("""
              <div>message: #{123}</div>
            """)
            (data)->
                @txt = data.txt
                @toString = -> @_template {txt}=@
        transform:(data)-> new @_class data
        
        
ROUTES = [
  * path:'/'
    name: ROUTE_NAMES.home
    action:(req, res, asd)!->
        @render {
            layout: TEMPLATES[TEMPLATE_NAMES.layout]
        }
        @render {
            template: TEMPLATES[TEMPLATE_NAMES.header]
            target-id: 'header'
            
        }
        @render {
            template: TEMPLATES[TEMPLATE_NAMES.home]
            target-id: 'content'
        }
        
    events: 
        'click #start':->
            alert 1
  * path:'/about'
    name: ROUTE_NAMES.about
    action:->
        @render {
            template: TEMPLATES[TEMPLATE_NAMES.about]
            target-id: 'content'
        }
        
]


    


# app = new App {TEMPLATES,COLLECTIONS, ROUTES}
# window.app = app

# console.log app.router.match '/'

# require './video-player'
# console.log 'wwwwwww'

# BA = ->* 
#     while true
#         yield 1
    
# fo = BA!

# # console.log fo.next!,fo.next!
# cats = [] <| fo
 q
