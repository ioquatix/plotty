require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
	require 'pry'
	require_relative 'lib/plotty'
	
	Pry.start
end