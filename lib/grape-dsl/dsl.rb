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

        @last_description ||= {}
        unless @last_description[:desc].class == ::GrapeDSL::Extend::APIMNT::Description

          var= ::GrapeDSL::Extend::APIMNT::Description.new(*args)

          unless self.content_types.keys.empty?

            content_type_name= nil
            [:json,:xml,:txt].each do |element|
              if self.content_types.keys.include? element
                content_type_name ||= element.to_s.upcase
              end
            end

            var.content_type= content_type_name if var.content_type.nil?

          end

          var.desc= desc.to_s
          @last_description[:desc]= var

        end

        return @last_description[:desc]

      end

      # mount all the rest api classes that is subclass of the Grape::API
      # make easy to manage

      def mount_by opts= {}

        raise unless opts.class <= ::Hash

        opts[:class]  ||= opts[:klass]    || opts[:k]         || opts[:c] || Grape::API
        opts[:ex]     ||= opts[:except]   || opts[:exception] || opts[:e] || []
        opts[:in]     ||= opts[:include]  || opts[:inclusion] || opts[:i] || []

        [:ex,:in].each{|sym| (opts[sym]=[opts[sym]]) unless opts[sym].class <= Array }

        # mount components
        opts[:class].inherited_by.each do |component|
          mount(component) unless opts[:ex].include?(component) || self == component
        end

        opts[:in].each{ |klass| self.mount(klass) }

        return nil

      end

      def mount_subclasses(*exception)
        mount_by ex: exception
      end;alias :mount_classes  :mount_subclasses

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