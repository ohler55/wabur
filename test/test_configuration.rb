#!/usr/bin/env ruby

class TestConfiguration < TestImpl
  def setup
    usage_string = 'Test Banner'
    options_map = {
      environment: {
        val:   'test',
        type:  String,
        doc:   'Configure the environment for this session',
        short: '-e',
        arg:   'ENV',
      }
    }
    @config = WAB::Impl::Configuration.new(usage_string, options_map)
  end

  def test_initialization
    assert_equal({:environment=>"test"}, @config.map )
  end

  def test_parse_config_file
    expected = {
      :store   => { :dir => "$BASE/test/store/data" },
      :handler => [{ :type =>"Article" }],
      :http    => { :dir => "$BASE/view/test-pages" }
    }
    assert_equal(expected,
      @config.parse_config_file(File.expand_path('samples/test-config.conf', __dir__))
    )
    assert_equal(expected,
      @config.parse_config_file(File.expand_path('samples/test-config.json', __dir__))
    )
    assert_raises(LoadError) {
      @config.parse_config_file(File.expand_path('samples/test-config.yml', __dir__))
    }
  end
end # TestConfiguration
