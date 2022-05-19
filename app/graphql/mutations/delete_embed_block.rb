module Mutations
  class DeleteEmbedBlock < BaseMutation
    include Guardian
    argument :id, ID, required: true

    type Types::EmbedBlockType

    def resolve(**params)
      check_authentication!
      delete_embed_block(params)
    end

   private

   def delete_embed_block(params)
     embed_block = EmbedBlock.find(params[:id])

     if embed_block.destroy
        embed_block
      else
        raise GraphQL::ExecutionError, "Invalid input: #{embed_block.errors.full_messages.join(', ')}"
      end
    end
  end
end
