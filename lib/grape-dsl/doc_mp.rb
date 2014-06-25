
module GrapeDSL
  module EXT

    module ArrayMP
      def convert_all_value_to_grape_dsl_format

        self.count.times do |index|

          case true

            when self[index].class <= Hash
              self[index].convert_all_value_to_grape_dsl_format

            when self[index].class <= Array
              self[index].convert_all_value_to_grape_dsl_format

            else
              self[index]= self[index].to_s


          end

        end

        return self
      end
    end

    module HashMP
      def convert_all_value_to_grape_dsl_format

        self.each do |key,value|

          case true

            when value.class <= Hash
              value.convert_all_value_to_grape_dsl_format

            when value.class <= Array
              value.convert_all_value_to_grape_dsl_format

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