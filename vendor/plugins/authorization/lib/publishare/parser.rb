module Authorization
  module Base

    VALID_PREPOSITIONS = ['of', 'for', 'in', 'on', 'to', 'at', 'by']
    BOOLEAN_OPS = ['not', 'or', 'and']
    VALID_PREPOSITIONS_PATTERN = VALID_PREPOSITIONS.join('|')

    module EvalParser
      # Parses and evaluates an authorization expression and returns <tt>true</tt> or <tt>false</tt>.
      #
      # The authorization expression is defined by the following grammar:
      #         <expr> ::= (<expr>) | not <expr> | <term> or <expr> | <term> and <expr> | <term>
      #         <term> ::= <role> | <role> <preposition> <model>
      #  <preposition> ::= of | for | in | on | to | at | by
      #        <model> ::= /:*\w+/
      #         <role> ::= /\w+/ | /'.*'/
      #
      # Instead of doing recursive descent parsing (not so fun when we support nested parentheses, etc),
      # we let Ruby do the work for us by inserting the appropriate permission calls and using eval.
      # This would not be a good idea if you were getting authorization expressions from the outside,
      # so in that case (e.g. somehow letting users literally type in permission expressions) you'd
      # be better off using the recursive descent parser in Module RecursiveDescentParser.
      #
      # We search for parts of our authorization evaluation that match <role> or <role> <preposition> <model>
      # and we ignore anything terminal in our grammar.
      #
      # 1) Replace all <role> <preposition> <model> matches.
      # 2) Replace all <role> matches that aren't one of our other terminals ('not', 'or', 'and', or preposition)
      # 3) Eval

      def parse_authorization_expression( str )
        if str =~ /[^A-Za-z0-9_:'\(\)\s]/
          raise AuthorizationExpressionInvalid, "Invalid authorization expression (#{str})"
          return false
        end
        @replacements = []
        expr = replace_temporarily_role_of_model( str )
        expr = replace_role( expr )
        expr = replace_role_of_model( expr )
        begin
          instance_eval( expr )
        rescue
          raise AuthorizationExpressionInvalid, "Cannot parse authorization (#{str})"
        end
      end

      def replace_temporarily_role_of_model( str )
        role_regex = '\s*(\'\s*(.+?)\s*\'|(\w+))\s+'
        model_regex = '\s+(:*\w+)'
        parse_regex = Regexp.new(role_regex + '(' + VALID_PREPOSITIONS.join('|') + ')' + model_regex)
        str.gsub(parse_regex) do |match|
          @replacements.push " process_role_of_model('#{$2 || $3}', '#{$5}') "
          " <#{@replacements.length-1}> "
        end
      end

      def replace_role( str )
        role_regex = '\s*(\'\s*(.+?)\s*\'|([A-Za-z]\w*))\s*'
        parse_regex = Regexp.new(role_regex)
        str.gsub(parse_regex) do |match|
          if BOOLEAN_OPS.include?($3)
            " #{match} "
          else
            " process_role('#{$2 || $3}') "
          end
        end
      end

      def replace_role_of_model( str )
        str.gsub(/<(\d+)>/) do |match|
          @replacements[$1.to_i]
        end
      end

      def process_role_of_model( role_name, model_name )
        model = get_model( model_name )
        raise( ModelDoesntImplementRoles, "Model (#{model_name}) doesn't implement #accepts_role?" ) if not model.respond_to? :accepts_role?
        model.send( :accepts_role?, role_name, @current_user )
      end

      def process_role( role_name )
        return false if @current_user.nil? || @current_user == :false
        raise( UserDoesntImplementRoles, "User doesn't implement #has_role?" ) if not @current_user.respond_to? :has_role?
        @current_user.has_role?( role_name )
      end

    end

    # Parses and evaluates an authorization expression and returns <tt>true</tt> or <tt>false</tt>.
    # This recursive descent parses uses two instance variables:
    #  @stack --> a stack with the top holding the boolean expression resulting from the parsing
    #
    # The authorization expression is defined by the following grammar:
    #         <expr> ::= (<expr>) | not <expr> | <term> or <expr> | <term> and <expr> | <term>
    #         <term> ::= <role> | <role> <preposition> <model>
    #  <preposition> ::= of | for | in | on | to | at | by
    #        <model> ::= /:*\w+/
    #         <role> ::= /\w+/ | /'.*'/
    #
    # There are really two values we must track:
    # (1) whether the expression is valid according to the grammar
    # (2) the evaluated results --> true/false on the permission queries
    # The first is embedded in the control logic because we want short-circuiting. If an expression
    # has been parsed and the permission is false, we don't want to try different ways of parsing.
    # Note that this implementation of a recursive descent parser is meant to be simple
    # and doesn't allow arbitrary nesting of parentheses. It supports up to 5 levels of nesting.
    # It also won't handle some types of expressions (A or B) and C, which has to be rewritten as
    # C and (A or B) so the parenthetical expressions are in the tail.
    module RecursiveDescentParser

      OPT_PARENTHESES_PATTERN = '(([^()]|\(([^()]|\(([^()]|\(([^()]|\(([^()]|\(([^()])*\))*\))*\))*\))*\))*)'
      PARENTHESES_PATTERN = '\(' + OPT_PARENTHESES_PATTERN + '\)'
      NOT_PATTERN = '^\s*not\s+' + OPT_PARENTHESES_PATTERN + '$'
      AND_PATTERN = '^\s*' + OPT_PARENTHESES_PATTERN + '\s+and\s+' + OPT_PARENTHESES_PATTERN + '\s*$'
      OR_PATTERN = '^\s*' + OPT_PARENTHESES_PATTERN + '\s+or\s+' + OPT_PARENTHESES_PATTERN + '\s*$'
      ROLE_PATTERN = '(\'\s*(.+)\s*\'|(\w+))'
      MODEL_PATTERN = '(:*\w+)'

      PARENTHESES_REGEX = Regexp.new('^\s*' + PARENTHESES_PATTERN + '\s*$')
      NOT_REGEX = Regexp.new(NOT_PATTERN)
      AND_REGEX = Regexp.new(AND_PATTERN)
      OR_REGEX = Regexp.new(OR_PATTERN)
      ROLE_REGEX = Regexp.new('^\s*' + ROLE_PATTERN + '\s*$')
      ROLE_OF_MODEL_REGEX = Regexp.new('^\s*' + ROLE_PATTERN + '\s+(' + VALID_PREPOSITIONS_PATTERN + ')\s+' + MODEL_PATTERN + '\s*$')

      def parse_authorization_expression( str )
        @stack = []
        raise AuthorizationExpressionInvalid, "Cannot parse authorization (#{str})" if not parse_expr( str )
        return @stack.pop
      end

      def parse_expr( str )
        parse_parenthesis( str ) or
        parse_not( str ) or
        parse_or( str ) or
        parse_and( str ) or
        parse_term( str )
      end

      def parse_not( str )
        if str =~ NOT_REGEX
          can_parse = parse_expr( $1 )
          @stack.push( !@stack.pop ) if can_parse
        end
        false
      end

      def parse_or( str )
        if str =~ OR_REGEX
          can_parse = parse_expr( $1 ) and parse_expr( $8 )
          @stack.push( @stack.pop | @stack.pop ) if can_parse
          return can_parse
        end
        false
      end

      def parse_and( str )
        if str =~ AND_REGEX
          can_parse = parse_expr( $1 ) and parse_expr( $8 )
          @stack.push(@stack.pop & @stack.pop) if can_parse
          return can_parse
        end
        false
      end

      # Descend down parenthesis (allow up to 5 levels of nesting)
      def parse_parenthesis( str )
        str =~ PARENTHESES_REGEX ? parse_expr( $1 ) : false
      end

      def parse_term( str )
        parse_role_of_model( str ) or
        parse_role( str )
      end

      # Parse <role> of <model>
      def parse_role_of_model( str )
        if str =~ ROLE_OF_MODEL_REGEX
          role_name = $2 || $3
          model_name = $5
          model_obj = get_model( model_name )
          raise( ModelDoesntImplementRoles, "Model (#{model_name}) doesn't implement #accepts_role?" ) if not model_obj.respond_to? :accepts_role?

          has_permission = model_obj.send( :accepts_role?, role_name, @current_user )
          @stack.push( has_permission )
          true
        else
          false
        end
      end

      # Parse <role> of the User-like object
      def parse_role( str )
        if str =~ ROLE_REGEX
          role_name = $1
          if @current_user.nil? || @current_user == :false
            @stack.push(false)
          else
            raise( UserDoesntImplementRoles, "User doesn't implement #has_role?" ) if not @current_user.respond_to? :has_role?
            @stack.push( @current_user.has_role?(role_name) )
          end
          true
        else
          false
        end
      end

    end
  end
end
