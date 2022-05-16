module Mutations
  class DeleteHome < BaseMutation
    include Guardian
    argument :id, ID, required: true

    type Types::HomeType

    def resolve(**params)
      check_authentication!
      delete_home(params)
    end

   private

   def delete_home(params)
     home = Home.find(params[:id])

     if home.destroy
        home
      else
        raise GraphQL::ExecutionError, "Invalid input: #{home.errors.full_messages.join(', ')}"
      end
    end
  end
end
