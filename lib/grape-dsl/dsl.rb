#encoding: UTF-8
module GrapeDSL
  module Extend

    module APIMNT

      class Description

        def initialize opts={}
          raise unless opts.class <= ::Hash
          opts.each{|k,v| self.__send__("#{k}=",v) }
        end

        def [] sym
          self.__send__ sym.to_s
        end

        def []= sym,value
          self.__send__ "#{sym.to_s}=",value
        end

        attr_accessor :description,:body,:content_type
        alias desc= description=
        alias desc  description
        alias type= content_type=
        alias type  content_type

        def value
          {description: description,content_type: content_type,body: body}
        end

      end

      # defaults
      # desc -> description for path
      # body -> return body from the call
      # convent_type -> real content type
      def description(*args)

        if desc.class != ::GrapeDSL::Extend::APIMNT::Description

          var= ::GrapeDSL::Extend::APIMNT::Description.new(*args)

          unless self.content_types.keys.empty?

            content_type_name= nil
            [:json,:xml,:txt].each do |element|
              if self.content_types.keys.include? element
                content_type_name ||= element.to_s.upcase
              end
            end
            var.content_type= content_type_name

          end

          var.desc= desc.to_s
          desc var

        end

        return desc

      end

      # mount all the rest api classes that is subclass of the Grape::API
      # make easy to manage

      def mount_api opts= {}

        unless opts.class <= Hash
          raise ArgumentError,"invalid option object given, must be hash like!"
        end

        opts[:ex] ||= opts[:except]   || opts[:exception] || opts[:e] || []
        opts[:in] ||= opts[:include]  || opts[:inclusion] || opts[:i] || []

        [:ex,:in].each{|sym| (opts[sym]=[opts[sym]]) unless opts[sym].class <= Array }

        # mount components
        Grape::API.inherited_by.each do |component|

          unless opts[:ex].include?(component) || self == component
            mount(component)
          end

        end

        opts[:in].each{|cls| self.mount(cls) }

        return nil

      end

      alias :mount_apis :mount_api

      def mount_subclasses(*exception)
        mount_api ex: exception
      end

      alias :mount_classes  :mount_subclasses

      # write out to the console the class routes
      def console_write_out_routes

        $stdout.puts "\n\nREST::API ROUTES:"
        self.routes.each do |route|
          $stdout.puts "#{route.route_method}","\t#{route.route_path}\n---\n"
        end

        return nil
      end

      alias :cw_routes :console_write_out_routes


    end

  end

end

Grape::API.__send__ :extend, ::GrapeDSL::Extend::APIMNT