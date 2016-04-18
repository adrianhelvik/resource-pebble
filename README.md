This module greatly simplify rest API creation. Supply the constructor with
a mongoose model and an express router is generated from the plural name of
the model. Given a model named Article, app.use(resource(Article)) will
generate all the routes listed below. (With no authentication)

Controller to route relation
----------------------------

(models being the lowercase plural form of the given model name)

* show: GET /models/:id
* all: GET /models
* create: POST /models
* update: PUT /models/:id
* destroy: DELETE /models/:id

Dependencies
------------

* body-parser or similar middleware

API
---

app.use(resourcePebble(Model:mongoose Model, [options:object]))

### options.controller: class(Model: mongoose model)|function(Model:mongoose model)

Swap out the default controller with another controller.
The constructor should accept a Model parameter, which
is the model that will be used in the controller.

### options.middleware

Example usage
-------------

```js
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var resourcePebble = require('resource-pebble')

// body-parser or a similar middleware is required
app.use(bodyParser.urlencoded, { extended: false });
app.use(bodyParser.json());

// Find a mongoose model for the resource
Article = require('./models/article');

var authMiddleware = require('./middleware/auth');

app.use(resourcePebble(Article), {

    // Optionally register middleware for routes
    middleware: {
        'create': authMiddleware,
        'update': authMiddleware
    },

    // Optionally restrict the number of methods to use
    only: ['show', 'create', 'update']
});
```

Responses
---------

The default responses are on the form:
```
{
    "status": Number,
    "success": Boolean,
    "data": ANY
}
```

The responses can be changed by extending the express response object with
a provide method. I am planning to develop response provider middleware
for express. The functionality required for this is enabled in this module.
To enable custom throughout your app you can use the stripped down
implementation specified below.

### Response API
Note: This is not enabled by by default, but will be used if available.

`res.response(responseType:String, data: ANY)`

#### Stripped down implementation
```javascript

var providers = {}; // Holds your response functions

function responseProvider(req, res, next) {
    res.provide = function (name, data) {
        var provider = providers[name](data);
        res.status(provider.status || 500);
        res.json(provider.data);
    }
    next();
}

app.use(responseProvider);

responses.error = function (data) {
    if (! process.env.DEBUG)
        data = null
    return {
        status: 500,
        data: data
    };
}
```

### Required responses
* error
* success

TODO
----

* Create tests for middleware
* Enable multiple methods per middleware (as in `middleware: { 'create update': authMiddleware }`)
* Create response provider module
