#encoding: UTF-8
module GrapeDSL
  module Extend

    module APIMNT

      # defaults
      # desc -> description for path
      # body -> return body from the call
      # convent_type -> real content type
      def description(opts={})

        @last_description ||= {}
        unless @last_description[:description].class == Hashie::Mash
          @last_description[:description]= Hashie::Mash.new(opts.merge(desc: @last_description[:desc]))
        end
        return @last_description[:description]

      end

      def description= obj
        self.description.desc= obj
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