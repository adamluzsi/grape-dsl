module GrapeDSL
  module Extend
    module Endpoint

      attr_accessor :header_config_obj
      alias :config_obj  :header_config_obj
      alias :config_obj= :header_config_obj=

    end
  end
end

Grape::Endpoint.__send__ :extend, ::GrapeDSL::Extend::Endpoint