$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "blast/core/version" # Se agrega el namespace blast

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "blast_core"                     # Se renombra core a blast_core
  spec.version     = Blast::Core::VERSION             # Se agrega el namespace Blast
  spec.authors     = ["Rodrigo Fernandez"]            # Tu nombre
  spec.email       = ["rofaccess@gmail.com"]          # Tu correo
  spec.homepage    = "https://github.com/rofaccess/blast_crm"
  spec.summary     = "Core features of blast_crm."
  spec.description = "Core features of blast_crm."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.6"

  spec.add_dependency 'bootstrap', '~> 4.3.1'
  spec.add_dependency 'jquery-rails', '~> 4.3.3'
  spec.add_dependency 'sass-rails', '~> 5.0'

  spec.add_development_dependency "sqlite3"
end
