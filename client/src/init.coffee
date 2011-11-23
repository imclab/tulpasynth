###
#   @file       init.coffee
#
#               This file contains initialization code for various
#               things.  It is the first file loaded.
#
#   @author     Colin Sullivan <colinsul [at] gmail.com>
#
#               Copyright (c) 2011 Colin Sullivan
#               Licensed under the MIT license.
###


# Global namespace
window.hwfinal = {
    views: {
        instrumentcontrollers: {}
    },
    models: {
        instruments: {}
    },
    # Our `SocketHelper` instance
    socket: null,
    # Our `Orchestra` instance
    orchestra: null,
}

$(document).ready () ->
    
    # Set up error handler
    window.onerror = (e) ->
        $('#info').text e

    # Create our singleton `Orchestra` instance
    hwfinal.orchestra = new hwfinal.models.Orchestra
        id: 1
    
    # Create our singleton `Timeline` view
    hwfinal.timeline = new hwfinal.views.Timeline()

    # Start listening on our socket
    hwfinal.socket = new hwfinal.SocketHelper 'ws://128.12.201.51:9090'

    hwfinal.socket.onready = () ->
        for i in [
            0.0546875,
            0.166015625,
            0.27734375,
            0.388671875,
            0.5,
            0.611328125,
            0.72265625,
            0.833984375,
            0.9453125]

            glitchInstance = new hwfinal.models.instruments.Glitch
                startTime: i
                disabled: true
            glitchInstance.save()

            hwfinal.orchestra.get('instruments').add glitchInstance




#         glitches[i] = 
#             disabled: true
#             onTime: (leftValue + (glitchElement.width()/2))/1024
#             id: i
#             el: glitchElement
        
#         console.log glitches[i].onTime
        
#         glitchElement.data({'glitchId': i});

#         # Tell server to create glitch instrument with given properties
#         # glitch = glitches[i]
#         # message = 
#         #     type: 'glitchCreate'
#         #     id: glitch.id
#         #     onTime: glitch.onTime
#         #     disabled: glitch.disabled
#         # socket.send JSON.stringify message

#         glitchElement.click () ->
#             glitchElement = $(this)
#             glitch = glitches[glitchElement.data('glitchId')]

#             message = 
#                 type: 'glitchUpdate'
#                 id: glitch.id

#             if glitch.disabled
#                 glitch.disabled = false
#                 glitchElement.removeClass 'disabled'

#             else
#                 glitch.disabled = true
#                 glitchElement.addClass 'disabled'

#             # Update server
#             message.disabled = glitch.disabled
#             socket.send JSON.stringify message
