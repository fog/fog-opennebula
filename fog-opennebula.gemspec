lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/opennebula/version'

Gem::Specification.new do |s|
    s.name = 'fog-opennebula'
    s.version     = Fog::OpenNebula::VERSION
    s.authors     = ['Daniel Clavijo Coca']
    s.email       = 'dclavijo@opennebula.systems'
    s.summary     = 'Module for the fog gem to support OpenNebula'
    s.description = 'This library can be used as a module for fog or as standalone provider'
    s.homepage    = 'http://github.com/fog/fog-opennebula'
    s.license     = 'MIT'

    s.files         = `git ls-files -z`.split("\x0")
    s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f) }
    s.test_files    = s.files.grep(%r{^(test|spec|features)/})
    s.require_paths = ['lib']

    s.required_ruby_version = '>= 2.0.0'

    ###### Gem dependencies ######

    s.add_dependency 'fog-core',  '= 2.1.0'
    s.add_dependency 'fog-json',  '~> 1.1'
    s.add_dependency 'fog-xml',   '~> 0.1'
    s.add_dependency 'nokogiri',  '< 1.13' if RUBY_VERSION < '2.6.0'
    s.add_dependency 'opennebula'
    s.add_dependency 'xmlrpc', '~> 0.3.0' if RUBY_VERSION > '2.4.0'
    s.add_development_dependency 'minitest'
    s.add_development_dependency 'minitest-stub-const'
    s.add_development_dependency 'mocha', '~> 1.1.0'
    s.add_development_dependency 'rake'
    s.add_development_dependency 'shindo', '~> 0.3.4'
    s.add_development_dependency 'simplecov'
end
