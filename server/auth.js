var express = require('express');
var app = express();
var MongoStore = require('connect-mongo')(express);


// Dev
app.configure('development', function() {
  app.set('db-uri', 'mongodb://localhost/dev');
  app.use(express.errorHandler({ dumpExceptions: true }));
  app.set('view options', {
    pretty: true
  });
});


// App setup
app.use(express.cookieParser());
app.use(express.session({
  secret: 'woot a secret',
  store: new MongoStore({
    url: app.set('db-uri')
  })
}));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);

var server = app.listen(3000, function() {
    console.log('Listening on port %d', server.address().port);
});



function checkAuth(req, res, next) {
  if (!req.session.user_id) {
    res.send('You are not authorized to view this page');
  } else {
    next();
  }
}


// Routes
app.get('/my_secret_page', checkAuth, function (req, res) {
  res.send('if you are viewing this page it means you are logged in');
});

app.post('/login', function (req, res) {
  console.log('Req ' + JSON.stringify(req.body, null, 4));
  var post = req.body;
  if (post.user == 'john' && post.password == 'johnspassword') {
    req.session.user_id = '10';
    res.redirect('/my_secret_page');
  } else {
    res.send('Bad user/pass');
  }
});

app.get('/logout', function (req, res) {
  delete req.session.user_id;
  res.redirect('/login');
});
