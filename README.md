Grape-DSL
============

DSL for Grape module that let you use some basic function much easier
if you use redmine wiki you can even create doc into it

### Use case

you can mount Grape::API-s all child class with
```ruby
    class MainApi < Grape::API
        mount_subclasses
    end
```

you can mount only a single singleton method from a class like this
ps.: you can even set arguments to be json or yaml so it will be parsed before passing to method
```ruby

    class TestClass

        def self.test_method hello

        end

        def self.complex_method
        def self.complex_method hello, world="default", opts={},*args

              puts "hello: #{hello}"
              puts "world: #{world}"
              puts "opts:  #{opts.inspect}"
              puts "args:  #{args.inspect}"
              puts "---"

        end

    end

    class Api < Grape::API

        mount_method TestClass, :test_method
        mount_method Test,:test, "hello_world",[:opts,:json],[:args,:json]

    end

```

or if you are big fan of the CURS , then you can use this two method:
response_headers_to_new_calls
response_headers_to_routes_options_request

there is description in he headers file.

so stuffs like this can be found in this project


## LICENSE

(The MIT License)

Copyright (c) 2014++ Adam Luzsi <adamluzsi@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
