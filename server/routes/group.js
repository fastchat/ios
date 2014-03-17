var User = require('../model/user');
var Group = require('../model/group');


exports.getGroups = function(req, res) {
  User.fromToken( req.headers['session-token'], function (usr) {
    Group.find( { 'members' : usr._id }, function(err, groups) {
      if (err) res.send(500, {'error' : 'string'});
      res.send(groups);
    });    
  });
};

exports.createGroup = function(req, res) {
  User.fromToken( req.headers['session-token'], function (usr) {
    
    Group.newGroup(req.body, usr, function(err, group) {
      if (err) return res.send(400, {error: err});

      res.send(group);	       
    });
  });
};

exports.deleteGroup = function(req, res) {

};

exports.changeSettings = function(req, res) {

};

exports.invite = function(req, res) {

};

