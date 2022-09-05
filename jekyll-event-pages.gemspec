# frozen_string_literal: true
# Copyright: Since 2022 Alessandra Donnini - MIT License
# Encoding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-event-pages/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-event-pages"
  spec.summary = "Add event index pages with and without pagination."
  spec.description = <<-EOF
This plugin is for all authors that tag their pages using events attribute as categories: they can be used simultaneously. It generates
event overview pages with a custom layout. Optionally, it also adds proper
pagination for these pages.

Please refer to the README.md file on the project homepage at
https://github.com/etcware/jekyll-event-pages
EOF
  spec.version = Jekyll::EventPages::VERSION
  spec.authors = ["Alessandra Donnini"]
  spec.email = "a.donnini@etcware.it"
  spec.homepage = "https://github.com/etcware/jekyll-event-pages"
  spec.licenses = ["MIT"]

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r!^(lib/|(LICENSE|README)((\.(txt|md|markdown)|$)))!i)
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", "~> 4.0"
  spec.add_dependency "jekyll-paginate", "~> 1.1", ">= 1.0.0"

  spec.add_development_dependency "rspec", "~> 3.0"
end
