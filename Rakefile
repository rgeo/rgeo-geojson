require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: [:test, :rubocop]

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = %w(test/**/*_test.rb)
  t.verbose = false
end

RuboCop::RakeTask.new
