# this is super if you want CORS with Grape
# This is a plugin for Mongoid
# models rest layer generate
module GrapeDSL
  module Extend
    module Mounter

      # Args will be seperated by they class type
      # string = path part, will be joined with "/"
      # hash   = grape options element
      # Class  = target class
      # Symbol = method name / REST METHOD NAME
      # Proc   = These procs will be called with the binding of GrapeEndpoint,
      #          so params and headers Hash::Mash will be allowed to use
      #          they will run BEFORE the method been called, so ideal for auth stuffs
      #
      # Array  = This is for argument pre parsing, like when you use "hash" and the input will be a json
      #
      # simple use case: [:hello,:json],[:sup,:yaml]
      #
      #
      # ---------------
      #
      # looks like this with FULL POWER:
      #   mount_method rest: :GET,
      #                class: TestClass,
      #                method: :test_method,
      #                path: "funny_path/okey",
      #                args: [[:arg_hello,:json]],#> or args: { arg_hello: :json }
      #                Proc{ authorize_instance_method_from_grape_endpoint }
      #
      # you can give hash options just like to any other get,post put delete etc methods, it will work
      #
      def mount_method opts= {}, &block

        unless opts.class <= Hash
          raise ArgumentError, "invalid input, must be Hash like obj"
        end

        # required
        opts[:method]       ||= opts[:m]        || raise(ArgumentError,"missing method input(:method)")

        # optional
        opts[:options]      ||= opts[:o]        || {}
        opts[:rest_method]  ||= opts[:r]        || opts[:protocol]    || opts[:rest] || opts[:rm] || :get
        opts[:proc]         ||= opts[:h]        || opts[:prc]         || opts[:hook] || block || Proc.new{}
        opts[:path]         ||= opts[:p]        || opts[:method].name
        opts[:args]         ||= opts[:a]        || opts[:arg]         || {}

        if opts[:method].class <= String || opts[:method].class <= Symbol

          opts[:class]  ||= opts[:c]  ||  opts[:module] ||  raise(ArgumentError,"missing method input(:method)")
          opts[:method]   = opts[:class].method(opts[:method])

        end

        if opts[:args].class <= Array

          tmp_hash  = Hash.new
          opts[:args].each do |array_obj|
            if array_obj.count == 2
              tmp_hash[array_obj[0]]= array_obj[1]
            end
          end
          opts[:args]= tmp_hash

        end

        {

            options:      Hash,
            rest_method:  Symbol,
            proc:         Proc,
            path:         String,
            args:         Hash,
            method:       Method

        }.each { |key,type|
          unless opts[key].class <= type
            raise(ArgumentError,"invalid #{key} value, must instance of an inherited class from #{type}")
          end
        }

        opts[:rest_method]  = opts[:rest_method].to_s.downcase.to_sym

        desc opts[:method].get_comments

        params do

          opts[:method].parameters.each do |array_obj|

            case array_obj[0]

              when :req
                requires array_obj[1]
              when :opt
                optional array_obj[1]
              when :rest
                optional array_obj[1],
                         type: Array

              #when :block
              #  optional array_obj[1],
              #           type: String,
              #           desc: "Ruby code to be used"


            end

          end

        end

        self.__send__(opts[:rest_method], opts[:path], opts[:options]) do

          opts[:proc].call_with_binding self.binding?
          opts[:method].call(

              *opts[:method].parameters.map { |element|

                if !params[element[1]].nil?

                  # parse if requested
                  case opts[:args][element[1]].to_s
                    when 'json'
                      params[element[1]]= JSON.parse(params[element[1]])

                    when 'yaml', 'yml'
                      params[element[1]]= YAML.parse(params[element[1]])

                  end

                  # add new element
                  params[element[1]]

                end

              }.compact

          )

        end


      end


    end
  end
end

Grape::API.__send__ :extend, ::GrapeDSL::Extend::Mounter