#!/usr/bin/env ruby
require 'erb'
require 'optparse'
require "fileutils"
require 'benchmark'
require 'csv'

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
  module_names = modules_numbers.map {|num| "module#{num}"}

  module_names.each do |module_name|
    create_module(module_name)
    generate_clusters(module_name, clusters)
  end
  write_app_build(module_names)
  write_settings(module_names.unshift('app'))
end


def run_simulation()
  number_of_modules = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  number_of_clusters = [20, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000]
  #number_of_clusters = [2000]
  times = []
  number_of_modules.each do |modules|
    cluster_times = []
    times.push(cluster_times)
    number_of_clusters.each do |clusters|
      puts "#{modules} by #{clusters}"
      per_module = clusters / modules
      puts "#{modules} by #{clusters} per #{per_module}"
      create_modules(modules, per_module)
      total_time = 0
      runs = 2
      for i in 1..runs do
        time = Benchmark.realtime {
          `./gradlew clean --recompile-scripts --offline --rerun-tasks  :app:assembleDebug`
        }
        puts "run #{i}: #{time}"
        total_time += time
      end
      average_time = total_time / runs
      puts "resting"
      sleep(average_time)
      puts "average: #{average_time}"

      cluster_times.push(average_time)
    end
    puts "resting five minutes before write csv."
    sleep(60 * 5)
    CSV.open("buildtimes_#{modules}.csv", 'w') do |csv|
       csv << cluster_times
    end
  end

  puts times
  CSV.open('buildtimes_all.csv', 'w') do |csv|
    times.each { |module_times| csv << module_times }
  end

end


run_simulation

