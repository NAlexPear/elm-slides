var Elm = require('./Main');
var hljs = require('highlight.js');

require('milligram');
require('highlight.js/styles/github-gist.css');
require('./main.css');

var app = Elm.Main.fullscreen();

app.ports.highlight.subscribe(() => setTimeout(
  () => document
    .querySelectorAll('code')
    .forEach(hljs.highlightBlock)
  , 50)
);
