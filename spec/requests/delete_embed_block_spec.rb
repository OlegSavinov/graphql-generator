RSpec.describe 'DeleteEmbedBlock', type: :request, current: true do
  include_context 'authenticated user'

  def query()
    <<~GQL
    mutation DeleteEmbedBlock($id: ID!) {
      deleteEmbedBlock(input: {id: $id}) {
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

  it 'delete_embed_block success' do
    embed_block = create(:embed_block)
    variables = { id: embed_block.id }

    json = graphql(query, variables: variables)
    data = json['deleteEmbedBlock']

    expect(data).to include('id' => embed_block.id)
    # expect(data).to include('title' => embed_block.title)
    # expect(data).to include('description' => embed_block.description)
    # expect(data).to include('token' => embed_block.token)
    # expect(data).to include('url' => embed_block.url)
    # expect(data).to include('startTime' => embed_block.start_time)
    # expect(data).to include('endTime' => embed_block.end_time)
    # expect(data).to include('spotlightedUsers' => embed_block.spotlighted_users)
    # expect(data).to include('stageUsers' => embed_block.stage_users)
    # expect(data).to include('settings' => embed_block.settings)

    expect(EmbedBlock.count).to eq(0)
  end
end
