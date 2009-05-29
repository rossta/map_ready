require 'rubygems'
require "rake/gempackagetask"
require "rake/clean"
require "spec/rake/spectask"
require './lib/map_ready'

spec = Gem::Specification.new do |s|
  s.name         = "map_ready"
  s.version      = MapReady::VERSION
  s.author       = "Ross Kaffenberger"
  s.email        = "rosskaff" + "@" + "gmail.com"
  s.homepage     = "http://github.com/rosskaff/map_ready"
  s.summary      = "Library for converting mappable objects to map markers"
  s.description  = s.summary
  s.files        = %w[History.txt MIT-LICENSE README.rdoc Rakefile] + Dir["lib/**/*"]
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts == ["--color"]
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run the specs"
task :default => ["spec"]

desc 'Show information about the gem.'
task :write_gemspec do
  File.open("map_ready.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
  puts "Generated: map_ready.gemspec"
end

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end
