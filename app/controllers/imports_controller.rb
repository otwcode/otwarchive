  class ImportsController < ApplicationController
    def new
      if params[:single]
        @page_subtitle = ts("Import Work")
        render :new_import and return
      end
      if params[:multiple]
        @page_subtitle = ts("Import Multiple Works")
        render :new_import_multiple and return
      end
    end

# POST /import/import
    def import
      Rails.logger.info "=====================Processing the request..."
      # check to make sure we have some urls to work with
      @urls = params[:urls].split
      unless @urls.length > 0
        flash.now[:error] = ts("Did you want to enter a URL?")
        render :new_import and return
      end

      # is this an archivist importing?
      if params[:importing_for_others] && !current_user.archivist
        flash.now[:error] = ts("You may not import stories by other users unless you are an approved archivist.")
        render :new_import and return
      end

      # make sure we're not importing too many at once
      if params[:import_multiple] == "works" && (!current_user.archivist && @urls.length > ArchiveConfig.IMPORT_MAX_WORKS || @urls.length > ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST)
        flash.now[:error] = ts("You cannot import more than %{max} works at a time.", :max => current_user.archivist ? ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST : ArchiveConfig.IMPORT_MAX_WORKS)
        render :new_import and return
      elsif params[:import_multiple] == "chapters" && @urls.length > ArchiveConfig.IMPORT_MAX_CHAPTERS
        flash.now[:error] = ts("You cannot import more than %{max} chapters at a time.", :max => ArchiveConfig.IMPORT_MAX_CHAPTERS)
        render :new_import and return
      end

      # otherwise let's build the options
      if params[:pseuds_to_apply]
        pseuds_to_apply = Pseud.find_by_name(params[:pseuds_to_apply])
      end
      options = {
          :pseuds => pseuds_to_apply,
          :post_without_preview => params[:post_without_preview],
          :importing_for_others => params[:importing_for_others],
          :restricted => params[:restricted],
          :override_tags => params[:override_tags],
          :fandom => params[:work][:fandom_string],
          :warning => params[:work][:warning_strings],
          :character => params[:work][:character_string],
          :rating => params[:work][:rating_string],
          :relationship => params[:work][:relationship_string],
          :category => params[:work][:category_string],
          :freeform => params[:work][:freeform_string],
          :encoding => params[:encoding],
          :external_author_name => params[:external_author_name],
          :external_author_email => params[:external_author_email],
          :external_coauthor_name => params[:external_coauthor_name],
          :external_coauthor_email => params[:external_coauthor_email],
          :xml_string => "",
          :source => "web"

      }



      # now let's do the import

      if params[:import_multiple] == "works" && options[:xml_string]
        import_multiple_works(@urls, options)
      else
        if params[:import_multiple] == "works" && @urls.length > 1
          import_multiple_works(@urls, options)
        else # a single work possibly with multiple chapters
          import_single(@urls, options)
        end
      end

    end



    # import a single work (possibly with multiple chapters)
    def import_single(urls, options)
      # try the import
      storyparser = StoryParser.new
      begin
        if urls.size == 1
          @work = storyparser.download_and_parse_story(urls.first, options)
        else
          @work = storyparser.download_and_parse_chapters_into_story(urls, options)
        end
      rescue Timeout::Error
        flash.now[:error] = ts("Import has timed out. This may be due to connectivity problems with the source site. Please try again in a few minutes, or check Known Issues to see if there are import problems with this site.")
        render :new_import and return
      rescue StoryParser::Error => exception
        flash.now[:error] = ts("We couldn't successfully import that work, sorry: %{message}", :message => exception.message)
        render :new_import and return
      end

      unless @work && @work.save
        flash.now[:error] = ts("We were only partially able to import this work and couldn't save it. Please review below!")
        @chapter = @work.chapters.first
        load_pseuds
        @series = current_user.series.uniq
        render :new and return
      end

      # Otherwise, we have a saved work, go us
      send_external_invites([@work])
      @chapter = @work.first_chapter if @work
      if @work.posted
        redirect_to work_path(@work) and return
      else
        redirect_to preview_work_path(@work) and return
      end
    end

    # import multiple works
    def import_multiple_works(urls, options)
      Rails.logger.info "================IN IMPORT MULTIPLE works"

      # try a multiple import
      storyparser = StoryParser.new
      if options[:xml_string].to_s.length > 100
        @works, failed_urls, errors = storyparser.import_many_xml(options)
      else
        @works, failed_urls, errors = storyparser.import_from_urls(urls, options)
      end


      # collect the errors neatly, matching each error to the failed url
      unless failed_urls.empty?
        error_msgs = 0.upto(failed_urls.length).map {|index| "<dt>#{failed_urls[index]}</dt><dd>#{errors[index]}</dd>"}.join("\n")
        flash.now[:error] = "<h3>#{ts('Failed Imports')}</h3><dl>#{error_msgs}</dl>".html_safe
      end

      # if EVERYTHING failed, boo. :( Go back to the import form.
      if @works.empty?
        if options[:xml_string]
          render :new_import_multiple and return
        else
          render :new_import and return
        end

      end

      # if we got here, we have at least some successfully imported works
      flash[:notice] = ts("Importing completed successfully for the following works! (But please check the results over carefully!)")
      send_external_invites(@works)

      # fall through to import template
    end

    # if we are importing for others, we need to send invitations
    def send_external_invites(works)
=begin
    if params[:importing_for_others]
      @external_authors = works.collect(&:external_authors).flatten.uniq
      if !@external_authors.empty?
        @external_authors.each do |external_author|
          external_author.find_or_invite(current_user)
        end
        message = " " + ts("We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually.")
        flash[:notice] ? flash[:notice] += message : flash[:notice] = message
      end
    end
=end
    end

    #POST /imports/import_multiple
    def import_multiple

      # is this an archivist importing?
      Rails.logger.info "IN IMPORT MULTIPLE"
      if params[:importing_for_others] && !current_user.archivist
        flash.now[:error] = ts("You may not import stories by other users unless you are an approved archivist.")
        render :new_import and return
      end
      options = {
          :pseuds => nil,
          :importing_for_others => params[:importing_for_others],
          :restricted => params[:restricted],
          :encoding => params[:encoding],
          :source => "file",
          :xml_string => params[:xml_data].read
      }
      Rails.logger.info "IN IMPORT MULTIPLE"
      import_multiple_works(nil, options)
    end

  end
