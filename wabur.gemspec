
require 'date'
require File.join(File.dirname(__FILE__), 'lib/wab/version')

Gem::Specification.new do |s|
  s.name = "wabur"
  s.version = ::WAB::VERSION
  s.authors = "Peter Ohler"
  s.date = Date.today.to_s
  s.email = "peter@ohler.com"
  s.homepage = "http://github.com/ohler55/wabur"
  s.summary = "Web Application Builder"
  s.description = %{Web Application Builder }
  s.licenses = ['MIT']

  s.files = Dir["{lib,test}/**/*.{rb,h,c}"] + ['LICENSE', 'README.md'] + Dir["pages/*.md"]
  s.test_files = Dir["test/**/*.rb"]

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md'] + Dir["pages/*.md"]
  s.rdoc_options = ['--title', 'WABuR', '--main', 'README.md', '--private']

  s.rubyforge_project = 'wabur'

end
