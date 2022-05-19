module Mutations
  class UpdateEmbedBlock < BaseMutation
    include Guardian
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :token, String, required: false
    argument :url, String, required: false
    argument :start_time, String, required: false
    argument :end_time, String, required: false
    # argument :meeting_id, ID, required: false
    argument :spotlighted_users, [String], required: false
    argument :stage_users, [String], required: false
    argument :settings, GraphQL::Types::JSON, required: false
    

    type Types::EmbedBlockType

    def resolve(**params)
      check_authentication!
      update_embed_block(params)
    end

   private

   def update_embed_block(params)
     embed_block = EmbedBlock.find(params[:id])

     if embed_block.update(params)
        embed_block
      else
        raise GraphQL::ExecutionError, "Invalid input: #{embed_block.errors.full_messages.join(', ')}"
      end
    end
  end
end
