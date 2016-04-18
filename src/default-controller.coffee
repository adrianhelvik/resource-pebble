stripIllegal = require './stripIllegalFields'

# Use res.provide if available,
# otherwise fall back to regular json response
provide = (res, type, data) ->
    if res.provide?
        res.provide type, data

    else if type is 'success'
        res.status(200).json
            success: true,
            data: data

    else if type is 'error'
        res.status(500).json
            success: false,
            data: data

controller = (Model) ->

    show: (req, res, next) ->
        Model.findById req.params.id, (err, data) ->
            if err?
                return provide res, 'error', err
            provide res, 'success', data
            
    all: (req, res, next) ->
        Model.find {}, (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

    create: (req, res, next) ->
        instance = new Model stripIllegal req.body
        instance.save (err) ->
            return provide res, 'error', err if err?
            provide res, 'success', instance

    update: (req, res, next) ->
        Model.findOneAndUpdate req.params.id, stripIllegal(req.body), (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

    destroy: (req, res, next) ->
        Model.findOneAndRemove req.params.id, (err, data) ->
            return provide res, 'error', err if err?
            provide res, 'success', data

module.exports = controller
