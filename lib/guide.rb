 require "restaurant"
 require "support/string_extend"
class Guide
    class Config
        @@actions = ['list', 'find', 'add', 'quit', 'exit']
        def self.actions; @@actions; end
    end

	def initialize(path=nil)
		#Locate the resturant text file at path
		#or create a new file
		#exit if create fails
		Restaurant.filepath = path

		#check if the restaurant file exists if not do elseif
		if Restaurant.file_usable?
			puts "Found Restaurant File." #tell me if the file is already created

			#creating a new file
			elsif Restaurant.create_file

				puts "Restaurant file created."
		 	else
		 		puts "Exiting.\n\n"
		 		exit! #just abort
		 	end
	end

	def launch!
		#action loop
		#   what do you want to do? (list, find, add, quit)
		#   do that action 
		#repeat until user quits

		intro #this method welcomes you to the Food Finder application
        #keep repeating the action
        result = nil
		until result == :quit || result == :exit
		  action, args = get_action
		 result = do_action(action, args)
		end

		conclude #this is th closing method that tells users goodbye
	end

    def get_action
        action = nil
        until Guide::Config.actions.include?(action) #how to access a class inside a class using :: double colon,
                                                     #and using . notation to access the class methods
            puts "Actions: "+ Guide::Config.actions.join(", ") if action
            print "> " #prompt user
            user_response = gets.chomp
            args = user_response.downcase.strip.split(' ')
            action = args.shift
        end
         return action, args
    end

	def do_action(action, args=[])
		case action
        when 'list'
            list(args)
        when 'find'
            keyword = args.shift
            find(keyword)

            if keyword
                #search
                restaurants = Restaurant.saved_restaurants
                found = restaurants.select do |rest|
                  rest.name.downcase.include?(keyword.downcase) ||
                  rest.cuisine.downcase.include?(keyword.downcase) ||
                  rest.price.to_i <= keyword.to_i
                end
                output_restaurant_table(found)
            else
                puts "Find using a key phrase to search the restaurant list."
                puts "Examples: 'find eya', 'find example', etc \n\n"
              
            end
        when 'add'
            add # invoking the add method
        when 'quit'
            return :quit
       when 'exit'
            return :exit
        else
            puts "\nI don't understand your command.\n"
        end
            
                
	end

    def list(args=[])
      sort_order = args.shift
      sort_order = args.shift if sort_order == 'by'
      sort_order = "name" unless ['name', 'cuisine', 'price'].include?(sort_order)
      
      
        output_action_header("Listing restaurants by #{sort_order}")
        
        
        restaurants = Restaurant.saved_restaurants  
         restaurants.sort! do |r1, r2|
           case sort_order
           when 'name'
             r1.name.downcase <=> r2.name.downcase
             when 'cuisine'
             r1.cuisine.downcase <=> r2.name.downcase
             when 'price'
             r1.price.to_i <=> r2.price.to_i
             end
         end
        
        output_restaurant_table(restaurants)
        puts "Sort using: 'list cuisine', or 'list by cuisine'"
    end

    def find(keyword="")
        output_action_header("Find a restaurant #{keyword}")
    end

    def add
        output_action_header("Add a restaurant")
        #now create an instance of the restaurant
        
        restaurant = Restaurant.build_from_questions
        #now, when all the attributes have being entered, the restaurant instance has to be saved!

        if restaurant.save
            puts "\nRestaurant Added!\n\n"
        else
            puts "\nSave error!: restaurant not added\n\n"
        end
    end
	
	def intro
		puts "\n\n<<< Welcome to the Food Finder >>>\n\n"
		puts "This is an interactive guide to help you find the food you crave.\n\n"
	end

	def conclude
		puts "\n<<< GoodBye and Enjoy your meal! >>>\n\n\n"
	end

    private 

    def output_action_header(text)
        puts "\n#{text.upcase.center(60)}\n\n\n"
    end

    def output_restaurant_table(restaurants=[])
        print " " + "Name".ljust(30)
        print " " + "Cuisine".ljust(20)
        print " " + "Price".rjust(6) + "\n"
        puts "-" * 60
        restaurants.each do |rest|
            line = " " << rest.name.titleize.ljust(30)
            line <<  " " +rest.cuisine.titleize.ljust(20)
            line << " "  + rest.formatted_price.rjust(6)
            puts line
        end
        puts "No listings found" if restaurants.empty?
        puts "-" * 60
    end
	
end