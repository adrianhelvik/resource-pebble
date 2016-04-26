mongoose = require 'mongoose'
mockgoose = require 'mockgoose'
chai = require 'chai'
expect = chai.expect
chance = new require('chance')()
factories = require '../example/factories'
async = require 'async'

describe 'default controller, sad path', ->

    defaultController = require '../src/default-controller'
    models = require '../example/models'
    Article = models.Article
    articleCtrl = defaultController Article

    before (done) ->
        mockgoose(mongoose).then ->
            mongoose.connect 'mongodb://example.com/testingDB', (err) ->
                done(err)

    beforeEach (done) ->
        mockgoose.reset -> done()

    after (done) ->
        mongoose.disconnect (err) ->
            done err

    describe '.show', ->
        it 'shows correct response if no articles are present', (done) ->

            # Arrange
            article = factories.article()

            req =
                body: {}
                params:
                    id: article.id
            res =
                status: (status) ->
                    return res
                json: (response) ->
                    # Assert
                    expect(response.status).to.equal(404)
                    expect(response.data).not.to.exist
                    done()

            # Act
            articleCtrl.show req, res

    describe '.create', ->
        it 'can not specify restricted fields', (done) ->

            # Arrange
            article = factories.article()

            req =
                body:
                    title: article.title
                    body: article.body
                    _id: 'should not be here'
                    __v: 'should not be here'
                params:
                    id: article._id
            res =
                status: (status) ->
                    return res
                json: (response) ->
                    # Assert
                    expect(response.status).to.equal(201)
                    expect(response.data).to.exist

                    Article.findById response.data._id, (err, data) ->
                        expect(err).not.to.exist
                        expect(data._id).not.to.equal(req.body._id)
                        expect(data.__v).not.to.equal(req.body.__v)
                        done()

            # Act
            articleCtrl.create req, res

    describe '.update', ->
        it 'can not specify restricted fields', (done) ->

            # Arrange
            article = factories.article.save()
            
            req =
                body:
                    _id: 'should not be updated'
                    __v: 'should not be updated'
                params:
                    id: article._id
            res =
                status: (status) ->
                    return res
                json: (response) ->
                    # Assert
                    expect(response.status).to.equal(200)

                    async.parallel([
                        ((cb) ->

                            # Determine that article cannot be found by new id
                            Article.findById 'should not be updated', (err, data) ->
                                expect(err).to.exist
                                expect(data).not.to.exist
                                cb(null)
                        ),
                        ((cb) ->
                            # Assert that __v has not been overridden
                            Article.findById article._id, (err, data) ->
                                console.log err
                                expect(err).not.to.exist
                                expect(data.__v).not.to.equal 'should not be updated'
                                cb(err)
                        )
                    ], done)

            # Act
            articleCtrl.update req, res
