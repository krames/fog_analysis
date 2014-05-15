require 'fog'

# Monkey patch classes so they don't attempt to do any setup
module Fog
  class Service
    def self.new(options={}) 
      # setup collections and models on service
      setup_requirements
      
      service::Real.class_eval do
        def initialize(options)
          # skip initialization for introspection purposes
        end
      end
      
      service::Real.send(:include, service::Collections)
      service::Real.send(:include, service::NoLeakInspector)
      service::Real.new(options)
    end
  end
end

def name(obj)
  obj_klass = obj.is_a?(Class) ? obj : obj.class
  obj_klass.to_s.split('::').last
rescue
  ''
end

def collection_key(col)
  "#{name(col)}/#{name(col.model)}"
end

def method_key(klass, method)
  "#{name(klass)}##{method}"
end

def service_to_introspect
  return @service if @service
  arg = ARGV.first || 'storage'
  @service = Fog.const_get arg.capitalize
end

collections = {}
collection_methods = {}
model_methods = {}
    
Fog.providers.keys.each do |provider|
  begin
    next unless service_to_introspect.providers.include?(provider)

    service = service_to_introspect[provider]
    service.collections.each do |col_method|
      col = service.send col_method
      col.clear # disable lazy load
      model = col.model 
      
      #create map of collections/models to provider
      collections[collection_key(col)] ||= []
      collections[collection_key(col)] << provider
      
      #create map of model#method to provider
      methods = model.methods - Fog::Model.new.methods
      methods.each do |method|
        model_methods[method_key(model, method)] ||= []
        model_methods[method_key(model, method)] << provider
      end

      #create map of collection#method to provider
      methods = col.methods - Fog::Collection.new.methods
      methods.each do |method|
        collection_methods[method_key(col, method)] ||= []
        collection_methods[method_key(col, method)] << provider
      end
      
    end
  rescue => e
  $stderr.puts e
  $stderr.puts e.backtrace if ENV['BACKTRACE']
  end
end; nil

def print_section(collection)
  sorted_keys = collection.keys.sort
  sorted_keys.each do |key|
    puts "  * **#{key}** (#{collection[key].join(", ")})"  
  end
end

puts "## Collection/Models Used By Provider"
print_section collections

puts "\n"
puts "## Collection Methods Implemented By Provider"
print_section collection_methods
  
puts "\n"
puts "## Model Methods Implemented By Provider"
print_section model_methods






# puts collections
#puts collection_methods
model_methods


