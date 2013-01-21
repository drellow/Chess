gem 'rspec'
require 'rspec/core/rake_task'

task :default => :spec

desc "run tests for this lab"
RSpec::Core::RakeTask.new do |task|
  task.pattern = "chess_spec.rb"
  task.rspec_opts = [ '--format documentation', "--color" ]
end
