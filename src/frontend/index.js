var Elm = require('./Main');
var hljs = require('highlight.js');
var { WebAuth } = require('auth0-js');
var jwtDecode = require('jwt-decode');

require('milligram');
require('highlight.js/styles/github-gist.css');
require('./main.css');

var auth = new WebAuth({
  domain: 'alexpear.auth0.com',
  clientID: 'iM3Hxdh3Bj2Ui3Cu92OpjyJCZIDmVgio',
  audience: 'https://alexpear.auth0.com/userinfo',
  scope: 'openid profile',
  redirectUri: `${window.location.origin}/verify`
});

var isExpired = localStorage.getItem('expiresAt') > new Date().getTime();
var token = !isExpired && localStorage.getItem('token') || null;
var name = token && jwtDecode(token)['given_name'] || ''

var app = Elm.Main.fullscreen({ name, token });

app.ports.highlight.subscribe(() => setTimeout(
  () => document
    .querySelectorAll('code')
    .forEach(hljs.highlightBlock)
  , 50)
);

app.ports.authorize.subscribe(() => {
  localStorage.setItem('previousDeck', window.location.pathname);

  auth.authorize({
    responseType: 'id_token'
  });
});

app.ports.clearToken.subscribe(() => {
  localStorage.removeItem('token');
  localStorage.removeItem('expiresAt');
})

app.ports.getToken.subscribe(() => auth.parseHash(
  (err, { idToken: token, expiresIn }) => {
    var payload = {
      name: jwtDecode(token)['given_name'],
      token,
      previousDeck: localStorage.getItem('previousDeck')
    }

    if(err){
      payload = err;
    }

    localStorage.setItem('token', token);
    localStorage.setItem('expiresAt', JSON.stringify(expiresIn * 1000 + new Date().getTime())); 

    app.ports.newToken.send(payload)
  })
)

