#encoding: UTF-8
module GrapeDSL

  #require 'bindless'
  #require 'procemon'
  #require 'mpatch'

  require 'mpatch/module'
  require 'mpatch/method'
  MPatch.patch!

  require 'grape'

  require 'json'
  require 'yaml'

  require 'grape-dsl/doc'
  require 'grape-dsl/dsl'
  #require 'grape-dsl/ept'
  require 'grape-dsl/mnt'

end