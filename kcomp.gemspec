# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "kcomp"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Holland"]
  s.date = "2013-04-06"
  s.description = "Codekit .kit file command-line compiler"
  s.email = "jeremy@jeremypholland.com"
  s.executables = ["kcomp"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/kcomp",
    "lib/errors.rb",
    "lib/kcomp.rb",
    "spec/kcomp_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/test-dest/.gitkeep",
    "spec/support/test-src-cyclic-1/inc1.kit",
    "spec/support/test-src-cyclic-1/test-inclusion.kit",
    "spec/support/test-src-cyclic-2/inc1.kit",
    "spec/support/test-src-cyclic-2/inc2.kit",
    "spec/support/test-src-cyclic-2/test-inclusion.kit",
    "spec/support/test-src-missing-dependency/test.kit",
    "spec/support/test-src-undefined-variable/test.kit",
    "spec/support/test-src/_partial1.kit",
    "spec/support/test-src/_partial2.kit",
    "spec/support/test-src/_partial3.kit",
    "spec/support/test-src/inc1.kit",
    "spec/support/test-src/inc10.kit",
    "spec/support/test-src/inc11.kit",
    "spec/support/test-src/inc12.kit",
    "spec/support/test-src/inc2.kit",
    "spec/support/test-src/inc4.kit",
    "spec/support/test-src/inc5.kit",
    "spec/support/test-src/inc7.kit",
    "spec/support/test-src/inc8.kit",
    "spec/support/test-src/inc9.kit",
    "spec/support/test-src/somedir/inc3.kit",
    "spec/support/test-src/somedir/inc6.kit",
    "spec/support/test-src/test-inclusion.kit"
  ]
  s.homepage = "http://github.com/awebneck/kcomp"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Codekit .kit file command-line compiler"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rgl>, ["~> 0.4.0"])
      s.add_development_dependency(%q<pry>, ["~> 0.9.12"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<rgl>, ["~> 0.4.0"])
      s.add_dependency(%q<pry>, ["~> 0.9.12"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.3.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rgl>, ["~> 0.4.0"])
    s.add_dependency(%q<pry>, ["~> 0.9.12"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.3.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end
