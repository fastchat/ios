var express = require('express');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var bcrypt = require('bcrypt');
var mongoose = require('mongoose');
var http = require('http');
var io = require('socket.io');
// better logging... https://github.com/LearnBoost/console-trace/pull/17/files
require('console-trace')({
  always: true,
})

var User = require('./user');

mongoose.connect( 'mongodb://localhost/dev' );
var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function callback() {
  console.log('Connected to DB');
});

// Passport session setup.
//   To support persistent login sessions, Passport needs to be able to
//   serialize users into and deserialize users out of the session.  Typically,
//   this will be as simple as storing the user ID when serializing, and finding
//   the user by ID when deserializing.
//
//   Both serializer and deserializer edited for Remember Me functionality
passport.serializeUser(function(user, done) {
  var createAccessToken = function () {
    var token = user.generateRandomToken();
    User.findOne( { accessToken: token }, function (err, existingUser) {
      if (err) { return done( err ); }
      if (existingUser) {
        createAccessToken(); // Run the function again - the token has to be unique!
      } else {
        user.set('accessToken', token);
        user.save( function (err) {
          if (err) return done(err);
          return done(null, user.get('accessToken'));
        })
      }
    });
  };

  if ( user._id ) {
    createAccessToken();
  }
});

passport.deserializeUser(function(token, done) {
  User.findOne( {accessToken: token } , function (err, user) {
    done(err, user);
  });
});

// Use the LocalStrategy within Passport.
//   Strategies in passport require a `verify` function, which accept
//   credentials (in this case, a username and password), and invoke a callback
//   with a user object.  In the real world, this would query a database;
//   however, in this example we are using a baked-in set of users.

passport.use(new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password'
  }, function(email, password, done) {
  User.findOne({ 'email': email }, function(err, user) {
    console.log("User: " + user);
    if (err) { return done(err); }
    if (!user) { return done(null, false, { message: 'Unknown user ' + email }); }
    user.comparePassword(password, function(err, isMatch) {
      if (err) return done(err);
      if(isMatch) {
        return done(null, user);
      } else {
        return done(null, false, { message: 'Invalid password' });
      }
    });
  });
}));

var app = express();
// Create HTTP server on port 3000 and register socket.io as listener
server = http.createServer(app)
server.listen(3000);
io = io.listen(server);

app.set('port', process.env.PORT || 3000);
//app.set('views', path.join(__dirname, 'views'));
//app.set('view engine', 'ejs');
//app.engine('ejs', require('ejs-locals'));
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.cookieParser('special turkey sauce is good'));
app.use(express.session());
app.use(passport.initialize());
app.use(passport.session());
app.use(app.router);

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}


// POST /login
// This is an alternative implementation that uses a custom callback to
// acheive the same functionality.
app.post('/login', function(req, res, next) {
  console.log('Logging in user');
  console.log('Info: ' + JSON.stringify(req.body, null, 4));
  passport.authenticate('local', function(err, user, info) {
    console.log('Error: ' + err);
    console.log('user: ' + user);
    console.log('INFO: ' + info);
    if (err) { return next(err) }
    if (!user) {
      req.session.messages = [info.message];
      //return error
//      return res.redirect('/login')
    }
    req.logIn(user, function(err) {
      if (err) { return next(err); }
      res.send( {'session-token': user.get('accessToken')} );
      
//      return res.redirect('/admin');
    });
  })(req, res, next);
});

// POST Register
app.post('/register', function(req, res) {
  console.log('Body: ' + JSON.stringify(req.body, null, 4));
  User.newUser(req.body.email, req.body.password, function(err, user) {
    if(err) {
      console.log(err);
      req.session.messages = [err.message];
      return res.redirect('/register');
    } else {
      console.log('user: ' + user.email + " saved.");
      res.send({'user':user.email});
    }
  });
});

app.get('/secret', ensureAuthenticated, function(req, res) {
  console.log('Get Secret');
  res.send({'ok':'you win.'});
});


// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
function ensureAuthenticated(req, res, next) {
  if ( req.isAuthenticated() ) {
    return next();
  } else {
    console.log('Checking ' + JSON.stringify(req.headers, null, 4));
    if (req.headers['session-token'] !== undefined) {
      console.log('Found header!');
      var token = req.headers['session-token'];
      console.log('Found token: ' + token);
      User.findOne( { accessToken: token }, function (err, usr) {
	console.log('User: ' + usr);
	if (usr && !err) {
	  return next();
	} else {
	  //401
	  res.send(401);
	}
      });
    } else {
      //401
      res.send(401);
    }
  }
}


///
/// Setup Socket IO
///
io.configure(function (){
  io.set('authorization', function (handshakeData, callback) {
    console.log('AUTHORIZED ACTIVATED: ' + JSON.stringify(handshakeData, null, 4));
    // findDatabyip is an async example function
    var token = handshakeData.query.token;

    if (!token) return callback(new Error('You must have a session token!'));
    
    console.log('TokeN???? ' + token);
    User.findOne( { accessToken: token }, function (err, usr) {
    console.log('Found: ' + err + ' Usr: ' + usr);
      
      if (err) return callback(err);

      if (usr) {
	console.log('SUCCESSFUL SOCKET AUTH');
	callback(null, true);
      } else {
        callback(null, false);
      }
    });
  });
});

io.on('connection', function (socket) {
  console.log('Connection');
  socket.emit('data', 'LOGGED IN');

  socket.on('disconnect', function() {
  })
  
});
