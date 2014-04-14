module GrapeDSL
  module Include
    module AccessControlEndpoint

      def generate_ip_regexp_collection *args

        if args.empty?
          raise ArgumentError, "missing ip(s) for allowed sources"
        end

        @cached_regexp_collection ||= {}
        if @cached_regexp_collection[args].nil?
          @cached_regexp_collection= {}

          ip_regex_collection= []
          args.each do |ip_addr|

            ip_regex_builder= [[],[],[],[]]

            #ip_addr.to_s.check(/([0-9\*]{1,3}\.){3}([0-9\*]{1,3})/)#(/([0-9\*]{1,3}\.){3}(0|\*)$/)
            if (ip_addr.to_s =~ /([0-9\*]{1,3}\.){3}([0-9\*]{1,3})/).nil? ? false : true

              ip_addr_index= 0
              ip_addr.split('.').each do |ip_addr_part|

                # 0.0.0.0
                # 255.255.255.255

                if ip_addr_part.include?("*")
                  ip_regex_builder[ip_addr_index]= "([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
                else
                  ip_regex_builder[ip_addr_index].push(ip_addr_part)
                end

                # increment index
                ip_addr_index += 1

              end

            else
              next
            end

            ip_regex_builder.map! do |element|

              case true

                when element.class <= Regexp
                  element.inspect[1..(element.inspect.length-2)]

                when element.class <= String
                  element

                when element.class <= Array
                  "(#{element.join('|')})"

                else
                  element.to_s

              end

            end

            ip_regex_collection.push /#{ip_regex_builder.join('\.')}/

          end

          @cached_regexp_collection[args]= ip_regex_collection

        end

        return @cached_regexp_collection[args]

      end

      def allowed_ips *args

        tests= generate_ip_regexp_collection(*args).map{ |regexp|
          request.instance_variable_get("@env")['REMOTE_ADDR'] =~ regexp
        }.compact

        if tests.empty?
          error!('403.6 - IP address rejected.', 403)
        end

      end

      alias :allowed_ip :allowed_ips

      def banned_ips *args

        tests= generate_ip_regexp_collection(*args).map{ |regexp|
          request.instance_variable_get("@env")['REMOTE_ADDR'] =~ regexp
        }.compact

        unless tests.empty?
          error!('403.6 - IP address rejected.', 403)
        end

      end

      alias :banned_ip :banned_ips



    end
  end
end

Grape::Endpoint.__send__ :include, ::GrapeDSL::Include::AccessControlEndpoint