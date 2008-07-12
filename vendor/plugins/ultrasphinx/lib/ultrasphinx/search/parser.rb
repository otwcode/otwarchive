
module Ultrasphinx
  class Search
    module Parser    
      # We could rewrite this in Treetop, but for now it works well.
          
      class Error < RuntimeError
      end

      OPERATORS = {
        'OR' => '|',
        'AND' => '',
        'NOT' => '-',
        'or' => '|',
        'and' => '',
        'not' => '-'
      }
            
      private
      
      def parse query
        # Alters a Google query string into Sphinx 0.97 style
        return "" if query.blank?
        # Parse
        token_hash = token_stream_to_hash(query_to_token_stream(query))  
        # Join everything up and remove some spaces
        token_hash_to_array(token_hash).join(" ").squeeze(" ").strip
      end
      

      def token_hash_to_array(token_hash)              
        query = []
        
        token_hash.sort_by do |key, value| 
          key or ""
        end.each do |field, contents|
          # First operator always goes outside
          query << contents.first.first 
          
          query << "@#{field}" if field
          query << "(" if field and contents.size > 1
          
          contents.each_with_index do |op_and_content, index|
            op, content = op_and_content
            query << op unless index == 0
            query << content
          end
          
          query << ")" if field and contents.size > 1        
        end
        
        # Collapse fieldsets early so that the swap doesn't split them        
        query.each_with_index do |token, index|
          if token =~ /^@/
            query[index] = "#{token} #{query[index + 1]}"
            query[index + 1] = nil
          end
        end
        
        # Swap the first pair if the order is reversed
        if [OPERATORS['NOT'], OPERATORS['OR']].include? query.first.upcase
          query[0], query[1] = query[1], query[0]
        end
        
        query
      end
      

      def query_to_token_stream(query)      
        # First, split query on spaces that are not inside sets of quotes or parens
        
        query = query.scan(/[^"() ]*["(][^")]*[")]|[^"() ]+/) 
      
        token_stream = []
        has_operator = false
        
        query.each_with_index do |subtoken, index|
      
          # Recurse for parens, if necessary
          if subtoken =~ /^(.*?)\((.*)\)(.*?$)/
            subtoken = query[index] = "#{$1}(#{parse $2})#{$3}"
          end 
          
          # Reappend missing closing quotes
          if subtoken =~ /(^|\:)\"/
            subtoken = subtoken.chomp('"') + '"'
          end
          
          # Strip parentheses within quoted strings
          if subtoken =~ /\"(.*)\"/
            subtoken.sub!($1, $1.gsub(/[()]/, ''))
          end
         
          # Add to the stream, converting the operator
          if !has_operator
            if OPERATORS.to_a.flatten.include? subtoken and index != (query.size - 1) 
              # Note that operators at the end of the string are not parsed
              token_stream << OPERATORS[subtoken] || subtoken
              has_operator = true # flip
            else
              token_stream << ""
              token_stream << subtoken
            end
          else
            if OPERATORS.to_a.flatten.include? subtoken
              # Drop extra operator
            else
              token_stream << subtoken
              has_operator = false # flop
            end
          end        
        end
        
        if token_stream.size.zero? or token_stream.size.odd?
          raise Error, "#{token_stream.inspect} is not a valid token stream"
        end
        token_stream.in_groups_of(2) 
      end
      
      
      def token_stream_to_hash(token_stream)
        token_hash = Hash.new([])        
        token_stream.map do |operator, content|
          # Remove some spaces
          content.gsub!(/^"\s+|\s+"$/, '"')
          # Convert fields into sphinx style, reformat the stream object
          if content =~ /(.*?):(.*)/
            token_hash[$1] += [[operator, $2]]
          else
            token_hash[nil] += [[operator, content]]
          end        
        end
        token_hash
      end


    end
  end
end