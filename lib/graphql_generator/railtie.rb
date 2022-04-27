module GraphQLGenerator
	def self.root
		File.dirname __dir__
	end

	class MyRailtie < Rails::Railtie
		generator_path = GraphQLGenerator::root.+'/graphql_generator/graphql/graphql_generator.rb'

		config.app_generators do
			require generator_path
		end
	end
end
