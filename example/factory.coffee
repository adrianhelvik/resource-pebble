async = require 'async'

###
# A factory for factories
###
Factory = (createSingle) ->
    factory = (count) ->
        if not count or count < 0
            count = 1

        arr = []

        for i in [1..count]
            arr.push createSingle()

        if arr.length is 1
            return arr[0]
        
        arr

    factory.save = (count, done) ->
        created = factory count

        if Array.isArray created
            created.forEach (model) ->
                model.save()
        else
            created.save()

        return created

    return factory

module.exports = Factory
