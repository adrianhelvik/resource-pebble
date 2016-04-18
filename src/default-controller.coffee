stripIllegal = require './stripIllegalFields'

###
# Use res.provide if available, otherwise fall back to regular json response
###
provide = (res, type, data) ->
    try
        if res.provide?
            res.provide type, data

        else if type is 'success'
            res.status(200).json
                status: 200,
                success: true,
                data: data

        else if type is 'error'
            res.status(500).json
                status: 500,
                success: false,
                data: data
    catch err
        throw new Error "#{type} is not a registered response, but is required for resource-pebble"

###
# Constructor function for the default controller
###
controller = (Model) ->

    # GET /models/:id
    show: (req, res, next) ->
        Model.findById req.params.id, (err, data) ->
            if err?
                return provide res, 'error', err
            provide res, 'success', data
            
    # GET /models
    all: (req, res, next) ->
        Model.find {}, (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

    # POST /models
    create: (req, res, next) ->
        instance = new Model stripIllegal req.body
        instance.save (err) ->
            return provide res, 'error', err if err?
            provide res, 'success', instance

    # PUT /models
    update: (req, res, next) ->
        Model.findOneAndUpdate req.params.id, stripIllegal(req.body), (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

    # DELETE /models/:id
    destroy: (req, res, next) ->
        Model.findOneAndRemove req.params.id, (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

module.exports = controller
