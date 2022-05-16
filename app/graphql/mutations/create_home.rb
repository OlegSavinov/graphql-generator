module Mutations
  class CreateHome < BaseMutation
    include Guardian
    argument :number, Integer, required: false
    # argument :cilivilianss, [CiliviliansInputType], required: false
    argument :hight, Integer, required: false
    argument :index, String, required: false
    

    type Types::HomeType

    def resolve(**params)
      check_authentication!
      create_home(params)
    end

   private

   def create_home(params)
     home = Home.new(params)

     if home.save
        home
      else
        raise GraphQL::ExecutionError, "Invalid input: #{home.errors.full_messages.join(', ')}"
      end
    end
  end
end
