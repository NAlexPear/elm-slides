var Elm = require('./Main');
var hljs = require('highlight.js');
var { WebAuth } = require('auth0-js')

require('milligram');
require('highlight.js/styles/github-gist.css');
require('./main.css');

var auth = new WebAuth({
  domain: 'alexpear.auth0.com',
  clientID: 'iM3Hxdh3Bj2Ui3Cu92OpjyJCZIDmVgio',
  audience: 'https://alexpear.auth0.com/userinfo',
  scope: 'openid',
  redirectUri: `${window.location.origin}/verify`
});

var app = Elm.Main.fullscreen();

app.ports.highlight.subscribe(() => setTimeout(
  () => document
    .querySelectorAll('code')
    .forEach(hljs.highlightBlock)
  , 50)
);

app.ports.authorize.subscribe(() => {
  localStorage.setItem('previousDeck', window.location.pathname);

  auth.authorize({
    responseType: "token"
  });
});

app.ports.getToken.subscribe(() => auth.parseHash((err, { accessToken: token }) => {
  var payload = {
    token,
    previousDeck: localStorage.getItem('previousDeck')
  }

  if(err){
    payload = err;
  }

  app.ports.newToken.send(payload)
}))
