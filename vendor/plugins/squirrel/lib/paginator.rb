module Squirrel
  # The WillPagination module emulates the results that the will_paginate plugin returns
  # from its #paginate methods. When it is used to extend a result set from Squirrel, it
  # automtically pulls the result from the pagination that Squirrel performs. The methods
  # added to that result set make it duck-equivalent to the WillPaginate::Collection
  # class.
  module WillPagination
    def self.extended base
      base.current_page  = base.pages.current || 1
      base.per_page      = base.pages.per_page
      base.total_entries = base.pages.total_results
    end

    attr_accessor :current_page, :per_page, :total_entries

    # Returns the current_page + 1, or nil if there are no more.
    def next_page
      current_page < page_count ? (current_page + 1) : nil
    end

    # Returns the offset of the current page that is suitable for inserting into SQL.
    def offset
      (current_page - 1) * per_page
    end

    # Returns true if the current_page is greater than the total number of pages.
    # Useful in case someone manually modifies the URL to put their own page number in.
    def out_of_bounds?
      current_page > page_count
    end

    # The number of pages in the result set.
    def page_count
      pages.last
    end

    alias_method :total_pages, :page_count

    # Returns the current_page - 1, or nil if this is the first page.
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # Sets the number of pages and entries.
    def total_entries= total
      @total_entries = total.to_i
      @total_pages   = (@total_entries / per_page.to_f).ceil
    end
  end

  # The Page class holds information about the current page of results.
  class Page
    attr_reader :offset, :limit, :page, :per_page
    def initialize(offset, limit, page, per_page)
      @offset, @limit, @page, @per_page = offset, limit, page, per_page
    end
  end

  # A Paginator object is what gets inserted into the result set and is returned by
  # the #pages method of the result set. Contains offets and limits for all pages.
  class Paginator < Array
    attr_reader :total_results, :per_page, :current, :next, :previous, :first, :last, :current_range
    def initialize opts={}
      @total_results = opts[:count].to_i
      @limit         = opts[:limit].to_i
      @offset        = opts[:offset].to_i

      @per_page      = @limit
      @current       = (@offset / @limit) + 1
      @first         = 1
      @last          = ((@total_results-1) / @limit) + 1
      @next          = @current + 1 if @current < @last
      @previous      = @current - 1 if @current > 1
      @current_range = ((@offset+1)..([@offset+@limit, @total_results].min))

      (@first..@last).each do |page|
        self[page-1] = Page.new((page-1) * @per_page, @per_page, page, @per_page)
      end
    end
  end
end
