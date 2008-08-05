module Streamlined::Controller::CrudMethods
  # Creates the list of items of the managed model class. Default behavior
  # creates an Ajax-enabled table view that paginates in groups of 10.  The 
  # resulting view will use Prototype and XHR to allow the user to page
  # through the model instances.  
  #
  # If the request came via XHR, the action will render just the list partial,
  # not the entire list view.
  def list
    self.crud_context = :list
    @options = {}
    unless exporting_a_full_download
      @options.smart_merge!(pagination_options)
    end
    @options.smart_merge!(order_options)
    @options.smart_merge!(filter_options)
    merge_count_or_find_options(@options)
    
    if pagination && !exporting_a_full_download
       if @options[:non_ar_column]
          col = @options[:non_ar_column]
          dir = @options[:dir]
          @options.delete :non_ar_column
          @options.delete :dir
          model_pages, models = paginate model_name.downcase.pluralize, @options
          if model_ui.has_sortable_column?(col)
            model_ui.sort_models(models, col)
          else
            logger.warn("Possible intrusion attempt: Invalid sort column #{col}")
          end
          models.reverse! if dir == 'DESC'
        else
          model_pages, models = paginate model_name.downcase.pluralize, @options
        end
    else
      model_pages = []
      models = model.find(:all, @options)
    end

    self.instance_variable_set("@#{model_name.variableize}_pages", model_pages)
    self.instance_variable_set("@#{Inflector.tableize(model_name)}", models)
    @streamlined_items = models
    @streamlined_item_pages = model_pages
    find_columns_for_export if exporting

    clear_filters unless request.xhr?
    
    if params[:format] == "EnhancedXMLToFile"
      export_xml_file
    elsif params[:format] == "XMLStylesheet"
      export_xml_stylesheet
    elsif params[:format] == "EnhancedXML"
      export_xml
    else
      respond_to do |format|
        format.html { render :action=> "list"}
        format.js { render :partial => "list"}
        format.csv { render :text => @streamlined_items.to_csv(model.columns.map(&:name),{:header => @header, :separator => @separator})}
        format.xml { export_xml }
        format.json { render :text => @streamlined_items.to_json }
        format.yaml { render :text => @streamlined_items.collect { |it| {it.class.name.to_s, it.attributes} }.to_yaml }
      end
    end
    
  end

   # Renders the Show view for a given instance.
   def show
     self.crud_context = :show
     self.instance = model.find(params[:id])
     render_or_redirect(:success, 'show')
   end

   # Opens the model form for creating a new instance of the
   # given model class.
   def new
     self.crud_context = :new
     self.instance = model.new
     render_or_redirect(:success, 'new')
   end

   # Uses the values from the rendered form to create a new
   # instance of the model.  If the instance was successfully saved,
   # render the #show view.  If the save was unsuccessful, re-render
   # the #new view so that errors can be fixed.
   def create
     hsh = collect_has_manies(params[model_symbol])
     self.instance = model.new(params[model_symbol])
     set_has_manies(hsh)

     if execute_before_create_and_yield { instance.save }
       flash[:notice] = "#{model_name.titleize} was successfully created."
       self.crud_context = :show
       render_or_redirect(:success, "show", :action=>"list")
     else
       self.crud_context = :new
       render_or_redirect(:failure, 'new')
     end
   end

  # Opens the model form for editing an existing instance.
  def edit
    self.crud_context = :edit
    self.instance = model.find(params[:id])
    render_or_redirect(:success, 'edit')
  end

  # Uses the values from the rendered form to update an existing
  # instance of the model.  If the instance was successfully saved,
  # render the #show view.  If the save was unsuccessful, re-render
  # the #edit view so that errors can be fixed.
  def update
    self.instance = model.find(params[:id])

    if execute_before_update_and_yield { update_relationships(params[model_symbol]) }
      # TODO: reimplement tag support
      # get_instance.tag_with(params[:tags].join(' ')) if params[:tags] && Object.const_defined?(:Tag)
      flash[:notice] = "#{model_name.titleize} was successfully updated."
      self.crud_context = :show
      render_or_redirect(:success, "show", :action=>"list")
    else
      self.crud_context = :edit
      render_or_redirect(:failure, "edit")
    end
  end

  def destroy
    self.instance = model.find(params[:id]).destroy
    render_or_redirect(:success, nil, :action => "list")
  end

  private
  delegates :pagination, :to=>:model_ui, :visibility=>:private
  attr_accessor :crud_context
  
  def pagination_options
    return pagination if pagination.is_a?(Hash)
    pagination ? {:per_page => 10} : {}
  end
  
  # TODO: Dump non_ar_column. 
  # Figure out whether a column is ar or not when using it!
  def order_options
    return model_ui.default_order_options unless order?

    if model.column_names.include? sort_column
      active_record_order_option
    else
      {:non_ar_column => sort_column.downcase.tr(" ", "_"), :dir => sort_order}
    end
  end
  
  def filter_options
    if advanced_filter?
      return {} if filter_session_expired

      conditions = advanced_filter.split(",")
      # put nil object in conditions array to generate NULL in sql query
      conditions.each_index {|i| conditions[i]=nil if conditions[i] == "nil"}
      rethash = {:conditions => conditions}
      rethash.merge! :include => session[:include] unless session[:include].nil?
      rethash
    elsif filter?
      rethash = {:conditions =>  model_ui.conditions_by_like_with_associations(filter)}
      rethash.merge!(:include => model_ui.filterable_associations + model_ui.additional_includes)
      rethash
    else
      {}  
    end
  end  
  
  def export_xml
    if params[:format] == "EnhancedXML"
      @xml_file = false
      render_streamlined_file '/generic_views/list.rxml', :layout => false
    else
      render :xml => @streamlined_items.to_xml
    end
  end

  def export_xml_file 
    @xml_file = true
    headers["Content-Type"] = "text/xml"
    headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(model_name)}_#{Time.now.strftime('%Y%m%d')}.xml\""
    render_streamlined_file '/generic_views/list.rxml', :layout => false
  end

  def export_xml_stylesheet
    headers["Content-Type"] = "text/xml"
    headers["Content-Disposition"] = "attachment; filename=\"#{model_underscore}.xsl\""
    render_streamlined_file '/generic_views/stylesheet.rxml', :layout => false
  end
  
  def exporting
    params[:format] == "xml" || params[:format] == "EnhancedXML" || params[:format] == "EnhancedXMLToFile" || params[:format] == "csv" || params[:format] == "XMLStylesheet" || params[:format] == "json" || params[:format] == "yaml"
  end
  
  def exporting_a_full_download
    exporting && params[:full_download] == "true"
  end
  
  def find_columns_for_export
    @header    = params[:skip_header].nil? ? true : false
    @separator = params[:separator].nil?   ? ','  : params[:separator]
    if params[:export_columns].nil?
      @export_columns = model_ui.list_columns
    else    
      @export_columns = model_ui.list_columns.reject { |col| params[:export_columns][col.name.to_sym].nil? }
    end  
  end
  
  private
  def collect_has_manies(params)     
    return {} if params.blank?
    hsh = {}
    model.has_manies(:exclude_has_many_throughs => true).each do |assoc|
      param = params.delete(assoc.name)
      if param
        hsh["#{assoc.name.to_s.singularize}_ids=".to_sym] = param
      end
    end
    hsh
  end
  
  def set_has_manies(hsh)
    return hsh if hsh.blank? 
    Streamlined::Components::Select.purge_streamlined_select_none_from_params(hsh)
    hsh.each do |method, ids|
      instance.send(method, ids)
    end
  end
  
  def update_relationships(params)
    hsh = collect_has_manies(params)
    set_has_manies(hsh)
    instance.update_attributes(params)
  end
end     
