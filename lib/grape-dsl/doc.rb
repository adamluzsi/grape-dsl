module GrapeDSL
  module Extend
    module Doc

      # helpers for doc generation
      def wiki_body(route,wrapper_begin,wrapper_end,wrapper_close)

        require 'grape-dsl/doc_mp'

        description_key= :body
        tmp_array= Array.new()
        params= nil
        evalue= nil
        content_type= nil

        #if route.route_path == "/booking/request(.:format)"
        #  debugger
        #end

        case true

          when route.route_description.class <= ::String
            params= route.route_params

          when route.route_description.class <= ::Hash

            if !route.route_description[:content_type].nil?
              content_type= route.route_description[:content_type]
            end

            if description_key.nil?
              params= route.route_params
              evalue= "value[:type]"
            else
              params= route.route_description[description_key]
              evalue= "value"
            end

          when route.route_description.class <= ::NilClass
            params= route.route_params
            params ||= "no return"
            content_type= "TXT"

          else
            params= route.route_params
            content_type= "TXT"

        end

        case true

          when params.class <= ::Hash

            if params == route.route_params
              tmp_hash= Hash.new
              params.each do |key,value|
                tmp_hash[key]= value[:type].to_s
              end
              params= tmp_hash
            end

            params = params.convert_all_value_to_grape_dsl_format

          when params.class <= ::Class
            begin
              if params.to_s.include? '::'
                if params.to_s.downcase.include? 'boolean'
                  params= params.to_s.split('::').last
                end
              end

              content_type= "TXT"
            end

          when params.class <= ::String
            content_type= "TXT"

          else
            begin
              params= "no params spec"
              content_type= "TXT"
            end

        end

        content_type ||= "TXT"
        case content_type.to_s.downcase

          when "json"
            begin

              tmp_array.push [wrapper_begin,content_type.to_s,wrapper_end].join

              require "json"

              formatted_string= params.to_json

              {
                  "{" => "{\n",
                  "}" => "\n}",
                  "," => ",\n"
              }.each do |from,to|
                formatted_string.gsub!(from,to)
              end

              formatted_string.gsub!(/^"/," \"")

              tmp_array.push formatted_string
              tmp_array.push wrapper_close
            end

          when "txt"
            begin
              tmp_array.push(params.inspect)
            end



        end

        return tmp_array

      end

      # this method help create from grape params and description a ppt like redmine wiki doc
      # Usage:
      #
      ##> example variable for description (hash obj)
      #description= Hash.new
      #
      ##> optional -> :description
      #description[:desc]= String.new
      #
      ##> response body like if JSON than a ruby Hash obj with the Structure and the values are the types
      #description[:body]= Hash.new
      #
      ##> response body code type -> like json usually same as content_type (format :xy)
      #description[:content_type]= String.new #> "JSON"
      #
      #desc description
      #params do
      #  optional :blabla, :type => String, :desc => "bla bla desc"
      #  requires :xy, type: String, desc: "XY desc"
      #end
      #get "xy" do
      #
      #end
      #
      ##>---------------------------------------------------------------------------------------------------
      #> OR the classic
      #desc "My awsome String Description"
      #params do
      #  optional :blabla, :type => String, :desc => "bla bla desc"
      #  requires :xy, type: String, desc: "XY desc"
      #end
      #delete "xy" do
      #
      #end
      #
      ##>---------------------------------------------------------------------
      ## For the method use
      #
      ## for a targeted specified class
      #Grape.create_redmine_wiki_doc target_class: REST::API,
      #                    path: File.expand_path(File.join(File.dirname(__FILE__),"test_file.txt"))
      #
      ## for all grape subclass (directs and indirects)
      #Grape.create_redmine_wiki_doc path: File.expand_path(File.join(File.dirname(__FILE__),"test_file.txt"))
      #
      def create_wiki_doc(*args)

        # default set in args
        begin

          args= Hash[*args]
          args.dup.each do |key,value|
            if key.class != Symbol
              args[key.to_s.to_sym]= value
              args.delete key
            end
          end

          if args[:path].nil?
            raise ArgumentError,"You must set a file path with a file name in order to create documentation for grape!"
          end

          args[:desc_files] ||= Array.new

          [:desc,:desc_file,:extra_desc_file].each do |one_key|

            args[:desc_files] += args[(one_key.to_s+"s").to_sym]  if args[(one_key.to_s+"s").to_sym].class  == Array
            args[:desc_files].push(args[one_key])                 if args[one_key].class                    == String

          end

          args[:type] ||= args[:doc_type]
          args[:type] ||= 'wiki'

          #args[:path],
          #args[:extra_desc_file]
          #args[:target_class]
          #args[:type]

        end


        # defaults
        begin

          uni_tab= ""
          case args[:type].to_s.downcase

            when "redmine","redmine_wiki","redmine-wiki","redminewiki"
              begin

                mid_tab= " "*3

                bsym= "*"
                isym= "_"

                htsym= "* "
                mtsym= htsym[0]*2 +" "
                stsym= htsym[0]*3 +" "

                hheader= "h3. "
                mheader= "h4. "
                sheader= "h5. "

                container_markup_begin= "<pre><code class=\""
                container_markup_end=   "\">"
                container_markup_close= "</code></pre>"

                toc_mark= "\n{{>toc}}\n"

              end

            when "github","wiki","md"
              begin

                mid_tab= " "*3

                bsym= "*"
                isym= "_"

                htsym= "* "
                mtsym= "  * "
                stsym= "    * "

                hheader= "## "
                mheader= "### "
                sheader= "#### "

                container_markup_begin= "```"
                container_markup_end=   ""
                container_markup_close= "```"
                toc_mark= ""

              end

            else
              raise ArgumentError, "invalid :type has been set, try github or redmine"

          end

        end

        # site name
        begin
          write_out_array = Array.new
          write_out_array.push "#{hheader}#{$0} REST Interface Documentation\n\n"
        end

        # description
        begin
          args[:desc_files].each do |extra_desc_file_path|

            write_out_array.push "#{sheader}#{extra_desc_file_path.split(File::Separator).last.split('.')[0].camelcase}\n"
            write_out_array.push " "+File.open(extra_desc_file_path,"r").read+"\n"

          end
        end

        # table of contents
        begin
          write_out_array.push toc_mark
        end

        # classes array
        begin
          rest_models= Array.new
        end
        if args[:target_class].nil?
          Grape::API.each_subclass do |one_class|
            rest_models.push(one_class)
          end
        else
          if args[:target_class].class != Class && args[:target_class] != nil
            raise ArgumentError, "invalid input :target_class is not a Class obj"
          end
          rest_models.push(args[:target_class])
        end

        rest_models.each do |rest_api_model|
          next if Grape::API == rest_api_model
          rest_api_model.routes.map do |route|


            method_name= "#{hheader}Request: #{route.route_path} call: #{route.route_method.to_s.downcase} part"

            # check that does the method already in the documentation
            unless write_out_array.include?(method_name)

              # create call name
              begin
                write_out_array.push method_name
              end

              # request
              begin

                # create request description
                begin
                  write_out_array.push("\n"+(uni_tab*1)+"#{mheader}Request description")
                  case true

                    when route.route_description.class <= String
                      route.route_description.each_line do |one_line|
                        write_out_array.push((uni_tab*2)+htsym+one_line.chomp)
                      end

                    when route.route_description.class <= Hash
                      begin

                        description_msg = nil

                        [:d,:desc,:description].each do |sym|
                          description_msg ||= route.route_description[sym]
                        end

                        if description_msg.class <= String
                          description_msg= [*description_msg.split("\n")]
                        end

                        description_msg ||= "No description available for this path"
                        description_msg= [*description_msg]

                        puts description_msg.inspect

                        description_msg.each do |one_line|
                          write_out_array.push((uni_tab*2)+htsym+one_line.chomp)
                        end

                      end


                  end
                end

                # pre request
                begin
                  write_out_array.push("\n#{mheader}request\n")
                end

                # create route method
                begin
                  write_out_array.push((uni_tab*2)+"#{htsym}#{bsym}method:#{bsym}#{mid_tab} #{route.route_method}")
                end

                # create route path
                begin
                  write_out_array.push((uni_tab*2)+"#{htsym}#{bsym}path:#{bsym}#{mid_tab}   #{route.route_path}")
                end

                # create route content_type
                begin
                  write_out_array.push((uni_tab*2)+"#{htsym}#{bsym}headers:#{bsym}#{mid_tab}")
                  rest_api_model.content_types.each do |one_format_type,one_format_header|
                    write_out_array.push "#{mtsym}#{uni_tab*2}#{one_format_header}"
                  end

                  write_out_array.push ""
                end

                # parameters
                begin
                  new_docs_element= Array.new
                  if route.route_params.count == 0
                    new_docs_element.push " No specified or special params"
                  else
                    new_docs_element.push ""
                    new_docs_element.push "#{htsym}#{isym}#{bsym}Parameters#{bsym}#{isym}"
                    route.route_params.each do |key,value|
                      new_docs_element.push "#{mtsym}#{isym}#{key}#{isym}"
                      value.each do |value_key,value_value|
                        new_docs_element.push "#{stsym}#{value_key}: #{value_value}"
                      end
                    end
                    new_docs_element.push "\n"
                  end
                  refactored_element= Array.new
                  new_docs_element.each do |one_element|
                    refactored_element.push((uni_tab*2)+one_element)
                  end
                  write_out_array.push refactored_element.join("\n")
                end

              end

              # response
              begin

                # pre response
                begin
                  write_out_array.push("\n#{mheader}response\n")
                end

                #> TODO make better implementation for others to use
                #create route content_type
                begin
                  if !Grape::Endpoint.config_obj.nil?

                    write_out_array.push((uni_tab*2)+"#{sheader}Extra headers:")

                    Grape::Endpoint.header_config_obj.each do |header_key,header_value|
                      write_out_array.push "#{htsym}#{header_key}: #{header_value.join(', ')}"
                    end

                    write_out_array.push ""

                  end
                end if Grape::Endpoint.respond_to?(:config_obj) && Grape::Endpoint.respond_to?(:header_config_obj)

                # create response bodies
                begin
                  #TODO check out why not working normaly with evry path!
                  write_out_array.push((uni_tab*2)+"#{sheader}*body:*")
                  wiki_body(route,container_markup_begin,container_markup_end,container_markup_close ).each do |one_element|
                    write_out_array.push one_element
                  end
                  write_out_array.push ""
                end

              end

              # error resp
              begin

                # pre error
                begin
                  write_out_array.push("\n#{mheader}response in case of failure\n")
                end

                # create error response headers
                begin

                end

                # create error response bodies
                begin
                  #write_out_array.push((uni_tab*2)+"*body:*")
                  write_out_array.push((uni_tab*2)+"#{htsym}*Internal Server Error:500*")
                end

              end

              # after space
              begin
                write_out_array.push "\n----\n"
              end

            end

          end
        end

        File.new(args[:path],"w").write write_out_array.join("\n")

        return nil
      end

      alias :create_ppt_doc :create_wiki_doc

    end
  end
end

Grape.__send__ :extend, ::GrapeDSL::Extend::Doc