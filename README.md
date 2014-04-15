Grape-DSL
============

DSL for Grape module that let you use some basic function much easier
if you use redmine wiki you can even create doc into it

## Use case

### Mount Grape api subclasses

you can mount Grape::API-s all child class with
```ruby

    # options   = grape options for call
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
    # you can give hash options just like to any other get,post put delete etc methods, it will work
    #

    class HelloApi < Grape::API

        get 'hello' do
          puts 'hello world'
        end

    end

    class SupApi < Grape::API

        get 'sup' do
            puts 'what\'s up?'
        end

    end


    class MainApi < Grape::API

        # all pre app now is mounted here ("/hello","/sup")
        mount_subclasses

    end

```

### Mount singleton methods as Rest calls

You can even set arguments to be json or yaml so it will be parsed before passing to method
In the default usecase, the mount process will read the method source for documentation for making desc

```ruby

    class TestClass

        def self.test_method hello

        end

        def self.complex_method hello, world="default", opts={},*args

              puts "hello: #{hello}"
              puts "world: #{world}"
              puts "opts:  #{opts.inspect}"
              puts "args:  #{args.inspect}"
              puts "---"

        end

    end

    class Api < Grape::API

        mount_method class: TestClass,method: :test_method
        # or
        mount_method method: TestClass.method(:test_method)

        mount_method    class: Test,
                        method: :test,
                        path: "hello_world",
                        args: [[:opts,:yaml],[:args,:json]]


    end

```

### Access Control for ips

you can manipulate and ban ips from unwelcomed sources

you can give static ips , or ranges by replacing number parts with stars

```ruby

    "192.168.1.2" == "192.168.1.2"
    "192.168.1.*" == ["192.168.1.0".."192.168.1.255"]

```

here is an example for the use

```ruby

    class API < Grape::API

        get :hello do

            allowed_ips "192.168.*.*"
            banned_ip "192.168.1.2"

            # some stuff to do here

        end

        get :hello_world do

            allowed_ips %W[ 192.168.*.* 127.0.0.1 ]
            banned_ip ["192.168.1.2","192.168.1.1"]

            # some stuff to do here

        end

    end

```