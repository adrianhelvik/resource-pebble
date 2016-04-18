dd = require 'dump-die'
Router = require('express').Router
pluralize = require 'pluralize'

resource = (Model, options) ->

    router = new Router()

    # Options defaults to empty object
    if not options?
        options = {}

    # Controller defaults to default resource controller
    if options.controller?
        controller = options.controller
    else controller = require './default-controller'

    # Inject model if controller is a function/class,
    # otherwise it should be an object literal
    if typeof controller == 'function'
        controller = controller(Model)

    # Set up middleware object
    options.middleware = options.middleware or {}
    middleware = {}

    for method in ['all', 'show', 'update', 'create', 'destroy']
        if options.middleware[method]?
            middleware[method] = options.middleware[method]
        else middleware[method] = []

    pluralized = pluralize Model.modelName

    # Register the routes
    router.get "/#{pluralized}/:id", middleware.show, controller.show
    router.get "/#{pluralized}/", middleware.all, controller.all
    router.put "/#{pluralized}/:id", middleware.update, controller.update
    router.post "/#{pluralized}/", middleware.create, controller.create
    router.delete "/#{pluralized}/", middleware.destroy, controller.destroy

    # TODO: Add check for body-parser middleware

    # Return the router instance
    return router

module.exports = resource
