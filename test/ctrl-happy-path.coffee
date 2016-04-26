mongoose = require 'mongoose'
mockgoose = require 'mockgoose'
chai = require 'chai'
expect = chai.expect
chance = new require('chance')()
factories = require '../example/factories'
async = require 'async'

describe 'default controller, happy path', ->

    defaultController = require '../src/default-controller'
    models = require '../example/models'
    Article = models.Article
    articleCtrl = defaultController Article

    before (done) ->
        mockgoose(mongoose).then ->
            mongoose.connect 'mongodb://example.com/testingDB', (err) ->
                if err?
                    throw err
                done()

    after (done) ->
        mongoose.disconnect (err) ->
            done err

    beforeEach (done) ->
        mockgoose.reset done

    describe '.show', (done) ->
        
        article = null

        it 'finds resource if it exists', (done) ->

            # Arrange
            article = factories.article()
            article.save()

            req =
                body: {}
                params:
                    id: article.id
            res =
                status: (status) ->
                    return res
                json: (data) ->
                    # Assert
                    expect(data.status).to.equal(200)
                    expect(data.data.title).to.equal(article.title)
                    expect(data.data.body).to.equal(article.body)
                    done()

            # Act
            articleCtrl.show req, res

    describe '.all', ->
        it 'finds all registered data', (done) ->

            # Arrange
            articles = factories.article.save 5
            req = {}
            res =
                status: (status) ->
                    return res
                json: (response) ->
                    # Assert
                    expect(response.status).to.equal(200)
                    for article, idx in response.data
                        expect(articles[idx].title).to.equal(article.title)
                        expect(articles[idx].body).to.equal(article.body)
                    done()

            # Act
            articleCtrl.all req, res

    describe '.create', ->
        it 'creates an article', (done) ->

            # Arrange
            article = factories.article()
            req =
                body: article.toObject()
            res =
                status: (status) ->
                    return res
                json: (response) ->
                    expect(response.status).to.equal(201)

                    Article.findOne {}, (err, _article) ->
                        expect(err).not.to.exist
                        expect(_article.title).to.equal(article.title)
                        expect(_article.title).to.equal(article.title)
                        done()

            articleCtrl.create req, res

    describe '.update', ->
        it 'updates an article', (done) ->

            # Arrange
            article = factories.article.save()
            newTitle = 'new title!!'
            req =
                body:
                    title: newTitle
                params:
                    id: article._id
            res =
                status: (status) ->
                    res
                json: (response) ->
                    expect(response.status).to.equal(200)
                    Article.findOne {}, (err, _article) ->
                        expect(err).not.to.exist
                        expect(_article.title).to.equal(newTitle)
                        expect(_article.body).to.equal(article.body)
                        done()

            articleCtrl.update req, res

    describe '.destroy', ->
        it 'deletes an article', ->

            # Arrange
            article = factories.article.save()
            
            req =
                params:
                    id: article._id
            res =
                status: (status) ->
                    res
                json: (response) ->
                    expect(response.status).to.equal(200)
                    Article.findOne {}, (err, _article) ->
                        expect(article).not.to.exist

            articleCtrl.destroy req, res
