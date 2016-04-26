mongoose = require 'mongoose'

exports.Article = mongoose.model 'article',
new mongoose.Schema
    title: String,
    body: String

exports.Wallet = mongoose.model 'Wallet', mongoose.Schema
    money: Number

exports.Bag = mongoose.model 'Bag', mongoose.Schema
    wallets: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Wallet'
    }]
    primaryWallet:
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Wallet'
