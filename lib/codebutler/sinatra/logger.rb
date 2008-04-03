module Sinatra
  
  class Logger
    
    def initialize
    end
    
    %w(info debug error warn).each do |n|
      define_method n do |message|
      end
    end
    
    def exception(e)
    end
    
  end
  
end