passport = require("passport")
us       = require("underscore")

module.exports.init = (allowed_domains) ->

  passport.serializeUser   (user, done) -> done null, user
  passport.deserializeUser (obj, done)  -> done null, obj

  GoogleStrategy = require("passport-google").Strategy
  passport.use new GoogleStrategy
    returnURL: process.env.GOOGLE_AUTH_REALM
    realm:     process.env.GOOGLE_AUTH_REALM
    (identifier, profile, done) ->
      email = profile.emails[0].value
      if us.indexOf(allowed_domains.split(","), email.split("@")[1]) > -1
        done null, email:email
      else
        done "invalid"

  authenticate = (req, res, next) ->
    protocol = req.headers['x-forwarded-proto'] || req.protocol
    url = "#{protocol}://#{req.headers.host}#{req.originalUrl}"
    passport._strategies.google._relyingParty.returnUrl = url
    passport.authenticate("google", failureRedirect:"auth/invalid") req, res, next

  authenticated: (req, res, next) ->
    url = req.url.split("?")[0]
    return next() if url is "/auth/google"
    return next() if url is "/auth/google/callback"
    return next() if url is "/auth/invalid"
    return next() if process.env.NODE_ENV is "development"
    return next() if req.isAuthenticated()
    req.session.desired = req.originalUrl
    res.redirect "auth/google"

  middleware: (app) ->
    app.use passport.initialize()
    app.use passport.session()

  routes: (app) ->
    app.get "/auth/google", authenticate, (req, res) ->
      if req.session.desired then res.redirect(req.session.desired) else res.redirect "../.."
    app.get "/auth/google/callback", authenticate, (req, res) ->
      res.redirect "../.."
    app.get "/auth/invalid", (req, res) ->
      res.status(403).send "invalid"
    app.get "/login", (req, res) ->
      req.session.desired = "../.."
      res.redirect "../auth/google"
    app.get "/logout", (req, res) ->
      req.logout()
      res.redirect "../.."
