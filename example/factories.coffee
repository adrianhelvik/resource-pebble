models = require './models'
chance = new require('chance')()
Factory = require './factory'

exports.article = new Factory ->
    Article = models.Article

    return new Article
        title: chance.word()
        body: chance.paragraph()

exports.wallet = new Factory ->
    Wallet = models.Wallet

    return new Wallet
        money: Math.random()

exports.bag = new Factory ->
    Bag = models.Bag

    return new Bag
        wallets: []
        primaryWallet:
            exports.wallet
