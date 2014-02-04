# this is super if you want CORS with Grape
module Grape
  class << self

    # example in yaml format
    # "header_name":
    #  - "header values"
    #  - "header value 2"
    #
    #
    # real  example for cors
    # "Access-Control-Allow-Headers":
    #    - "X-Idp-Id"
    #    - "X-Token"
    #    - "Content-Type"
    # "Access-Control-Allow-Origin":
    #    - "*"
    # "Access-Control-Allow-Methods":
    #    - HEAD
    #    - OPTIONS
    #    - GET
    #    - POST
    #    - PUT
    #    - DELETE
    #
    #
    # This will give headers to all call request response made after this
    # make sure to load BEFORE every route call going to be made
    def response_headers_to_new_calls(config_obj=nil)

      Grape::Endpoint.config_obj= config_obj unless config_obj.nil?
      Grape::API.inject_singleton_method :inherited, add: "after" do |subclass|

        subclass.class_eval do

          before do
            Grape::Endpoint.header_config_obj.each do |header_key,header_value|
              header header_key, header_value.join(', ')
            end
          end

        end

      end

      return nil
    end


    # same config obj format like to "response_headers_to_new_calls"
    # this will create headers for the options call to ALL already made route
    # make sure to load after every route has been made
    def response_headers_to_routes_options_request(config_obj=nil)

      Grape::Endpoint.header_config_obj= config_obj unless config_obj.nil?
      Grape::API.subclasses.each do |rest_api_model|
        rest_api_model.routes.map { |route| route.route_path.split('(.:format)')[0] }.uniq.each do |path|
          rest_api_model.class_eval do

            options path do
              Grape::Endpoint.header_config_obj.each do |header_key,header_value|
                header header_key, header_value.join(', ')
              end
            end

          end
        end

      end

      return nil
    end


  end
end