var mongoose = require('mongoose');
var mockgoose = require('mockgoose');
var chai = require('chai');
var expect = chai.expect
var chance = new require('chance')()
var factories = require('../example/factories');
var async = require('async');
var defaultController = require('../src/default-controller');
var models = require('../example/models');

describe('Nested resources', () => {

    /*
     * Setup
     */

    var Wallet = models.Wallet;
    var Bag = models.Bag
    var bagCtrl = defaultController(Bag);

    before((done) => {
        mockgoose(mongoose).then(() => {
            mongoose.connect('mongodb://example.com/testingDB', (err) => {
                done(err)
            });
        });
    });

    beforeEach((done) => {
        mockgoose.reset(done);
    });

    after((done) => {
        mongoose.disconnect(done);
    });

    /*
     * Tests
     */
    
    it('can create nested resources one->many');

    it('can create nested resources one->one');
});
