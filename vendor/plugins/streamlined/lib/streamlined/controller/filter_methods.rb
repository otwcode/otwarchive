module Streamlined::Controller::FilterMethods
  
      def add_filter
        @expired = filter_session_expired
        @column = params[:filter_column]
        @value = params[:filter_value]
        @conditions = build_filter(:add, nil, @column, @value)
        render_streamlined_file '/shared/add_filter.rjs'
#        if filter_session_expired
#          render :update do |page|
#            page.replace_html "advanced_filter", :partial => STREAMLINED_TEMPLATE_ROOT + '/shared/new_filter', :layout => false 
#            page.form.reset 'add_filter_form'
#            page << "$('page_options_advanced_filter').value =  \"#{@conditions}\" "
#            page.hide "filter_session_expired_msg"        
#          end
#        else
#          render :update do |page|
#            page.insert_html :bottom, "advanced_filter", :partial => STREAMLINED_TEMPLATE_ROOT + '/shared/new_filter', :layout => false 
#            page.form.reset 'add_filter_form'
#            page << "$('page_options_advanced_filter').value =  \"#{@conditions}\" "
#            page.hide "filter_session_expired_msg"        
#          end
#        end
      end
      
      def delete_filter
        if filter_session_expired
          render_streamlined_file '/shared/filter_session_expired.rjs'
#          render :update do |page|
#            page << "$('page_options_advanced_filter').value =  \"\" "
#            page.replace_html "advanced_filter", ""
#            page.show "filter_session_expired_msg"
#          end
        else
          @filter_num = params[:id]
          @conditions = build_filter(:delete, @filter_num, nil, nil)
          render_streamlined_file '/shared/delete_filter.rjs'
#          render :update do |page|
#            page.remove "filter_#{@filter_num}"
#            page << "$('page_options_advanced_filter').value =  \"#{@conditions}\" "
#            page.hide "filter_session_expired_msg"
#          end  
        end
      end

      # Update a filter in repsonse to it being changed on the screen      
      def update_filter
        if filter_session_expired
          render_streamlined_file '/shared/filter_session_expired.rjs'
#          render :update do |page|
#            page << "$('page_options_advanced_filter').value =  \"\" "
#            page.replace_html "advanced_filter", ""
#            page.show "filter_session_expired_msg"
#          end
        else
          @filter_num = params[:id]
          @column = params["filter_column__" + @filter_num.to_s]
          @value = params["filter_value__" + @filter_num.to_s]
          @conditions = build_filter(:update, @filter_num, @column, @value)
          render_streamlined_file '/shared/update_filter.rjs'
#          render :update do |page|
#            page << "$('page_options_advanced_filter').value =  \"#{@conditions}\" "
#            page.hide "filter_session_expired_msg"
#          end          
        end
      end

      def clear_all_filters
        clear_filters
        render_streamlined_file '/shared/clear_all_filters.rjs'
#        render :update do |page|
#          page << "$('page_options_advanced_filter').value =  \"\" "
#          page.replace_html "advanced_filter", ""
#          page.hide "filter_session_expired_msg"
#        end
      end
      

  private

      def filter_session_expired
        session[:num_filters].nil?
      end
      
      # handle the new filter input and return the new conditions for the db query
      def build_filter(action, filter_num, column, value)
        if action == :add
          if not session[:num_filters].nil?
            session[:num_filters] += 1
            session[:filter_index] += 1
          else
            session[:num_filters] = 1
            session[:filter_index] = 1
          end
          filter_num = session[:filter_index]
        end
        
        if action == :delete
          operand = sql_value = nil
          session[:num_filters] -= 1 unless session[:num_filters].nil? 
        else  
          operand, sql_value = get_operand_and_value(column, value)
        end
        
        store_filter(filter_num, column, sql_value, operand)
        conditions = rebuild_filter_conditions
      end
      
      # store the filter values in the session
      def store_filter(index, column, value, operand)
        session["filter_column__" + index.to_s] = column
        session["filter_value__" + index.to_s] = value
        session["filter_operand__" + index.to_s] = operand
      end
      
      # rebuild the conditions string to be passed to the database
      def rebuild_filter_conditions
        @join = ""
        @conditions = Array.new
        @include = Array.new
        @conditions[0] = ""
        index = 1
        column = nil
        
        return "" if session[:filter_index].nil?
        
        for filter in 1..session[:filter_index]
          column = session["filter_column__" + filter.to_s]
          if not column.nil?
            association, table_name, column = association_table_and_column(column)
            @conditions[0] += @join + table_name + "." + column + " " + session["filter_operand__" + filter.to_s] + " ?"
            @conditions[index] = session["filter_value__" + filter.to_s] 
            index += 1
            @join = " AND "
            if not association.nil? && @include.index(association).nil?
              @include.push(association)
            end
          end  
        end
        session[:include] = @include
        @conditions.join(",")
      end
      
      # decode the data passed and determine which table and column to filter on
      def association_table_and_column(column)
        if association_table(column)
          col = column.split("::")
          association = col[1].to_sym
          column = col[2]
          [association, model.reflect_on_association(association).klass.table_name, column]
        else
          [nil, model.table_name, column]  
        end
      end
      
      # returns true if the filter is on an association table
      def association_table(column)
        column[0..4] == "rel::"
      end
      
      # Clear out all the filters.  Called when we refresh the list
      def clear_filters
        unless session[:num_filters].nil?
          for filter in 1..session[:filter_index]
            if not session["filter_column__" + filter.to_s].nil?
              store_filter(filter, nil, nil, nil)
            end  
          end
          session[:num_filters] = nil
          session[:filter_index] = nil
        end
      end
      
      # Decode the filter data passed to see if we have an operand and a value e.g. "> 100"
      def get_operand_and_value(column, value)
        # caution: words have a "\  " ("\<space><space>") at the end.
        # the first space is part of the operand so that we get keywords 
        # and not string search terms such as "issue".  the second separates 
        # the operands 
        operands = %w{<= >= < > = after\  before\  is\ }
        op = nil

        operands.each do |operand|
          # only use operands at the start of the string
          if value.downcase.index(operand) == 0
            value = value.downcase.sub(operand,'')
            value = value.sub(/^\s+/,'')      # remove any spaces that were after the operand
            if operand == "after "
              op = ">"
            elsif operand == "before "
              op = "<"
            else
              op = operand  
            end
          end
        end

        # if no operands are passed then default to a like query 
        if op.nil?
          op = "like"
          value = "%" + value + "%"
        elsif op == "is "
          if value.downcase.index("null") || value.downcase.index("nil") || value.downcase.index("empty") || value.downcase.index("blank") || value == ""
            op = "is"
            value = "nil"
          else
            op = "="  
          end    
        end
        [op, value]
      end

end