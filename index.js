var Elm = require('./Main');
var hljs = require('highlight.js');

require('milligram');
require('highlight.js/styles/github-gist.css');
require('./main.css');

window.hljs = hljs;

Elm.Main.fullscreen();
