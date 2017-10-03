
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'
require 'wab/version'

Gem::Specification.new do |s|
  s.name = 'wabur'
  s.version = ::WAB::VERSION
  s.authors = 'Peter Ohler'
  s.date = Date.today.to_s
  s.email = 'peter@ohler.com'
  s.homepage = 'http://github.com/ohler55/wabur'
  s.summary = 'Web Application Builder'
  s.description = %{Web Application Builder }
  s.licenses = ['MIT']

  s.bindir = 'bin'
  s.executables << 'wabur'

  s.files = Dir['{lib,test}/**/*.rb'] + ['LICENSE', 'README.md'] + Dir['pages/*.md'] + Dir['bin/*'] + Dir['export/**/*'] + Dir['lib/**/*.template']
  s.test_files = Dir['test/**/*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md'] + Dir['pages/*.md']
  s.rdoc_options = ['--title', 'WABuR', '--main', 'README.md', '--private']

  s.rubyforge_project = 'wabur'

  s.add_runtime_dependency 'oj', '~> 3.3'

  s.add_development_dependency 'rake', '>= 0', '< 13.0'
  s.add_development_dependency 'rake-compiler', '>= 0.9', '< 2.0'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'sass', '~> 3.4'
end
