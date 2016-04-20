Gem::Specification.new do |s|
  s.name        = 'pontoon'
  s.version     = '0.1.0'
  s.date        = '2016-04-20'
  s.summary     = "A simple Raft distributed consensus implementation"
  s.description = s.summary
  s.authors     = ["Anthony Corletti"]
  s.email       = 'anthcor@gmail.com'
  s.files       = ["lib/pontoon.rb", "lib/pontoon/goliath.rb"]
  s.homepage    = 'http://github.com/anthcor/pontoon'
  s.license     = 'MIT'

  s.add_dependency 'goliath', '~> 1.0'
  s.add_dependency 'multi_json', '~> 1.3'

  s.add_development_dependency 'cucumber', '~> 1.0'
  s.add_development_dependency 'em-http-request', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 2.0'
end
