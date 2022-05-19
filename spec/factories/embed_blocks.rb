FactoryBot.define do
  factory :embed_block do
    title {  "My title " + rand(1..10000).to_s }
    description {  "My description " + rand(1..10000).to_s }
    token {  "My token " + rand(1..10000).to_s }
    url {  "My url " + rand(1..10000).to_s }
    start_time { (Time.now + 5.hours).to_s }
    end_time { (Time.now + 1.hours).to_s }
    meeting { create(:meeting) }
    spotlighted_users { [ "My spotlighted_users " + rand(1..10000).to_s] }
    stage_users { [ "My stage_users " + rand(1..10000).to_s] }
    settings { {:hello=>:world, :new=>1} }

    factory :updated_embed_block do
      title {  "My title updated " + rand(1..10000).to_s }
      description {  "My description updated " + rand(1..10000).to_s }
      token {  "My token updated " + rand(1..10000).to_s }
      url {  "My url updated " + rand(1..10000).to_s }
      start_time { (Time.now + 2.hours).to_s }
      end_time { (Time.now + 2.hours).to_s }
      meeting { create(:meeting) }
      spotlighted_users { [ "My spotlighted_users updated " + rand(1..10000).to_s] }
      stage_users { [ "My stage_users updated " + rand(1..10000).to_s] }
      settings { {:hello=>:updated_world, :updated=>100} }
    end
  end
end
