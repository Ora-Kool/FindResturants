require "support/number_helper"
class Restaurant
	include NumberHelper
	@@filepath = nil # class variable, this can't be accessiable outside the class

	#all the methods with self. are class method
	#accessing filepath from outside the class
	def self.filepath=(path=nill)
		@@filepath = File.join(APP_ROOT, path)
	end

	#creating accessor methods
	attr_accessor :name, :cuisine, :price

	#checking if the restaurant file exist
	def self.file_exists?
		#class should know if the restaurant file exists
		if @@filepath && File.exists?(@@filepath)
			return true
		else
			return false
		end
	end

	#default method to check if file is usable
	def self.file_usable?
		return false unless @@filepath
		return false unless File.exists?(@@filepath)
		return false unless File.readable?(@@filepath)
		return false unless File.writable?(@@filepath)
		return true
	end

	#create the file if it doesnt't exist
	def self.create_file
		#create the restaurant file
		File.open(@@filepath, 'w') unless file_exists?
			return file_usable?
	end

	#save the file when you create it
	def self.saved_restaurants
		#read the restaurant file
		#return instances of restaurant
		restaurants = []
		if file_usable?
			file = File.new(@@filepath, 'r')
			file.each_line do |line|
				restaurants << Restaurant.new.import_line(line.chomp)
			end
			file.close
		end
		return restaurants
	end

	def self.build_from_questions
		
        args = {}
        print "Restaurant name: "
        args[:name] = gets.chomp.strip

        print "Cuisine type: "
        args[:cuisine] = gets.chomp.strip

        print "Average price: "
        args[:price] = gets.chomp.strip

          return self.new(args)
	end

	#end of class method

	def initialize(args={})
		@name 	 = args[:name] 	  || ""
		@cuisine = args[:cuisine] || ""
		@price   = args[:price]   || ""
	end

	def import_line(line)
		line_array = line.split("\t")
		@name, @cuisine, @price = line_array
		return self #return an instance 
	end

	def save #this is an instance method which could be accessed from an instance variable
		return false unless Restaurant.file_usable? #since the save method is an instance method, to access
		File.open(@@filepath, 'a') do |file|		#the Restaurant class method we need the class name . the method 
			file.puts "#{[@name, @cuisine, @price].join("\t")}\n"
		end											
		return true
	end

	def formatted_price
		number_to_currency(@price)
	end

	
	
end