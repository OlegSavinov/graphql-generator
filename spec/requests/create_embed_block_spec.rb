RSpec.describe 'CreateEmbedBlock', type: :request, current: true do
  include_context 'authenticated user'

  def query()
    <<~GQL
    mutation CreateEmbedBlock($title: String!, $description: String, $token: String, $url: String, $startTime: String, $endTime: String, $meetingId: ID, $spotlightedUsers: [String], $stageUsers: [String], $settings: JSON) {
      createEmbedBlock(input: {title: $title, description: $description, token: $token, url: $url, startTime: $startTime, endTime: $endTime, meetingId: $meetingId, spotlightedUsers: $spotlightedUsers, stageUsers: $stageUsers, settings: $settings}) {
          id
          title
          description
          token
          url
          startTime
          endTime
          meeting { id } 
          spotlightedUsers
          stageUsers
          settings
        }
      }
    GQL
  end

  it 'create_embed_block success' do
    meeting = create(:meeting)
 
    embed_block = build(:embed_block , meeting: meeting)
    variables = as_json(embed_block)

    json = graphql(query, variables: variables)
    data = json['createEmbedBlock']

    expect(data).to include('id' => be_present)
    expect(data).to include('title' => embed_block.title)
    expect(data).to include('description' => embed_block.description)
    expect(data).to include('token' => embed_block.token)
    expect(data).to include('url' => embed_block.url)
    expect(data).to include('startTime' => embed_block.start_time)
    expect(data).to include('endTime' => embed_block.end_time)
    expect(data).to include('spotlightedUsers' => embed_block.spotlighted_users)
    expect(data).to include('stageUsers' => embed_block.stage_users)
    expect(data).to include('settings' => embed_block.settings)
  end
end
