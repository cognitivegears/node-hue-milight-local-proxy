#!/usr/bin/env node

var path = require('path');
var fs   = require('fs');
var lib  = path.join(path.dirname(fs.realpathSync(__filename)), 'lib');

require(lib + '/command').runWith(arguments);

require(lib + '/ssdp').runWith(arguments);
