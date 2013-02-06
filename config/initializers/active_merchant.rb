ActiveMerchant::Billing::PaypalExpressGateway.default_currency = 'USD'
ActiveMerchant::Billing::Base.mode = :test if (::Configuration[:paytech_test] == 'true')
