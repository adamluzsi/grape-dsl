#encoding: UTF-8
module Grape
  # The API class is the primary entry point for
  # creating Grape APIs.Users should subclass this
  # class in order to build an API.
  class API
    class << self

      # mount all the rest api classes that is subclass of the Grape::API
      # make easy to manage
      def mount_subclasses(*exception)

        # mark self as exception
        begin
          exception.push(self)
        end

        # mount components
        begin
          Grape::API.subclasses.each do |component|
            unless exception.include?(component)
              mount(component)
            end
          end
        end

        return nil

      end

      # write out to the console the class routes
      def console_write_out_routes

        $stdout.puts "\n\nREST::API ROUTES:"
        self.routes.map do |route|
          $stdout.puts "\t#{route.route_method}","#{route.route_path}"
        end

        return nil
      end


    end
  end
end

