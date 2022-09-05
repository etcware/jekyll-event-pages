# Frozen-string-literal: true
# Copyright: Since 2017 Wolfram Schroers - MIT License
# Encoding: utf-8

require 'jekyll-event-pages'

basedir = 'spec/test/_site2/event/'
jekyll = basedir + 'jekyll/'
haodezhuyi = basedir + '好的主意/'
plugin = basedir + 'event-pages-plugin/'
index = 'index.html'
page2 = 'page2.html'
page3 = 'page3.html'

describe Jekyll::EventPages do
  context "with pagination" do
    it "event indices exists" do
      expect(File.file? jekyll+index).to be true
      expect(File.file? jekyll+page2).to be true
      expect(File.file? jekyll+page3).to be true
      expect(File.file? haodezhuyi+index).to be true
      expect(File.file? plugin+index).to be true
    end

    it "event jekyll index is correct" do
      load jekyll+index
      expect($page_title).to eql('jekyll')
      expect($page_event).to eql('jekyll')
      expect($page_total_posts).to eql(5)
      expect($page_posts_title).to eql([ "More about Jekyll", "Everything you always wanted to know about Jekyll", "About the plugin", "Welcome to the plugin", "Welcome to Jekyll!" ])

      expect($page_paginator_total_posts).to eql(5)
      expect($page_paginator_per_page).to eql(2)
      expect($page_paginator_total_pages).to eql(3)
      expect($page_paginator_previous_page).to be_nil
      expect($page_paginator_next_page).to eql(2)
      expect($page_paginator_previous_page_path).to eql('')
      expect($page_paginator_next_page_path).to eql('page2.html')
      expect($page_paginator_posts_title).to eql([ "More about Jekyll", "Everything you always wanted to know about Jekyll" ])
    end

    it "event jekyll page2 is correct" do
      load jekyll+page2
      expect($page_title).to eql('jekyll')
      expect($page_event).to eql('jekyll')
      expect($page_total_posts).to eql(5)
      expect($page_posts_title).to eql([ "More about Jekyll", "Everything you always wanted to know about Jekyll", "About the plugin", "Welcome to the plugin", "Welcome to Jekyll!" ])

      expect($page_paginator_total_posts).to eql(5)
      expect($page_paginator_per_page).to eql(2)
      expect($page_paginator_total_pages).to eql(3)
      expect($page_paginator_previous_page).to eql(1)
      expect($page_paginator_next_page).to eql(3)
      expect($page_paginator_previous_page_path).to eql(index)
      expect($page_paginator_next_page_path).to eql(page3)
      expect($page_paginator_posts_title).to eql([ "About the plugin", "Welcome to the plugin" ])
    end

    it "event jekyll page3 is correct" do
      load jekyll+page3
      expect($page_title).to eql('jekyll')
      expect($page_event).to eql('jekyll')
      expect($page_total_posts).to eql(5)
      expect($page_posts_title).to eql([ "More about Jekyll", "Everything you always wanted to know about Jekyll", "About the plugin", "Welcome to the plugin", "Welcome to Jekyll!" ])

      expect($page_paginator_total_posts).to eql(5)
      expect($page_paginator_per_page).to eql(2)
      expect($page_paginator_total_pages).to eql(3)
      expect($page_paginator_previous_page).to eql(2)
      expect($page_paginator_next_page).to be_nil
      expect($page_paginator_previous_page_path).to eql(page2)
      expect($page_paginator_next_page_path).to eql('')
      expect($page_paginator_posts_title).to eql([ "Welcome to Jekyll!" ])
    end

    it "event 好的主意 is correct" do
      load haodezhuyi+index
      expect($page_title).to eql('好的主意')
      expect($page_event).to eql('好的主意')
      expect($page_total_posts).to eql(1)
      expect($page_posts_title).to eql([ "Welcome to the plugin" ])

      expect($page_paginator_total_posts).to eql(1)
      expect($page_paginator_per_page).to eql(2)
      expect($page_paginator_total_pages).to eql(1)
      expect($page_paginator_previous_page).to be_nil
      expect($page_paginator_next_page).to be_nil
      expect($page_paginator_previous_page_path).to eql('')
      expect($page_paginator_next_page_path).to eql('')
      expect($page_paginator_posts_title).to eql([ "Welcome to the plugin" ])
    end

    it "event Event Pages Plugin is correct" do
      load plugin+index
      expect($page_title).to eql('Event Pages Plugin')
      expect($page_event).to eql('Event Pages Plugin')
      expect($page_total_posts).to eql(2)
      expect($page_posts_title).to eql([ "About the plugin", "Welcome to the plugin" ])

      expect($page_paginator_total_posts).to eql(2)
      expect($page_paginator_per_page).to eql(2)
      expect($page_paginator_total_pages).to eql(1)
      expect($page_paginator_previous_page).to be_nil
      expect($page_paginator_next_page).to be_nil
      expect($page_paginator_previous_page_path).to eql('')
      expect($page_paginator_next_page_path).to eql('')
      expect($page_paginator_posts_title).to eql([ "About the plugin", "Welcome to the plugin" ])
    end
  end
end
