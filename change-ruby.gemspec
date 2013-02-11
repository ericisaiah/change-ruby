Gem::Specification.new do |s|
  s.name        = 'change-ruby'
  s.version     = '0.0.1'
  s.description = 'A Ruby library for the Change.org API.'
  s.authors     = ['Eric Lukoff']
  s.email       = 'eric@ericlukoff.com'
  s.summary     = 'Change.org API Ruby Library'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://rubygems.org/gems/change-ruby'
  s.add_runtime_dependency "httparty", ["= 0.10.2"]
end
