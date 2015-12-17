Gem::Specification.new do |gem|
  gem.name         = "shrine-fog"
  gem.version      = "0.1.1"

  gem.required_ruby_version = ">= 2.1"

  gem.summary      = "Provides Fog storage for Shrine."
  gem.description  = "Provides Fog storage for Shrine."
  gem.homepage     = "https://github.com/janko-m/shrine-fog"
  gem.authors      = ["Janko Marohnić"]
  gem.email        = ["janko.marohnic@gmail.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "shrine-fog.gemspec"]
  gem.require_path = "lib"

  gem.add_development_dependency "down", ">= 1.0.3"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "fog-aws"
  gem.add_development_dependency "mime-types"
  gem.add_development_dependency "dotenv"
  gem.add_development_dependency "shrine"
  gem.add_development_dependency "minitest", "~> 5.8"
end
