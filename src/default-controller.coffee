stripIllegal = require './stripIllegalFields'

###
# Use res.provide if available, otherwise fall back to regular json response
###
provide = (res, type, data) ->
    try
        if res.provide?
            return res.provide type, data
    catch err
        throw new Error "#{type} is not a registered response, but is required for resource-pebble"

    if type is 'success'
        res.status(200).json
            status: 200
            success: true
            data: data

    else if type is 'error'
        res.status(500).json
            status: 500
            success: false
            data: data

    else if type is 'created'
        res.status(201).json
            status: 201
            success: true
            data: data

    else if type is 'not found'
        res.status(404).json
            status: 404
            success: false
            data: data

    else throw new Error "Error in resource-pebble/default-controller. Response '#{type}' not defined."

###
# Constructor function for the default controller
###
controller = (Model) ->

    # GET /models/:id
    show: (req, res, next) ->
        Model.findById req.params.id, (err, data) ->
            if err?
                provide res, 'error', err
            else if data
                provide res, 'success', data
            else
                provide res, 'not found', data

    # GET /models
    all: (req, res, next) ->
        query = Model.find {}

        schema = Model.schema.tree

        Object.keys(schema).forEach (field) ->
            if schema[field].type and schema[field].type.schemaName is 'ObjectId'
                query.populate(field)

        query.exec (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

    # POST /models
    create: (req, res, next) ->
        instance = new Model stripIllegal req.body
        instance.save (err) ->
            if err?
                return provide res, 'error', err
            provide res, 'created', instance

    # PUT /models
    update: (req, res, next) ->
        Model.findOneAndUpdate req.params.id, stripIllegal(req.body), (err, data) ->
            if err?
                return provide res, 'error'
            provide res, 'success', data

    # DELETE /models/:id
    destroy: (req, res, next) ->
        Model.findOneAndRemove req.params.id, (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

module.exports = controller
