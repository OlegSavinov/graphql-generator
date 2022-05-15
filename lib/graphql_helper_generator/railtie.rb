module GraphqlHelperGenerator
	def self.root
		File.dirname __dir__
	end

	class MyRailtie < Rails::Railtie
		generator_path = GraphqlHelperGenerator::root.+'/graphql_helper_generator/graphql_model/graphql_model_generator.rb'

		config.app_generators do
			require generator_path
		end
	end
end
