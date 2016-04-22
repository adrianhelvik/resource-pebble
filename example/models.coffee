mongoose = require 'mongoose'

exports.Article = mongoose.model 'article',
new mongoose.Schema
    title: String,
    body: String
