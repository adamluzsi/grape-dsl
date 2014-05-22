# this is super if you want CORS with Grape
# This is a plugin for Mongoid
# models rest layer generate
module GrapeDSL
  module Extend
    module Mounter

      # options   = grape options element
      # class     = target class
      # rest      = method name / REST METHOD NAME
      # prc       = These procs will be called with the binding of GrapeEndpoint,
      #             so params and headers Hash::Mash will be allowed to use
      #             they will run BEFORE the method been called, so ideal for auth stuffs
      #
      # args      = This is for argument pre parsing,
      #             like when you use "hash" type for an argument
      #             and the input should be sent as json, but you want it to be preparsed when the method receive
      #
      #      #> method hello parameter will be preparsed before passing to method
      #      simple use case => args: [:hello,:json],[:sup,:yaml]
      #                                     or
      #                         args: { hello: :json, sup: :yaml }
      #
      #
      # ---------------
      #
      # looks like this with FULL POWER:
      #   mount_method rest:    :get,
      #                class:   TestClass,
      #                method:  :test_method,
      #                path:    "funny_path/okey",
      #                args:    [[:arg_hello,:json]],#> or args: { arg_hello: :json }
      #                prc:     Proc{ authorize_instance_method_from_grape_endpoint }
      #
      # you can give hash options just like to any other get,post put delete etc methods, it will work
      #
      def mount_method *args, &block

        # process params && validations
        begin

          opts= args.select{|e|(e.class <= ::Hash)}.reduce( {}, :merge! )

          # required
          opts[:method]       ||= opts[:m]        || args.select{|e|(e.class <= ::Method)}[0] || raise(ArgumentError,"missing method input(:method)")
          unless [::String,::Symbol].select{|klass|(opts[:method].class <= klass)}.empty?

            opts[:class]  ||= opts[:c]  ||  opts[:module] ||  raise(ArgumentError,"missing method input(:method)")
            opts[:method]   = opts[:class].method(opts[:method])

          end

          # optional
          opts[:options]      ||= opts[:o]        || {}
          opts[:rest_method]  ||= opts[:r]        || opts[:protocol]    || opts[:rest] || opts[:rm] || :get
          opts[:proc]         ||= opts[:h]        || opts[:prc]         || opts[:hook] || block || Proc.new{}
          opts[:path]         ||= opts[:p]        || opts[:method].name
          opts[:args]         ||= opts[:a]        || opts[:arg]         || {}

          if opts[:args].class <= Array

            tmp_hash  = Hash.new
            opts[:args].each do |array_obj|
              if array_obj.size == 2 && array_obj.class <= ::Array
                tmp_hash[array_obj[0]]= array_obj[1]
              end
            end
            opts[:args]= tmp_hash

          end

          {

              options:      ::Hash,
              rest_method:  ::Symbol,
              proc:         ::Proc,
              path:         ::String,
              args:         ::Hash,
              method:       ::Method

          }.each { |key,type|
            unless opts[key].class <= type
              raise(ArgumentError,"invalid #{key} value, must instance of an inherited class from #{type}")
            end
          }

          opts[:rest_method]= opts[:rest_method].to_s.downcase.to_sym
          unless [:get,:post,:put,:delete,:options].include?(opts[:rest_method])
            raise(ArgumentError,"invalid rest method: #{opts[:rest_method]}")
          end

        end

        # do grape command generation
        begin
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
                           type: ::Array

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

                  unless params[element[1]].nil?

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

        return nil

      end


    end
  end
end

Grape::API.__send__ :extend, ::GrapeDSL::Extend::Mounter