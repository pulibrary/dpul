# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rubocop/rake_task'
require 'sneakers/tasks'
require 'solr_wrapper'
require 'solr_wrapper/rake_task'

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

def with_solr
  SolrWrapper.wrap(config: '.solr_wrapper') do |solr|
    solr.with_collection(dir: File.join('solr', 'config')) do
      begin
        puts "Solr running on port #{solr.port}"
        yield
      rescue Interrupt
        puts 'Stopping server'
      end
    end
  end
end

desc 'Run Solr and Rails for development environment'
task :ci do
  with_solr do
    Rake::Task['spec'].invoke
  end
end

namespace :pomegranate do
  desc 'Run Solr and Rails for development environment'
  task :rails do
    with_solr do
      IO.popen('rails server') do |io|
        io.each do |line|
          puts line
        end
      end
    end
  end

  desc 'Run Solr for test environment'
  task :server do
    with_solr do
      sleep
    end
  end
end
