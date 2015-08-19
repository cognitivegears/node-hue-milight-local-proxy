ssdp.litcoffee
=================

This is the SSDP discovery mechanism for node-hue-milight-local-proxy
This class is responsible for listening to "hue" discovery requests
and locating the /description.xml

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

    ssdp = require('peer-ssdp')
    interval = null
    ssnpMessage = {
      ST: 'urn:Belkin:device:**'
      LOCATION: 'http://10.0.1.29:8080/upnp/amazon-ha-bridge/setup.xml'
      OPT: '"http://schemas.upnp.org/upnp/1/0/\"; ns=01'
      USN: 'uuid:Socket-1_0-221438K0100073::urn:Belkin:device:**'
    }


Server setup
------------

Define a main runWith() module to handle the server creation -
dispatched from the main node-milight-local-proxy.js executable

    exports.runWith = (args) ->
      peer = ssdp.createPeer()
      peer.on('ready', () ->
        console.log('IN ready method')
        interval = setInterval( ()->
          peer.alive(ssnpMessage)
        , 1000)
      )

      peer.on('search', (headers, address)->
        console.log("In search method")
        peer.reply(ssnpMessage, address)
      )

      peer.start()

      #server.addUSN('urn:Belkin:device:**')
      #server.addUSN('uuid:Socket-1_0-221438K0100073::urn:Belkin:device:**')
      # server.addUSN('upnp:rootdevice')
      # server.addUSN('urn:schemas-upnp-org:device:basic:1')

Initialize the restify server

      #server.on('advertise-alive', (headers) -> {
        # Expire old devices from your cache.
      #})

      #server.on('advertise-bye', (headers) -> {
        # Remove specified device from cache.
      #})

Start the server

      #server.start("239.255.255.250")
