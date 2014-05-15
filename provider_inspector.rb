require 'fog'

bucket = {
  :established => [],
  :not_enough => [],
  :one_off => []  
}

Fog.services.each_pair do |service, providers|
  if providers.size > 2
    bucket[:established] << service
  elsif providers.size == 1
    bucket[:one_off] << service
  else
    bucket[:not_enough] << service
  end
end

puts "## Established Abstraction"
bucket[:established].each {|service| puts "  * **#{service}** (#{Fog.services[service].join(", ")})" }
puts "\n"

puts "## Services with 2 Providers"
bucket[:not_enough].each {|service| puts "  * **#{service}** (#{Fog.services[service].join(", ")})" }
puts "\n"

puts "## Unique Services"
bucket[:one_off].each {|service| puts "  * **#{service}** (#{Fog.services[service].join(", ")})" }
