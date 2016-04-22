models = require './models'
chance = new require('chance')()
Factory = require './factory'

exports.article = new Factory (count) ->
    Article = models.Article

    return new Article
        title: chance.word()
        body: chance.paragraph()
