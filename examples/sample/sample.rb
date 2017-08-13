#!/usr/bin/env ruby
# encoding: UTF-8

$VERBOSE = true

while (index = ARGV.index('-I'))
  _, path = ARGV.slice!(index, 2)
  $: << path
end

require 'optparse'

$verbose = false
$async = false
$opts = OptionParser.new(%|Usage: sample [options]

Acts as a remote Controller in a WAB deployment. Input is from stdin and output
is on stdout. If verbosity is turned on it is sent to stderr.
|)
$opts.on('-v', 'verbose output on stderr')  { $verbose = true }
$opts.on('-a', 'async processing')          { $async = true }
$opts.on('-h', '--help', 'show this page')  { STDERR.puts $opts.help; Process.exit!(0) }

$opts.parse(ARGV)

require 'wab'
require 'wab/io'

class SampleController < ::WAB::Controller

  def initialize(shell, async=false)
    super(shell, async)
  end

  def handle(data)
    # TBD call TQL
    super
  end

  def create(path, query, data, rid=nil)
    super
  end

  def read(path, query, rid=nil)
    super
  end

  def update(path, query, data, rid=nil)
    super
  end

  def delete(path, query, rid=nil)
    super
  end

  def on_result(data)
    super
  end

end # MirrorController

shell = ::WAB::IO::Shell.new(1, 'kind', 0)
shell.verbose = $verbose
shell.register_controller('Sample', SampleController.new(shell, $async))
shell.start
