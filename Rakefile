begin
  require "rspec/core/rake_task"

  task :default => :spec

  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
    task.pattern    = 'spec/**/*_spec.rb'
  end
rescue LoadError
end
