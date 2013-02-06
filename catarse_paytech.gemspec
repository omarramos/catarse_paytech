$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_paytech/version"

Gem::Specification.new do |s|
  s.name        = "catarse_paytech"
  s.version     = CatarsePaytech::VERSION
  s.authors     = ["Omar Ramos"]
  s.email       = ["omar@digitaltree.com"]
  s.homepage    = "https://bitbucket.org/digitaltree/catarse-paytech/overview"
  s.summary     = "PaypalExpress integration with Catarse"
  s.description = "PaypalExpress integration with Catarse crowdfunding platform"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.7"

  s.add_development_dependency "sqlite3"
end
