# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ar_translate/version'

Gem::Specification.new do |spec|
  spec.name = 'ar_translate'
  spec.version = ArTranslate::VERSION
  spec.authors = ['Niko Dziemba']
  spec.email = ['niko@dziemba.com']

  spec.summary = 'Store translations in AR models with hstore'
  spec.description =
    'Store values for multiple languages in an ActiveRecord attribute using PostgreSQL\'s hstore.'
  spec.homepage = 'https://github.com/ad2games/ar_translate'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'activesupport', '>= 4.0.0'
  spec.add_dependency 'pg'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
