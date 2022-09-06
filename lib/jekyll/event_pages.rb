# frozen_string_literal: true
# Encoding: utf-8

#
# attribute_pages
# Add attribute index pages with and without pagination.
#
# (c) since 2022 by Alessandra Donnini
# Written by Alessandra Donnini <a dor donnini -at- etcware dot it>
#
# Copyright: Since 2022 Alessandra Donnini - MIT License
# See the accompanying file LICENSE for licensing conditions.
#

require 'jekyll'

module Jekyll

  module EventPages
    INDEXFILE = 'index.html'

    # Custom generator for generating all index pages based on a supplied layout.
    #
    # Note that this generator uses a layout instead of a regular page template, since
    # it will generate a set of new pages, not merely variations of a single page like
    # the blog index Paginator does.
    class Pagination < Generator
      # This generator is safe from arbitrary code execution.
      safe true
      priority :lowest

      # Generate paginated event pages if necessary.
      #
      # site - The Site object.
      def generate(site)
        event_base_path = site.config['event_path'] || 'event'
        event_layout_path = File.join('_layouts/', site.config['event_layout'] || 'event_index.html')
		site.data["events"] = site.post_attr_hash("events")
        
        if Paginate::Pager.pagination_enabled?(site)
          # Generate paginated event pages
          generate_paginated_events(site, event_base_path, event_layout_path)
        else
          # Generate event pages without pagination
          generate_events(site, event_base_path, event_layout_path)
        end
      end

      # Sort the list of events and remove duplicates.
      #
      # site - The Site object.
      #
      # Returns an array of strings containing the site's events.
      def sorted_events(site)
        events = []
        site.data["events"].each_pair do |event, pages|
          events.push(event)
        end
        events.sort!.uniq!
        return events
      end

      # Generate the paginated event pages.
      #
      # site               - The Site object.
      # event_base_path - String with the base path to the event index pages.
      # event_layout    - The name of the basic event layout page.
      def generate_paginated_events(site, event_base_path, event_layout)
        events = sorted_events site

        # Generate the pages
        for event in events
          posts_in_event = site.data["events"][event]
          event_path = File.join(event_base_path, Utils.slugify(event))
          per_page = site.config['paginate']

          page_number = EventPager.calculate_pages(posts_in_event, per_page)
          page_paths = []
          event_pages = []
          (1..page_number).each do |current_page|
            # Collect all paths in the first pass and generate the basic page templates.
            page_name = current_page == 1 ? INDEXFILE : "page#{current_page}.html"
            page_paths.push page_name
            new_page = EventIndexPage.new(site, event_path, page_name, event, event_layout, posts_in_event, true)
            event_pages.push new_page
          end

          (1..page_number).each do |current_page|
            # Generate the paginator content in the second pass.
            previous_link = current_page == 1 ? nil : page_paths[current_page - 2]
            next_link = current_page == page_number ? nil : page_paths[current_page]
            previous_page = current_page == 1 ? nil : (current_page - 1)
            next_page = current_page == page_number ? nil : (current_page + 1)
            event_pages[current_page - 1].add_paginator_relations(current_page, per_page, page_number,
                                                                     previous_link, next_link, previous_page, next_page)
          end

          for page in event_pages
            # Finally, add the new pages to the site in the third pass.
            site.pages << page
          end
        end

        Jekyll.logger.debug("Paginated events", "Processed " + events.size.to_s + " paginated event index pages")
      end

      # Generate the non-paginated event pages.
      #
      # site               - The Site object.
      # event_base_path - String with the base path to the event index pages.
      # event_layout    - The name of the basic event layout page.
      def generate_events(site, event_base_path, event_layout)
        events = sorted_events site

        # Generate the pages
        for event in events
          posts_in_event = site.data["events"][event]
          event_path = File.join(event_base_path, Utils.slugify(event))

          site.pages << EventIndexPage.new(site, event_path, INDEXFILE, event, event_layout, posts_in_event, false)
        end

        Jekyll.logger.debug("Events", "Processed " + events.size.to_s + " event index pages")
      end

    end
  end

  # Auto-generated page for a event index.
  #
  # When pagination is enabled, contains a EventPager object as paginator. The posts in the
  # event are always available as posts, the total number of those is always total_posts.
  class EventIndexPage < Page
    # Attributes for Liquid templates.
    ATTRIBUTES_FOR_LIQUID = %w(
      event
      paginator
      posts
      total_posts
      content
      dir
      name
      path
      url
    )

    # Initialize a new event index page.
    #
    # site              - The Site object.
    # dir               - Base directory for all event pages.
    # page_name         - Name of this event page (either 'index.html' or 'page#.html').
    # event          - Current event as a String.
    # event_layout   - Name of the event index page layout (must reside in the '_layouts' directory).
    # posts_in_event - Array with full list of Posts in the current event.
    # use_paginator     - Whether a EventPager object shall be instantiated as 'paginator'.
    def initialize(site, dir, page_name, event, event_layout, posts_in_event, use_paginator)
      @site = site
      @base = site.source
      if ! File.exist?(File.join(@base, event_layout)) && 
        ( site.theme && File.exist?(File.join(site.theme.root, event_layout)) )
          @base = site.theme.root
      end
      
      super(@site, @base, '', event_layout)
      @dir = dir
      @name = page_name

      self.process @name

      @event = event
      @posts_in_event = posts_in_event
      @my_paginator = nil

      self.read_yaml(@base, event_layout)
      self.data.merge!('title' => event)
      if use_paginator
        @my_paginator = EventPager.new
        self.data.merge!('paginator' => @my_paginator)
      end
    end

    # Add relations of this page to other pages handled by a EventPager.
    #
    # Note that this method SHALL NOT be called if the event pages are instantiated without pagination.
    # This method SHALL be called if the event pages are instantiated with pagination.
    #
    # page               - Current page number.
    # per_page           - Posts per page.
    # total_pages        - Total number of pages.
    # previous_page      - Number of previous page or nil.
    # next_page          - Number of next page or nil.
    # previous_page_path - String with path to previous page or nil.
    # next_page_path     - String with path to next page or nil.
    def add_paginator_relations(page, per_page, total_pages, previous_page_path, next_page_path, previous_page, next_page)
      if @my_paginator
        @my_paginator.add_relations(page, per_page, total_pages,
                                    previous_page, next_page, previous_page_path, next_page_path)
        @my_paginator.add_posts(page, per_page, @posts_in_event)
      else
        Jekyll.logger.warn("Categories", "add_relations does nothing since the event page has been initialized without pagination")
      end
    end

    # Get the event name this index page refers to
    #
    # Returns a string.
    def event
      @event
    end

    # Get the paginator object describing the current index page.
    #
    # Returns a EventPager object or nil.
    def paginator
      @my_paginator
    end

    # Get all Posts in this event.
    #
    # Returns an Array of Posts.
    def posts
      @posts_in_event
    end

    # Get the number of posts in this event.
    #
    # Returns an Integer number of posts.
    def total_posts
      @posts_in_event.size
    end
  end

  # Handle pagination of event index pages.
  class EventPager
    attr_reader :page, :per_page, :posts, :total_posts, :total_pages,
                :previous_page, :previous_page_path, :next_page, :next_page_path

    # Static: Calculate the number of pages.
    #
    # all_posts - The Array of all Posts.
    # per_page  - The Integer of entries per page.
    #
    # Returns the Integer number of pages.
    def self.calculate_pages(all_posts, per_page)
      (all_posts.size.to_f / per_page.to_i).ceil
    end

    # Add numeric relationships of this page to other pages.
    #
    # page               - Current page number.
    # per_page           - Posts per page.
    # total_pages        - Total number of pages.
    # previous_page      - Number of previous page or nil.
    # next_page          - Number of next page or nil.
    # previous_page_path - String with path to previous page or nil.
    # next_page_path     - String with path to next page or nil.
    def add_relations(page, per_page, total_pages, previous_page, next_page, previous_page_path, next_page_path)
      @page = page
      @per_page = per_page
      @total_pages = total_pages
      @previous_page = previous_page
      @next_page = next_page
      @previous_page_path = previous_page_path
      @next_page_path = next_page_path
    end

    # Add page-specific post data.
    #
    # page              - Current page number.
    # per_page          - Posts per page.
    # posts_in_event - Array with full list of Posts in the current event.
    def add_posts(page, per_page, posts_in_event)
      total_posts = posts_in_event.size
      init = (page - 1) * per_page
      offset = (init + per_page - 1) >= total_posts ? total_posts : (init + per_page - 1)

      @total_posts = total_posts
      @posts = posts_in_event[init..offset]
    end

    # Convert this EventPager's data to a Hash suitable for use by Liquid.
    #
    # Returns the Hash representation of this EventPager.
    def to_liquid
      {
          'page' => page,
          'per_page' => per_page,
          'posts' => posts,
          'total_posts' => total_posts,
          'total_pages' => total_pages,
          'previous_page' => previous_page,
          'previous_page_path' => previous_page_path,
          'next_page' => next_page,
          'next_page_path' => next_page_path
      }
    end
  end
end
