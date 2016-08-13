Router = require('express').Router
pluralize = require 'pluralize'
paramCase = require 'param-case'

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

    pluralized = paramCase pluralize Model.modelName

    # Parse options.only
    if not options.only?
        options.only = ['show', 'all', 'create', 'update', 'destroy']
    only = {}
    for method in options.only
        only[method] = true

    # Register the routes
    only.show    and router.get    "/#{pluralized}/:id", middleware.show,    controller.show
    only.all     and router.get    "/#{pluralized}/",    middleware.all,     controller.all
    only.update  and router.put    "/#{pluralized}/:id", middleware.update,  controller.update
    only.create  and router.post   "/#{pluralized}/",    middleware.create,  controller.create
    only.destroy and router.delete "/#{pluralized}/:id",    middleware.destroy, controller.destroy

    # TODO: Register nested resources for Arrays and ObjectID's

    # TODO: Add check for body-parser middleware

    # Return the router instance
    return router

module.exports = resource
