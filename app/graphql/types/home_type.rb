
module Types
  class HomeType < Types::BaseObject
    field :number, Integer
    field :cilivilianss, [CiliviliansType]
    field :hight, Integer
    field :index, String
    

    field :created_at, String, null: true
    field :updated_at, String, null: true
  end
end
