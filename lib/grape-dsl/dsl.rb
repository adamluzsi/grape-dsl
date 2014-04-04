#encoding: UTF-8

module GrapeDSL
  module Extend

    module API

        # defaults
        # desc -> description for path
        # body -> return body from the call
        # convent_type -> real content type
        def description

          if desc.class <= String
            tmp_string= desc
            desc ::Hashie::Mash.new
            desc[:desc]= tmp_string
          end

          unless desc.class <= Hash
            desc ::Hashie::Mash.new
          end

          unless self.content_types.keys.empty?

            content_type_name= nil
            [:json,:xml,:txt].each do |element|
              if self.content_types.keys.include? element
                content_type_name ||= element.to_s.upcase
              end
            end
            desc[:convent_type] ||= content_type_name

          end

          return desc

        end

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

Grape::API.__send__ :extend, ::GrapeDSL::Extend::API