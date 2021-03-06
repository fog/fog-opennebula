require 'bundler/setup'
require 'rake/testtask'
require 'rubygems'
require 'rubygems/package_task'
require File.dirname(__FILE__) + '/lib/fog/opennebula'

#############################################################################
#
# Helper functions
#
#############################################################################

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  Fog::OpenNebula::VERSION
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

#############################################################################
#
# Standard tasks
#
#############################################################################

GEM_NAME = name.to_s
task :default => [:test]

testcommand = 'shindont'
ENV.each do |key, val|
  if key =~ /VERBOSE|DEBUG/
    val =~ /1|true/ ? testcommand = 'shindo' : testcommand = 'shindont'
  end
end

desc 'Run tests'
task :test do
  mock = ENV['FOG_MOCK'] || 'true'
  sh("export FOG_MOCK=#{mock} && bundle exec #{testcommand} tests")
end

desc 'Run mocked tests'
task :mock do
  sh("export FOG_MOCK=true && bundle exec #{testcommand} tests")
end

desc 'Run live tests'
task :live do
  sh("export FOG_MOCK=false && bundle exec #{testcommand} tests")
end

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -r ./lib/fog/opennebula.rb'
end

#############################################################################
#
# Packaging tasks
#
#############################################################################

task :release => ['release:prepare', 'release:publish']

namespace :release do
  task :preflight do
    unless `git branch` =~ /^\* master$/
      puts 'You must be on the master branch to release!'
      exit!
    end
    if `git tag` =~ /^\* v#{version}$/
      puts "Tag v#{version} already exists!"
      exit!
    end
  end

  task :prepare => :preflight do
    Rake::Task[:build].invoke
    sh "gem install pkg/#{name}-#{version}.gem"
    Rake::Task[:git_mark_release].invoke
  end

  task :publish do
    Rake::Task[:git_push_release].invoke
    Rake::Task[:gem_push].invoke
  end
end

task :git_mark_release do
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
end

task :git_push_release do
  sh 'git push origin master'
  sh "git push origin v#{version}"
end

task :gem_push do
  sh "gem push pkg/#{name}-#{version}.gem"
end

desc "Build #{name}-#{version}.gem"
task :build do
  sh 'mkdir -p pkg'
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end
task :gem => :build
