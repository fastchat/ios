var mongoose = require('mongoose')
  , Schema = mongoose.Schema
  , bcrypt = require('bcrypt')
  , SALT_WORK_FACTOR = 10;

///
/// User should probably own an account object? Or somethign that organizes all account info
///
var User = new Schema({
  email: {type: String, required: true, unique: true},
  password: {type: String, required: true},
  accessToken: {type: String} //For Remember me
});

// Bcrypt middleware
User.pre('save', function(next) {
  var user = this;
  
  if(!user.isModified('password')) return next();

  bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
    if(err) return next(err);
    
    bcrypt.hash(user.password, salt, function(err, hash) {
      if(err) return next(err);
      user.password = hash;
      next();
    });
  });
});

// cb(err, user)
User.statics.newUser = function(email, password, cb){
  
  // Create the home world .... somewhere
  var usr = new this({ 'email': email, 'password': password });
  usr.save(function(err) {
    if(err) {
      console.log(err);
      cb(err, null);
    } else {
      console.log('user: ' + usr.email + " saved.");
      cb(null, usr);
    }
  });
};

// Password verification
User.methods.comparePassword = function(candidatePassword, cb) {
  bcrypt.compare(candidatePassword, this.password, function(err, isMatch) {
    if(err) return cb(err);
    cb(null, isMatch);
  });
};

// Remember Me implementation helper method
User.methods.generateRandomToken = function () {
  var user = this,
  chars = "_!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
  token = new Date().getTime() + '_';
  for ( var x = 0; x < 16; x++ ) {
    var i = Math.floor( Math.random() * 62 );
    token += chars.charAt( i );
  }
  return token;
};

module.exports = mongoose.model('User', User);