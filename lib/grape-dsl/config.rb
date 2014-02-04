module Grape

  # for security on/off functions
  class << self
    attr_accessor :security
  end
  self.security= true

end
