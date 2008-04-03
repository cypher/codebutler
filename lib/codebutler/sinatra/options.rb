require 'optparse'

module Sinatra
  module Options
    extend self
    
    attr_with_default :port, 4567
    attr_with_default :environment, :development
    attr_with_default :console, nil
    attr_with_default :use_mutex, false

    alias :use_mutex? :use_mutex

    def parse!(args)
      return if @environment == :test
      OptionParser.new do |opts|
        opts.on '-p port', '--port port', 'Set the port (default is 4567)' do |port|
          @port = port
        end
        opts.on '-h', '--help', '-?', 'Show this message' do
          puts opts
          exit!
        end
      end.parse!(ARGV)
    end
    
    def log_file
      ''
    end
    
    def set_environment(env)
      @environment = env
    end
  end
end
