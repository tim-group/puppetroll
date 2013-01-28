require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'rspec/core/rake_task'


task :test => [:setup]
Rake::TestTask.new { |t|
    t.pattern = 'test/**/*_test.rb'
}

desc "Run specs"
RSpec::Core::RakeTask.new("sys_spec") do |t|
    t.rspec_opts = %w[--color]
    t.pattern = "test/sys_spec/**/*_spec.rb"
end

desc "Run specs"
RSpec::Core::RakeTask.new() do |t|
    t.rspec_opts = %w[--color]
    t.pattern = "test/spec/**/*_spec.rb"
end


desc "Create Debian package"
task :package do
    require 'rubygems'
    require 'fpm'
    require 'fpm/program'
    FileUtils.mkdir_p( "build/package/opt/puppetroll/" )
    FileUtils.mkdir_p("build/package/usr/share/mcollective/plugins/mcollective/agent/")
    FileUtils.cp_r( "lib", "build/package/opt/puppetroll/" )
    FileUtils.cp_r("config", "build/package/opt/puppetroll")

    arguments = [
        "-p", "build/puppetroll_1.0.#{ENV['BUILD_NUMBER']}_all.deb" ,
        "-n" ,"puppetroll" ,
        "-v" ,"1.0.#{ENV['BUILD_NUMBER']}" ,
        "-m" ,"David Ellis <david.ellis@timgroup.com>" ,
        "-a", 'all' ,
        "-t", 'deb' ,
        "-s", 'dir' ,
        "--description", "An MCollective application that provides automated triggering of puppet runs via the puppetd agent." ,
        "--url", "https://github.com/youdevise/puppetroll",
        "-C" ,'build/package'
    ]

    raise "problem creating debian package " unless FPM::Program.new.run(arguments) == 0
end





