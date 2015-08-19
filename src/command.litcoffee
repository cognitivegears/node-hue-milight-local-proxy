command.litcoffee
=================

This is the main command dispatcher for node-hue-milight-local-proxy
This class is responsible for listening to "hue" API for mi-light commands 
and dispatching them to the appropriate functions.

Copyright
=========

Copyright (c) 2015 Nathan Byrd. All Rights Reserved.

This file is part of node-hue-milight-local-proxy.

node-hue-milight-local-proxy is free software: you can redistribute it and/or 
modify it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

node-hue-milight-local-proxy is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with node-hue-milight-local-proxy.  If not, see 
[gnu.org](http://www.gnu.org/licenses/).

Code
====

First, require some needed modules and setup globals

    restify = require 'restify'
    Milight = require('node-milight-local-promise').MilightLocalController
    commands = require('node-milight-local-promise').commands
    extend = require 'extend'

    Logger = require 'bunyan'

    log = new Logger.createLogger {
      name: 'node-hue-milight-local',
      serializers: {
        req: Logger.stdSerializers.req
      }
    }

Server settings
---------------

Change these settings as needed to match your configuration.

The following controls the port and IP address the proxy listens on.

    PROXY_PORT = 8080
    PROXY_IP = ''

Serial settings
---------------

Change these settings as needed to match your configuration.

    TTL_PORT = "/dev/ttyAMA0"
    TTL_SPEED = 9600


description.xml
---------------

This is the description.xml used for discovery

    descriptionXml = '''
      <root xmlns="urn:schemas-upnp-org:device-1-0">
      <specVersion>
      <major>1</major>
      <minor>0</minor>
      </specVersion>
      <URLBase>http://10.0.1.29:8080/</URLBase>
      <device>
      <deviceType>urn:schemas-upnp-org:device:Basic:1</deviceType>
      <friendlyName>Philips hue (192.168.0.21)</friendlyName>
      <manufacturer>Royal Philips Electronics</manufacturer>
      <manufacturerURL>http://www.philips.com</manufacturerURL>
      <modelDescription>Philips hue Personal Wireless Lighting</modelDescription>
      <modelName>Philips hue bridge 2012</modelName>
      <modelNumber>1000000000000</modelNumber>
      <modelURL>http://www.meethue.com</modelURL>
      <serialNumber>93eadbeef13</serialNumber>
      <UDN>uuid:01234567-89ab-cdef-0123-456789abcdef</UDN>
      <serviceList>
      <service>
      <serviceType>(null)</serviceType>
      <serviceId>(null)</serviceId>
      <controlURL>(null)</controlURL>
      <eventSubURL>(null)</eventSubURL>
      <SCPDURL>(null)</SCPDURL>
      </service>
      </serviceList>
      <presentationURL>index.html</presentationURL>
      <iconList>
      <icon>
      <mimetype>image/png</mimetype>
      <height>48</height>
      <width>48</width>
      <depth>24</depth>
      <url>hue_logo_0.png</url>
      </icon>
      <icon>
      <mimetype>image/png</mimetype>
      <height>120</height>
      <width>120</width>
      <depth>24</depth>
      <url>hue_logo_3.png</url>
      </icon>
      </iconList>
      </device>
      </root>
    '''

Server setup
------------

Define a main runWith() module to handle the server creation -
dispatched from the main node-milight-local-proxy.js executable

    exports.runWith = (args) ->

Setup the milight object for sending commands

      light = new Milight {compatMode: false, delayBetweenCommands: 110, commandRepeat: 1, ttlPort: TTL_PORT, ttlSpeed: TTL_SPEED}


Initialize the restify server

      server = restify.createServer(log: log)
      server.use restify.bodyParser()
      server.listen PROXY_PORT, () -> {
      }
      console.log "Server started on " + PROXY_PORT


Define a lamp state structure - *NOTE* for now, this only stays for as long as 
the server is alive, we may investigate permanent storage later

      lightState = [
        {state: {on: false, bri: 0, hue: 15331, sat: 121, xy: [0.4448, 0.4066], ct: 343, alert: "none", effect: "none", colormode: "ct", reachable: true}, type: "Extended color light", name: "Living Room", modelid: "LCT001", swversion: "65003148", pointsymbol: {}},
        {state: {on: false, bri: 0, hue: 15331, sat: 121, xy: [0.4448, 0.4066], ct: 343, alert: "none", effect: "none", colormode: "ct", reachable: true}, type: "Extended color light", name: "Hue Lamp 2", modelid: "LCT001", swversion: "65003148", pointsymbol: {}},
        {state: {on: false, bri: 0, hue: 15331, sat: 121, xy: [0.4448, 0.4066], ct: 343, alert: "none", effect: "none", colormode: "ct", reachable: true}, type: "Extended color light", name: "Hue Lamp 3", modelid: "LCT001", swversion: "65003148", pointsymbol: {}},
        {state: {on: false, bri: 0, hue: 15331, sat: 121, xy: [0.4448, 0.4066], ct: 343, alert: "none", effect: "none", colormode: "ct", reachable: true}, type: "Extended color light", name: "Hue Lamp 4", modelid: "LCT001", swversion: "65003148", pointsymbol: {}}
      ]

Now define our paths

User registration
-----------------

Return the description.xml for discovery

      server.get '/upnp/amazon-ha-bridge/setup.xml', (req, res, next) ->
        console.log('RETURNING SETUP.XML')
        res.writeHead(200, {
          'Content-Length': Buffer.byteLength(descriptionXml)
          'Content-Type': 'application/xml'
        })
        res.write(descriptionXml)
        res.end()
     

Allow registration of any user *TODO* Actually track registrations

      server.post '/api', (req, res, next) ->
        console.log "Registration request performed."
        res.json {success: {username: req.body.username}}


Get a list of lights supported by the API.  Since milight supports 4 channels, 
we will pretend like we have 4 lights.

      server.get '/api/:userId/lights', (req, res, next) ->
        console.log "hue lights list requested for userId: " + req.params.userId
        res.json {"1": "Living Room", "2": "Hue Lamp 2", "3": "Hue Lamp 3", "4": "Hue Lamp 4"}



      server.get '/api/:userId', (req, res, next) ->
        console.log "hue api root requested for userId: " + req.params.userId
        lightResponse = {
          "1" : lightState[0]
          "2" : lightState[1]
          "3" : lightState[2]
          "4" : lightState[3]
        }
        res.json {
          lights: lightResponse
        }

      server.get '/api/:userId/lights/:lightId', (req, res, next) ->
        console.log "hue light requested: " + req.params.lightId
        res.json lightState[req.params.lightId-1]

      server.put '/api/:userId/lights/:lightId/state', (req, res, next) ->
        console.log "hue state change requested for light: " + req.params.lightId
        requestBody = req.body
        if req.is('application/x-www-form-urlencoded')
          requestBody = JSON.parse(requestBody)
        console.log req.body
        cmdResults = []
        if requestBody.on?
          if requestBody.on
            console.log "Turning on light"
            light.sendCommands commands.rgbw.on(req.params.lightId)
            lightState[req.params.lightId-1].state.on=true
            cmdResults.push {"success": {"/lights/#{req.params.lightId}/state/on": true}}
          else
            console.log "Turning off light"
            light.sendCommands commands.rgbw.off(req.params.lightId)
            lightState[req.params.lightId-1].state.on=false
            cmdResults.push {"success": {"/lights/#{req.params.lightId}/state/on": false}}
        if requestBody.bri? and lightState[req.params.lightId-1].state.on
          brightness = Math.floor((requestBody.bri / 254) * 100)
          console.log "Setting brightness to #{brightness}"
          light.sendCommands(commands.rgbw.on(req.params.lightId), commands.rgbw.brightness(brightness))
          cmdResults.push {"success": {"/lights/#{req.params.lightId}/state/bri": requestBody.bri}}

        extend(true, lightState[req.params.lightId-1].state, requestBody)
        res.json cmdResults

Finally, add common headers to responses

      server.use (req, res, next) ->
        res.header 'Cache-Control', "no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
        res.header 'Pragma', 'no-cache'
        res.header 'Expires', "Mon, 1 Aug 2011 09:00:00 GMT"
        res.header 'Connection', "close"
        res.header 'Access-Control-Max-Age', '0'
        res.header "Access-Control-Allow-Origin", "*"
        res.header "Access-Control-Allow-Credentials", "true"
        res.header "Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE"
        res.header "Access-Control-Allow-Headers", "Content-Type"
        next()

      server.pre (req, res, next) ->
        console.log "command called"
        req.log.info {req: req}, 'REQUEST'
        next()

