#!/usr/bin/env ruby
require 'erb'
require 'optparse'

module_name = ARGV[0]
clusters = ARGV[1].to_i

for cluster_number in 1..clusters do
 erb_template = ERB.new(File.read('templates/Cluster.kt'))
 File.write("#{module_name}/src/main/java/com/airbnb/#{module_name}/Cluster#{cluster_number}.kt", erb_template.result(binding))
end