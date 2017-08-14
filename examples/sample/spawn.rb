#!/usr/bin/env ruby
# encoding: UTF-8

$VERBOSE = true

$: << __dir__
while (index = ARGV.index('-I'))
  _, path = ARGV.slice!(index, 2)
  $: << path
end

require 'optparse'
require 'wab'
require 'wab/io'
require 'sample'

# This app is expected to be spawned from a WAB runner. This demonstrates one
# possible mode for running WAB applications. It is the least performant of
# the WAB run options.

$verbose = false
$async = false
$opts = OptionParser.new(%|Usage: sample [options]

Acts as a remote Controller in a WAB deployment. Input is from stdin and output
is on stdout. If verbosity is turned on it is sent to stderr.
|)
$opts.on('-v', 'verbose output on stderr')  { $verbose = true }
$opts.on('-a', 'async processing')          { $async = true }
$opts.on('-h', '--help', 'show this page')  { $stderr.puts $opts.help; Process.exit!(0) }

$opts.parse(ARGV)

shell = ::WAB::IO::Shell.new(1, 'kind', 0)
shell.verbose = $verbose
shell.register_controller('Article', SampleController.new(shell, $async))
#shell.register_controller(nil, SampleController.new(shell, $async))
shell.start
