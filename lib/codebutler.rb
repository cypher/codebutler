require 'find'
require 'coderay'
require 'uri'

# We bring our own version of sinatra since it's not available as a gem yet
require 'codebutler/sinatra'

module CodeButler
  
  SUPPORTED_LANGUAGES = {
    '.rb'     => :ruby,
    '.c'      => :c,
    '.cc'     => :c,
    '.h'      => :c,
    '.html'   => :html,
    '.rhtml'  => :rhtml,    
  }
  
  # Ignore all command line arguments except -p
  # Clears ARGV to prevent sinatra from parsing
  def self.clean_argv
    if ARGV.include? "-h"
      puts <<-HELP
      Supported Arguments:
        -h        Print help (You're looking at it)
        -p port   Start the webserver on the specified port
      HELP
      exit
    elsif ARGV.include?("-p") && ARGV[ARGV.index("-p") + 1] =~ /^[0-9]+$/
      port = ARGV[ARGV.index("-p") + 1]
      ARGV.clear
      ARGV.unshift ['-p', port.to_s]
    else
      ARGV.clear
    end        
  end
  
  # Scan the current working directory for files, and serve them on localhost
  def self.serve
    clean_argv
    
    # Create a regex that matches all supported file endings
    regex = Regexp.new("(#{SUPPORTED_LANGUAGES.keys.map{|key| Regexp.escape(key)}.join('|')})$")
    
    working_dir = Dir.getwd
    file_list = []

    Find.find(working_dir) do |path|
      if match = path.match(regex)
        relative_path = path.slice( working_dir.length..-1 )
        
        file_list << relative_path
        
        # use Sinatra for easy hosting
        # We need to escape the path to catch names like "c++test.rb" and spaces
        get(Regexp.escape(URI.escape(relative_path))) do
          CodeRay.scan(File.readlines(path).join, SUPPORTED_LANGUAGES[match[1]]).div
        end
      end
    end
    
    # index:
    get('/') do
      file_list.sort.map { |file|
        %Q(<a href="#{file}">#{file}</a>)
      }.join("<br/>")      
    end
    
  end
end
