# this is super if you want CORS with Grape
# This is a plugin for Mongoid
# models rest layer generate
module Grape
  # The API class is the primary entry point for
  # creating Grape APIs.Users should subclass this
  # class in order to build an API.

  class API

    class << self


      # Args will be seperated by they class type
      # string = path part, will be joined with "/"
      # hash   = options element
      # Class  = target class
      # Symbol = method name
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
      # looks like this:
      #   mount_method TestClass, :test_method, "funny_path",:GET
      #
      # you can give hash options just like to any other get,post put delete etc methods, it will work
      #
      def mount_method *args

        options      =  Hash[*args.extract_class!(Hash)]
        path_name    = args.extract_class!(String).join('/')
        class_name   = args.extract_class!(Class)[0]
        before_procs = args.extract_class!(Proc)

        tmp_array    = args.extract_class!(Array)
        adapter_opt  = Hash.new

        tmp_array.each do |array_obj|
          if array_obj.count == 2
            adapter_opt[array_obj[0]]= array_obj[1]
          end
        end

        method_name  = nil
        rest_method  = nil

        args.extract_class!(Symbol).each do |element|
          if element.to_s == element.to_s.downcase
            method_name = element
          elsif element.to_s == element.to_s.upcase
            rest_method = element.to_s.downcase
          end
        end

        rest_method ||= "get"
        method_obj   =  class_name.method(method_name).clone

        if path_name == String.new
          path_name= method_name.to_s
        end


        params do

          method_obj.parameters.each do |array_obj|

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


        __send__(rest_method,path_name,options) do


          method_arguments= (method_obj.parameters.map{|element|
            if !params[element[1]].nil?

              case adapter_opt[element[1]]
                when :json
                  params[element[1]]= JSON.parse(params[element[1]])

                when :yaml
                  params[element[1]]= YAML.parse(params[element[1]])

              end

              params[element[1]]
            end
          }-[nil])

          before_procs.each do |proc_obj|
            proc_obj.call_with_binding self.binding?
          end

          method_obj.call(*method_arguments)

        end


      end

    end
  end
end