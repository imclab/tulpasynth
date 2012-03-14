#!/usr/bin/env coffee

colors = require "colors"
net = require "net"
redis = require "redis"
WebSocket = require "faye-websocket"
http = require "http"
argv = require("optimist").argv;
_ = require("underscore")._;

tulpasynth = require "./lib/tulpasynth.coffee"
require "./lib/ShooterModel.coffee"



console.log "
 __          __                                     __   __    \n
|  |_.--.--.|  |.-----..---.-..-----..--.--..-----.|  |_|  |--.\n
|   _|  |  ||  ||  _  ||  _  ||__ --||  |  ||     ||   _|     |\n
|____|_____||__||   __||___._||_____||___  ||__|__||____|__|__|\n
                |__|                 |_____|                   \n

".bold

SERVER_IP = argv.address || "128.12.158.62"
SERVER_PORT = argv.port || 6666

debugMsg = (msg) ->
    console.log "info".cyan+" - "+msg

errorMsg = (msg) ->
    console.log "error".bold.red+" - "+msg

###
#   Maintain a list of currently open connections, identified by an arbitrary
#   counter.
###
connectionId = 1
openConnections = []

serverStartTime = new Date();

offsetTimeAttributes = (data, attributesToOffset, offsetAmt) ->
    dataClone = _.clone data
    dataClone.attributes = _.clone data.attributes
    if attributesToOffset
        for timeOffsetAttribute in attributesToOffset
            attribute = dataClone.attributes[timeOffsetAttribute]
            if _.isArray attribute
                newArray = []
                for value in attribute
                    newArray.push value-offsetAmt
                dataClone.attributes[timeOffsetAttribute] = newArray
            else
                attribute -= offsetAmt

    dataClone

sendToAll = (data, timeOffsetAttributes) ->
    debugMsg "Sending to all:"
    console.log data

    for connectionId, client of openConnections
        debugMsg "To client #{connectionId} with offset #{client.timeOffset}"
        client.send JSON.stringify(offsetTimeAttributes(data, timeOffsetAttributes, client.timeOffset))

sendToAllButOne = (data, one, timeOffsetAttributes) ->
    debugMsg "Sending to all but one:"
    console.log data

    for connectionId, client of openConnections
        if client != one
            client.send JSON.stringify(offsetTimeAttributes(data, timeOffsetAttributes, client.timeOffset))

sendToOne = (data, one, timeOffsetAttributes) ->
    debugMsg "Sending to one:"
    console.log data

    debugMsg "To client #{one.connectionId} with offset #{one.timeOffset}"
    one.send JSON.stringify(offsetTimeAttributes(data, timeOffsetAttributes, one.timeOffset))

unpauseAll = () ->
    # Unpause all clients
    message = 
        method: "unpause"

    sendToAll message


