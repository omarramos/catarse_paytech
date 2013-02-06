PaymentEngines.register({name: 'Creditcards', review_path: ->(backer){ CatarsePaytech::Engine.routes.url_helpers.payment_review_paytech_path(backer) }, locale: 'en'})
