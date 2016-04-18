stripIllegalFields = (object) ->

    if typeof object != 'object'
        return object

    result = {}

    for key, value of object
        if key not in ['_id', '__v']
            result[key] = stripIllegalFields value
        
    return result

module.exports = stripIllegalFields
