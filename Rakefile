require 'rake'
require 'rake/packagetask'
require 'rake/testtask'

desc 'Build and release the package'
task :release => [:build, :publish]

task :build do
  # Define the steps to build your package
  sh 'gem build fluent-plugin-eventbridge.gemspec'
end

task :publish do
  # Define the steps to publish the package to a gem server
  sh 'gem push fluent-plugin-eventbridge-*.gem'
end

