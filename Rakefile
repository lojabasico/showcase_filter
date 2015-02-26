require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :console do
  load_irb
end

def load_irb
  require 'irb'
  require 'rspec'
  require_relative 'spec/spec_helper'
  ARGV.clear
  IRB.start
end

RSpec::Core::RakeTask.new

task default: :spec
task test: :spec
