resource = (options) ->
    if options.controller?
        controller = options.controller
    else controller = require './default-controller'

    options.middleware = options.middleware or {}
    middleware = {}

    for method in ['all', 'get', 'update', 'create', 'destroy']
        if options.middleware[method]?
            middleware[method] = options.middleware[method]
        else middleware[method] = []

    (req, res, next) ->
        @get '/', middleware.all, controller.all
        @get '/:id', middleware.get, controller.get
        @put '/:id', middleware.update, controller.update
        @post '/', middleware.create, controller.create
        @delete '/', middleware.destroy, controller.destroy

        next()

module.exports = resource
