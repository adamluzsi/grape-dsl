module Grape
  # An Endpoint is the proxy scope in which all routing
  # blocks are executed. In other words, any methods
  # on the instance level of this class may be called
  # from inside a `get`, `post`, etc.
  class Endpoint
    class << self
      attr_accessor :header_config_obj

      alias :config_obj  :header_config_obj
      alias :config_obj= :header_config_obj=

    end
  end
end