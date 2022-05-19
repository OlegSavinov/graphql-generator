RSpec.describe 'UpdateEmbedBlock', type: :request, current: true do
  include_context 'authenticated user'

  def query()
    <<~GQL
    mutation UpdateEmbedBlock($id: ID!, $title: String, $description: String, $token: String, $url: String, $startTime: String, $endTime: String, $spotlightedUsers: String, $stageUsers: String, $settings: JSON) {
      updateEmbedBlock(input: {id: $id, title: $title, description: $description, token: $token, url: $url, startTime: $startTime, endTime: $endTime, spotlightedUsers: $spotlightedUsers, stageUsers: $stageUsers, settings: $settings}) {
          id
          title
          description
          token
          url
          startTime
          endTime
          spotlightedUsers
          stageUsers
          settings
        }
      }
    GQL
  end

  it 'update_embed_block success' do
    embed_block = create(:embed_block)
    updated_embed_block = build(:updated_embed_block)
    updated_embed_block.id = embed_block.id
    variables = as_json(updated_embed_block)

    json = graphql(query, variables: variables)
    data = json['updateEmbedBlock']

    expect(data).to include('id' => embed_block.id)
    expect(data).to include('title' => updated_embed_block.title)
    expect(data).to include('description' => updated_embed_block.description)
    expect(data).to include('token' => updated_embed_block.token)
    expect(data).to include('url' => updated_embed_block.url)
    expect(data).to include('startTime' => updated_embed_block.start_time)
    expect(data).to include('endTime' => updated_embed_block.end_time)
    expect(data).to include('spotlightedUsers' => updated_embed_block.spotlighted_users)
    expect(data).to include('stageUsers' => updated_embed_block.stage_users)
    expect(data).to include('settings' => updated_embed_block.settings)
  end
end