db = redis.createClient()
db.on "ready", () ->
    debugMsg "Redis connection ready"

    if not db.exists("next_id")
        db.set("next_id", "1")


    server = http.createServer();

    server.addListener 'upgrade', (request, socket, head) ->
        ws = new WebSocket request, socket, head
        ws.connectionId = connectionId
        openConnections[connectionId++] = ws

        ws.timeOffset = 0.0
        ws.timeSyncMessages = []

        ws.onopen = (event) ->
            debugMsg "Client #{ws.connectionId} connected"
            debugMsg "#{Object.keys(openConnections).length} connections now open"

            # # Get current state
            # db.hgetall "model", (err, obj) ->
            #     if err
            #         throw err
                
            #     console.log 'obj'
            #     console.log obj

            #     for id, model of obj
            #         message = JSON.parse(model)
            #         message.method = "create"
            #         ws.send JSON.stringify(message)
                    
                

        ws.onmessage = (event) ->
            data = JSON.parse(event.data)

            if data.time
                temp = new Date()
                temp.setTime(data.time*1000)
                data.time = temp

            debugMsg "Data received:"
            console.log data

            response = {}

            if data.method == "request_id"
                response.method = "response_id"

                # Get next id
                db.get "next_id", (err, nextId) =>
                    response.id = nextId

                    # Increment next id
                    db.incr("next_id")
            
                    sendToOne response, ws

            
            else if data.method == "create"
                # Store data in redis
                delete data.method
                debugMsg "Storing model #{data.attributes.id}"
                db.hmset "model", "#{data.attributes.id}", JSON.stringify(data)

                # If this is a shooter model, we'll need to synchronize
                # shooting times.
                if data.class is "ShooterModel"
                    debugMsg "Creating a ShooterModel on server"

                    # Offset shoot times based on this client's time offset
                    # amount, putting the shotTimes in server time
                    console.log 'data.attributes.shotTimes'
                    console.log data.attributes.shotTimes
                    
                    compensatedShotTimes = []
                    for shotTime in data.attributes.shotTimes
                        compensatedShotTimes.push shotTime+ws.timeOffset

                    data.attributes.shotTimes = compensatedShotTimes
                    console.log 'data.attributes.shotTimes'
                    console.log data.attributes.shotTimes
                    

                    shooter = new tulpasynth.models.ShooterModel data.attributes

                    # data.attributes.nextShotTime = shooter.get("nextShotTime")

                    # Update initial client
                    data.method = "update"
                    sendToOne data, ws, ["shotTimes"]

                    # When shooter updates the next shot time
                    shooter.on "change:shotTimes", () =>
                        # Inform all clients
                        message =
                            method: "update"
                            class: "ShooterModel"
                            attributes: shooter.toJSON()
                        sendToAll message, ["shotTimes"]

                    # Relay create message to other connected clients
                    data.method = "create"
                    sendToAllButOne data, ws, ["shotTimes"]

                    # start updating shot times
                    shooter.updateNextShotTimes()

                # Other models, just relay message
                else
                    
                    data.method = "create"
                    sendToAllButOne data, ws



                # unpauseAll()


            
            else if data.method == "update"
                # Update data in redis
                delete data.method
                debugMsg "Updating model #{data.attributes.id}"

                db.hmset "model", "#{data.attributes.id}", JSON.stringify(data)

                if tulpasynth.modelInstances[data.attributes.id]
                    instance = tulpasynth.modelInstances[data.attributes.id]
                    if data.class is "ShooterModel"
                        # delete data.attributes.nextShotTime

                        # If rate has not changed
                        if data.attributes.rate == instance.get "rate"
                            # ignore shot times
                            delete data.attributes.shotTimes

                    instance.set data.attributes

                # Relay update message to other connected clients
                data.method = "update"
                sendToAllButOne data, ws

                # unpauseAll()
            else if data.method == "time_sync"
                # Record time received
                time_received = new Date()
                data.time_received = (time_received.getTime()/1000.0)
                ws.timeSyncMessages.push data

                if ws.timeSyncMessages.length == 10
                    # Determine time offset of this client
                    latencySum = 0.0
                    for timeSyncMessage in ws.timeSyncMessages
                        latencySum += timeSyncMessage.time_received - timeSyncMessage.time_sent

                    ws.timeOffset = latencySum / ws.timeSyncMessages.length
                    console.log 'ws.timeOffset'
                    console.log ws.timeOffset

                # send back
                sendToOne data, ws

                



        
        # ws.send event.data

        ws.onclose = (event) ->
            debugMsg "Client #{ws.connectionId} disconnected"
            delete openConnections[ws.connectionId]
            debugMsg "#{Object.keys(openConnections).length} connections now open"
            ws = null
    
    server.on "listening", () ->
        debugMsg "Server listening on #{SERVER_IP}:#{SERVER_PORT}"

    server.on "error", (e) ->
        if e.code == "EADDRINUSE"
            errorMsg "Address in use error."
            # setTimeout () ->
            #     try
            #         server.close()
            #     catch error
            #         return
            #     finally
            #         server.listen 6666, "128.12.158.62"
            # , 1000
    
    debugMsg "Attempting to listen on #{SERVER_IP}:#{SERVER_PORT}"
    server.listen SERVER_PORT, SERVER_IP

db.on "error", () ->
    console.log "Redis connection error"


# console.log "   info  - ".cyan + "Opening socket on port 6666"
# io = require("socket.io").listen(6666)

# io.sockets.on "connection", (socket) ->
#     socket.on "msg", () ->
#         console.log "message received"



# socket = ws.createServer()
#     # debugMsg: true
#     # version: "draft75"

# socket.addListener "connection", (connection) ->
    
#     console.log "Connection established"

#     connection.addListener "message", (msg) ->
#         console.log "Message received: #{msg}"

# socket.listen(6666);

    


#     server = net.createServer (socket) ->
#         console.log "Client connected"

#         socket.on "end", () ->
#             console.log "Client disconnected"
        
#         socket.on "data", (data) ->


#     server.listen 6666, () ->
#         console.log "Listening on 6666"

