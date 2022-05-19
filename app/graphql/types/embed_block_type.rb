module Types
  class EmbedBlockType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :token, String, null: true
    field :url, String, null: true
    field :start_time, String, null: true
    field :end_time, String, null: true
    field :meeting, MeetingType, null: true
    field :meeting_id, ID, null: true
    field :spotlighted_users, [String], null: true
    field :stage_users, [String], null: true
    field :settings, GraphQL::Types::JSON, null: true
    

    field :created_at, String, null: true
    field :updated_at, String, null: true
  end
end
