chai = require 'chai'
chai.should()
expect = chai.expect
Chance = require 'chance'
chance = new Chance()
async = require 'async'

sampleApp = require '../example'
request = require 'request'

app = null
models = null
Article = null
port = null
mongoose = null

send = (method, path, data, cb) ->
    if not cb? and typeof data == 'function'
        cb = data
    request[method] 'http://localhost:5000/' + path, form: data, cb

post = (path, data, cb) -> send('post', path, data, cb)
get = (path, data, cb) -> send('get', path, data, cb)
put = (path, data, cb) -> send('put', path, data, cb)

createArticles = (count) ->
    articles = []
    for i in [1..count]
        article = new Article
            title: chance.word()
            body: chance.paragraph()
        article.save()
        articles.push article
    return articles

before (done) ->
    sampleApp (data) ->
        app = data.app
        models = data.models
        Article = models.Article
        port = data.port
        mongoose = data.mongoose
        done null

describe 'default controller', ->
    describe 'create', ->
        it 'creates the resource', (done) ->
            post 'articles', title: 'foo', body: 'bar', (err, res, body) ->
                expect(body.success).to.be.okay
                Article.findOne { title: 'foo' }, (err, data) ->
                    expect(data.body).to.equal 'bar'
                    done()

    describe 'all', ->
        it 'can get all articles', (done) ->
            createArticles 3
            get 'articles', (err, res, data) ->
                data = JSON.parse data
                expect(data.data.length).to.equal 4
                done()

    describe 'get', ->
        it 'gets one article by id', (done) ->
            id = null
            article =
                title: null
                body: null

            async.series [(
                (cb) ->
                    Article.findOne {}, (err, _article) ->
                        id = _article._id
                        article.title = _article.title
                        article.body = _article.body
                        cb()
            ), (
                (cb) ->
                    get "articles/#{id}", (err, res, data) ->
                        data = JSON.parse data
                        expect(data.data.title).to.equal article.title
                        expect(data.data.body).to.equal article.body
                        cb()
            )], done
    describe 'update', ->
        it 'can update an article', (done) ->
            id = null
            article =
                title: null
                body: null

            findArticle = (cb) ->
                Article.findOne {}, (err, _article) ->
                    id = _article._id
                    article.title = _article.title
                    article.body = _article.body
                    cb null

            updateArticle = (cb) ->
                put "articles/#{id}", title: 'A NEW TITLE', ->
                    cb null

            assertFound = (cb) ->
                Article.findById id, (err, data) ->
                    expect(data.title).to.equal('A NEW TITLE')
                    cb null

            async.series [findArticle, updateArticle, assertFound], done
