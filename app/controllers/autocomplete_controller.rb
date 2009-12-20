class AutocompleteController < ApplicationController

  def work_collection_names
    @collection_names = Collection.open.with_name_like(params[:work_collection_names]).name_only.map(&:name).sort
    render :inline => "<ul><%= @collection_names.map {|name| '<li>' + name + '</li>'} -%></ul>"
  end

  def work_recipients
    @work_recipients = Pseud.find(:all, :conditions => ["pseuds.name LIKE ?", '%' + params[:work_recipients] + '%'], :limit => 10).map(&:byline).sort
    render :inline => "<ul><%= @work_recipients.map {|name| '<li>' + name + '</li>'} -%></ul>"
  end

end
