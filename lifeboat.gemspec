# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lifeboat}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ivan Acosta-Rubio"]
  s.date = %q{2011-11-15}
  s.description = %q{ }
  s.email = %q{ivan@bakedweb.net}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "config/aws.yml",
    "config/database.yml",
    "lib/lifeboat.rb",
    "lifeboat.gemspec",
    "spec/lifeboat_spec.rb",
    "support/lifeboat.png"
  ]
  s.homepage = %q{http://github.com/ivanacostarubio/lifeboat}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{sends messages to SQS}
  s.test_files = [
    "spec/lifeboat_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<right_aws>, [">= 1.10.0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<mysql>, [">= 2"])
      s.add_development_dependency(%q<rspec>, ["= 2.5.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<autotest>, [">= 0"])
    else
      s.add_dependency(%q<right_aws>, [">= 1.10.0"])
      s.add_dependency(%q<activerecord>, [">= 2.1.2"])
      s.add_dependency(%q<mysql>, [">= 2"])
      s.add_dependency(%q<rspec>, ["= 2.5.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<autotest>, [">= 0"])
    end
  else
    s.add_dependency(%q<right_aws>, [">= 1.10.0"])
    s.add_dependency(%q<activerecord>, [">= 2.1.2"])
    s.add_dependency(%q<mysql>, [">= 2"])
    s.add_dependency(%q<rspec>, ["= 2.5.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<autotest>, [">= 0"])
  end
end

