# frozen_string_literal: true

require_relative "lib/shorttags/version"

Gem::Specification.new do |spec|
  spec.name = "shorttags-rb"
  spec.version = Shorttags::VERSION
  spec.authors = ["Nauman Tariq"]
  spec.email = ["nauman@shorttags.com"]

  spec.summary = "Ruby client for Shorttags metrics tracking"
  spec.description = "Simple, lightweight Ruby gem for tracking metrics with Shorttags. Track signups, payments, revenue, and custom events."
  spec.homepage = "https://github.com/nauman/shorttags-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nauman/shorttags-rb"
  spec.metadata["changelog_uri"] = "https://github.com/nauman/shorttags-rb/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://shorttags.com/docs"

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # No external dependencies - uses only Ruby stdlib (net/http, json, uri)
end
