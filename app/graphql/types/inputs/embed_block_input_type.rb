class Types::Inputs::EmbedBlockInputType < Types::BaseInputObject
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
  
end
