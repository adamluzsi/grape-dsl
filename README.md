Grape-DSL
============

DSL for Grape module that let you use some basic function much easier
if you use redmine wiki you can even create doc into it

## Use case

### Mount Grape api subclasses

you can mount Grape::API-s all child class with
```ruby

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