dd = require 'dump-die'

###
# Used in the tests
#
# Sets up an express server and creates the Article model
# and a
###
exports = module.exports = (callback) ->
    EventEmitter = require 'events'
    events = new EventEmitter()

    # Set up the express app
    express = require 'express'
    app = express()

    # Enable body parser
    bodyParser = require 'body-parser'
    app.use bodyParser.urlencoded extended: false
    app.use bodyParser.json()

    # Set up the database
    mongoose = require 'mongoose'
    mockgoose = require 'mockgoose'
    Article = mongoose.model 'Article', new mongoose.Schema(
        title: String,
        body: String
    )
    mockgoose(mongoose).then ->
        mongoose.connect 'mongodb://non-existing-site.com', (err) ->
            events.emit 'mongoose loaded', err

    useResource = ->
        # Create resource for Article model
        resourcePebble = require '../src/resource'
        app.use new resourcePebble Article

    listen = ->
        # Listen for requests
        app.listen 5000, (err) ->
            events.emit 'express loaded', err

    events.on 'mongoose loaded', (err) ->
        if err?
            console.log 'Mongoose failed to load'
            throw err
        useResource()
        listen()

    events.on 'express loaded', (err) ->
        if err?
            throw err
        console.log 'Example app started on port ' + 5000

        callback
            port: 5000,
            app: app,
            mongoose: mongoose,
            models:
                Article: Article

# Run the server if file is directly executed
if process.argv[1] is __filename
    exports ->
