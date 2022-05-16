module Mutations
  class UpdateHome < BaseMutation
    include Guardian
    argument :id, ID, required: true
    argument :number, Integer, required: false
    # argument :cilivilianss, [CiliviliansInputType], required: false
    argument :hight, Integer, required: false
    argument :index, String, required: false
    

    type Types::HomeType

    def resolve(**params)
      check_authentication!
      update_home(params)
    end

   private

   def update_home(params)
     home = Home.find(params[:id])

     if home.update(params)
        home
      else
        raise GraphQL::ExecutionError, "Invalid input: #{home.errors.full_messages.join(', ')}"
      end
    end
  end
end
