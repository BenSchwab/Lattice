#!/usr/bin/env ruby
require 'erb'
require 'optparse'
require "fileutils"
require 'benchmark'

# module_name = ARGV[0]
# clusters = ARGV[1].to_i
# resources = ARGV[2].to_i
# modules = ARGV[3].to_i


# create settings file

# add dependencies to app build.gradle

# for each module
# Generate the files

#FileUtils::mkdir_p "../module/"



def write_settings(modules)
 modules = modules
 erb_template = ERB.new(File.read('templates/settings.gradle'))
 File.write("settings.gradle", erb_template.result(binding))
end

def write_app_build(modules)
 modules = modules
 erb_template = ERB.new(File.read('templates/build.gradle'))
 File.write("app/build.gradle", erb_template.result(binding))
end


def generate_clusters(module_name, clusters)
 for cluster_number in 1..clusters do
  erb_template = ERB.new(File.read('templates/Cluster.kt'))
  File.write("#{module_name}/src/main/java/com/airbnb/#{module_name}/Cluster#{cluster_number}.kt", erb_template.result(binding))
 end
end

def generate_resources()
 for resource_number in 1..resources do
  erb_template = ERB.new(File.read('templates/layout.xml'))
  File.write("#{module_name}/src/main/res/layout/layout_#{resource_number}.xml", erb_template.result(binding))
 end
end


def create_module(module_name)
 `rm -rf #{module_name}`
 `mkdir -p #{module_name}/src/main`
 `mkdir -p #{module_name}/src/main/java/com/airbnb/#{module_name}`
 `mkdir -p #{module_name}/src/main/res`

 {
     'build.gradle' => "#{module_name}/build.gradle",
     'AndroidManifest.xml' => "#{module_name}/src/main/AndroidManifest.xml",
 }.each do |template, file_name|
  erb_template = ERB.new(File.read("templates/module/#{template}"), nil, '-')
  File.write(file_name, erb_template.result(binding))
 end

end

def create_modules(modules, clusters)
 modules_numbers = [*1..modules]
 module_names = modules_numbers.map { |num| "module#{num}"}

 module_names.each do |module_name|
  create_module(module_name)
  generate_clusters(module_name, clusters)
 end
 write_app_build(module_names)
 write_settings(module_names.unshift('app'))
end


def run_simulation()
 create_modules(1, 2000)
 time = Benchmark.measure {
  `./gradlew clean --recompile-scripts --offline --rerun-tasks  :app:assembleDebug`
 }
 puts time.real

end


run_simulation

