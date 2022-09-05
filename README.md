# jekyll-event-pages

[![Gem Version](https://img.shields.io/gem/v/jekyll-event-pages.svg)](https://rubygems.org/gems/jekyll-event-pages)
[![Build Status](https://travis-ci.org/field-theory/jekyll-event-pages.png?branch=master)](https://travis-ci.org/field-theory/jekyll-event-pages)

This plugin adds event index pages with and without pagination.  
Benefits are:
* Easy to setup and use, fully compatible with the default [pagination
    plugin](https://github.com/jekyll/jekyll-paginate) (also cf. the
    [official documentation](https://jekyllrb.com/docs/pagination/)).
* Supports event keys with spaces and other special characters.
* Complete documentation and a usage example.
* Test coverage of key features.
* event index pages are generated based on a customizable template.

## Usage

Assign one or more events in the YAML front matter of each page:
```yaml
events: [event Pages Plugin, jekyll]
```
Generate the site and the event pages are generated:
```
_site/event/
├── event-pages-plugin/
│   └── index.html
├── 好的主意/
│   └── index.html
└── jekyll/
    ├── index.html
    ├── page2.html
    └── page3.html
```
In this example there are three paginated index pages for the `jekyll`
event (apparently, there are many posts for this event), a
single index page for the `好的主意` event and another single index
page for the `event Pages Plugin` event.

Note that the YAML `events` entry should always use brackets `[]`
to make it explicit that it is an array!

You can find this example in the `example` directory of the
[git repository](https://github.com/field-theory/jekyll-event-pages).

### The example project

The `example` directory contains a basic example project that
demonstrates the different use cases. In order to run Jekyll on these
examples use:
```shell
bundle install
bundle exec rake example
```
The result is put in `example/_site`.

## Installation and setup

Installation is straightforward (like other plugins):
1. Add the plugin to the site's `Gemfile` and configuration file and
   also install the `jekyll-paginate` gem (the latter is a required
   dependency even if you don't use it):
    ```ruby
    group :jekyll_plugins do
      gem "jekyll-paginate"
      gem "jekyll-event-pages"
    end
    ```
2. Add the plugin to your site's `_config.yml`:
    ```ruby
    plugins:
      - jekyll-event-pages
    ```
3. This step is optional, but recommended: Also add this line to
   `_config.yml` which excludes events from file URLs (they are
   ugly and don't work properly in Jekyll, anyways):
   ```ruby
   permalink: /:year/:month/:day/:title:output_ext
   ```
4. Configure any other options you need (see below).
5. Add template for event pages (see below).
6. Set appropriate `events` tags on each blog post YAML front
   matter.

### Configuration

The following options can be set in the Jekyll configuration file
`_config.yml`:
* `event_path`: Root directory for event index pages. Defaults
    to `event` if unset.  
    In the example this places the index file for event `jekyll` at
    `example/_site/event/jekyll/index.html`.
* `event_layout`: Basic event index template. Defaults to
    `event_index.html`. The layout **must** reside in the standard
    `_layouts` directory.  
    In the example the layout is in
    `example/_layouts/event_index.html`.
* `paginate`: (Maximum) number of posts on each event index
    page. This is the same for the regular (front page) pagination. If
    absent, pagination is turned off and only single index pages are
    generated.  
    In the example `paginate` is set to 2.

### Template for event pages

The template for a event index page must be placed in the site's
`_layouts` directory. The attribute `event` indicates the current
event for which the page is generated. The page title also defaults
to the current event. The other attributes are similar to the
default Jekyll pagination plugin.

If no pagination is enabled the following attributes are available:

| Attribute     | Description                               |
| ------------- | ----------------------------------------- |
| `event`    | Current page event                     |
| `posts`       | List of posts in current event         |
| `total_posts` | Total number of posts in current event |

If pagination is enabled (i.e., if setting `site.paginate` globally in
`_config.yml`) then a `paginator` attribute is available which returns
an object with the following attributes:

| Attribute            | Description                                                                      |
| -------------------- | -------------------------------------------------------------------------------- |
| `page`               | Current page number                                                              |
| `per_page`           | Number of posts per page                                                         |
| `posts`              | List of posts on the current page                                                |
| `total_posts`        | Total number of posts in current event                                        |
| `total_pages`        | Total number of pagination pages for the current event                        |
| `previous_page`      | Page number of the previous pagination page, or `nil` if no previous page exists |
| `previous_page_path` | Path of previous pagination page, or `''` if no previous page exists             |
| `next_page`          | Page number of the next pagination page, or `nil` if no subsequent page exists   |
| `next_page_path`     | Path of next pagination page, or `''` if no subsequent page exists               |

An example can be found in `example/_layouts/event_index.html`
which demonstrates the various attributes and their use.

### event listing

A event overview with a full listing of all events can be
created as follows:
```html
<ul>
{% for event in site.events %}
<li><a href="{{ site.url }}/event/{{ event | first | slugify }}/index.html">{{ event | first }}</a></li>
{% endfor %}
</ul>
```
Note that the event page paths are URL-encoded when generated by
this plugin. Thus, you have to use `slugify` when linking to each
event. This saves you from problems with spaces or other special
characters in event names.

An example listing can be found in `example/index.html` which
shows a full listing of events with corresponding links.

### events on a single page

Listing the events in a single page is particularly simple since
the events listed in the YAML front matter are directly available
as strings in `page.events`.  However, unlike the site-wide
event list in `site.events` the content of `page.events`
are just strings and can thus be added as follows (with references):
```html
<ul>
{% for event in page.events %}
<li><a href="{{ site.url }}/path-to-event-index/{{ event | slugify }}/index.html">{{ event }}</a></li>
{% endfor %}
</ul>
```

## Development

This project contains a `Rakefile` that supports the following
tasks:
* `build`: Runs all tests and builds the resulting gem file.
* `test`: Run all tests.
* `example`: Run Jekyll for the example project.
* `clean`: Clean up all transient files.

To run all test cases use:
```shell
bundle exec rake test
```
The tests run different Jekyll configurations and produce output files
that can be read by Ruby. These are then evaluted and validated using
[Ruby RSpec](http://rspec.info).

To build the gem use:
```shell
bundle exec rake build
```
The result is put in the current directory after all tests have been
run.

## Gotchas

The following issues and limitations are known:
* Jekyll currently does not properly escape special HTML entities
  (like `&` or `<`) in permalink paths. Because of that you cannot use
  them in event names. If you still want to use them you need to
  adjust the `permalink` path as shown above -- it must not contain
  event names.

## License

The gem is available as open source under the terms of the [MIT
License](https://github.com/field-theory/jekyll-event-pages/blob/master/LICENSE).
