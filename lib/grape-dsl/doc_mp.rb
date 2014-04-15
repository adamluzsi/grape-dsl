
module GrapeDSL
  module EXT

    module ArrayMP
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

    module HashMP
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

  end
end

Array.__send__ :include, GrapeDSL::EXT::ArrayMP
Hash.__send__ :include, GrapeDSL::EXT::HashMP