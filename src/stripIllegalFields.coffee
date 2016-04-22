stripIllegalFields = (object, currentDepth = 0) ->

    if currentDepth > 200
        console.log currentDepth, object
        throw new Error 'Recursive object can not be sent as json'

    if typeof object != 'object'
        return object

    result = {}

    for key, value of object
        if key not in ['_id', '__v']
            result[key] = stripIllegalFields value, currentDepth + 1
        
    return result

module.exports = stripIllegalFields
