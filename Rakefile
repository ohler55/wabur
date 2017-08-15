#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'rake/testtask'

=begin
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/test_*.rb'
  test.options = "-v"
end
=end

task :test_all => [:clean] do
  exitcode = 0
  status = 0

  cmds = "bundle exec ruby test/impl_test.rb"
  puts "\n" + "#"*90
  puts cmds
  Bundler.with_clean_env do
    status = system(cmds)
  end
  exitcode = 1 unless status

  Rake::Task['test'].invoke
  exit(1) if exitcode == 1
end

task :default => :test_all

begin
  require "oj"
rescue LoadError
end

