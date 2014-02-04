
class Array

  def convert_all_value_to_s

    self.count.times do |index|

      case self[index].class.to_s.downcase

        when "hash"
          self[index].convert_all_value_to_s

        when "array"
          self[index].convert_all_value_to_s

        else
          self[index]= self[index].to_s


      end

    end

    return self
  end

end


class Hash

  def convert_all_value_to_s

    self.each do |key,value|

      case value.class.to_s.downcase

        when "hash"
          value.convert_all_value_to_s

        when "array"
          value.convert_all_value_to_s

        else
          self[key]= value.to_s

      end

    end

    return self
  end

end

module Grape
  class << self

    # helpers for doc generation
    def redmine_body(route)

      description_key= :body
      tmp_array= Array.new()
      params= nil
      evalue= nil
      content_type= nil

      #if route.route_path == "/booking/request(.:format)"
      #  debugger
      #end

      case route.route_description.class.to_s.downcase

        when "string"
          params= route.route_params

        when "hash"

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

        when "nilclass"
          params= route.route_params
          params ||= "no return"
          content_type= "TXT"

        else
          params= route.route_params
          content_type= "TXT"

      end

      case params.class.to_s.downcase

        when "hash"

          if params == route.route_params
            tmp_hash= Hash.new
            params.each do |key,value|
              tmp_hash[key]= value[:type].to_s
            end
            params= tmp_hash
          end

          params = params.convert_all_value_to_s

        when "class"
          begin
            if params.to_s.include? '::'
              if params.to_s.downcase.include? 'boolean'
                params= params.to_s.split('::').last
              end
            end

            content_type= "TXT"
          end

        when "string"
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



            tmp_array.push("<pre><code class=\"#{content_type.to_s.upcase}\">")

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
            tmp_array.push("</code></pre>")
          end

        when "txt"
          begin

            tmp_array.push("<pre>")
            tmp_array.push(params.inspect)
            tmp_array.push("</pre>")

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
    #Grape.create_ppt_doc target_class: REST::API,
    #                    path: File.expand_path(File.join(File.dirname(__FILE__),"test_file.txt"))
    #
    ## for all grape subclass (directs and indirects)
    #Grape.create_ppt_doc path: File.expand_path(File.join(File.dirname(__FILE__),"test_file.txt"))
    #
    def create_redmine_wiki_doc(*args)

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
        if !args[:desc_files].nil? && args[:desc_files].class != Array
          args[:desc_files]= Array.new.push(args[:desc_files])
        end

        [:desc,:desc_file,:extra_desc_file].each do |one_key|
          unless args[one_key].nil?
            args[:desc_files].push args[one_key]
            args.delete one_key
          end
        end



        #args[:path],
        #args[:extra_desc_file]
        #args[:target_class]

      end

      # site name
      begin
        write_out_array = Array.new
        write_out_array.push "h1. Database Rest Control Layer Documentation\n"
        write_out_array.push "h2. REST application routes:\n"
      end

      # description
      begin
        write_out_array.push  "h3. this is the documentation for #{$0} rest calls\n\n"+
                                  "  the main function is to create a control layer to the database,\n"+
                                  "with interactive commands, that can handle multiple way from ask requests,\n"+
                                  "like regexp search by string, or different parameters for an array ask,\n"+
                                  "relation connection handle.\n\n"+
                                  " The calls input are the parameters, the description tells what does it do,\n"+
                                  "like read from db, create in the db or update in the db by xy params, and how.\n"

        args[:desc_files].each do |extra_desc_file_path|
          write_out_array.push "h3. #{extra_desc_file_path.split(File::Separator).last.split('.')[0].downcase.capitalize}\n"
          write_out_array.push "<pre>"
          write_out_array.push File.open(extra_desc_file_path,"r").read
          write_out_array.push "</pre>\n"
        end
      end

      # table of contents
      begin
        write_out_array.push "\n{{>toc}}\n"
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

          # defaults
          begin

            uni_tab= " "*0
            mid_tab= " "*3

            bsym= "*"
            isym= "_"

            htsym= "* "
            mtsym= "** "
            stsym= "*** "

            hheader= "h3. "
            mheader= "h4. "
            sheader= "h5. "
            method_name= "#{hheader}Request: #{route.route_path} call: #{route.route_method.to_s.downcase} part"



          end

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
                case route.route_description.class.to_s.downcase

                  when "string"
                    route.route_description.each_line do |one_line|
                      write_out_array.push((uni_tab*2)+htsym+one_line.chomp)
                    end

                  when "hash"
                    begin
                      sym_to_find= :desc
                      if route.route_description[sym_to_find].nil?
                        sym_to_find= :description
                      end
                      route.route_description[sym_to_find].each_line do |one_line|
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

              # create request type for code format class
              # create request body contents
              #begin
              #  if rest_api_model.content_types.count == 1
              #    write_out_array.push((uni_tab*2)+"#{htsym}*body:*")
              #
              #    redmine_body(rest_api_model,route).each do |one_element|
              #      write_out_array.push one_element
              #    end
              #
              #  end
              #  write_out_array.push ""
              #end

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

              # create route content_type
              begin
                write_out_array.push((uni_tab*2)+"#{htsym}#{bsym}headers:#{bsym}#{mid_tab}")
                rest_api_model.content_types.each do |one_format_type,one_format_header|
                  write_out_array.push "#{mtsym}#{uni_tab*2}#{one_format_header}"
                end

                write_out_array.push ""
              end

              # create response bodies
              begin
                #TODO check out why not working normaly with evry path!
                write_out_array.push((uni_tab*2)+"#{htsym}*body:*")
                redmine_body(route).each do |one_element|
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

    alias :create_ppt_doc :create_redmine_wiki_doc

  end
end
