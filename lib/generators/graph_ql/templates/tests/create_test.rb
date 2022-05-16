RSpec.describe 'CreateMeeting', type: :request do
  include_context 'authenticated user'

  def query()
  <%= "<<~GQL" %>
      mutation create<%= @camelize_name %>($title: String!, $introduction: String, $description: String, $zoomLink: String, $status: String, $state: JSON, $startTime: String, $endTime: String, $companyId: ID, $settings: JSON!) {
        createMeeting(input: {title: $title, introduction: $introduction, description: $description, zoomLink: $zoomLink, status: $status, state: $state, startTime: $startTime, endTime: $endTime, companyId: $companyId, settings: $settings}) {
          id
          title
          introduction
          description
          zoomLink
          status
          state
          startTime
          endTime
          settings
          token
          company {
            id
          }
          owner {
            id
          }
          guests {
            id
          }
          hosts {
            id
          }
        }
      }
    GQL
  end

  it 'create_meeting success' do
    # s = Sequence.new({title: "Title"})
    # s.save
    company = create(:company)
    meeting = build(:meeting, owner: current_user, company: company)
    variables = as_json(meeting)

    json = graphql(query, variables: variables)
    data = json['createMeeting']

    expect(data).to include('id' => be_present)
    expect(data).to include('token' => be_present)
    expect(data).to include('title' => meeting.title)
    expect(data).to include('introduction' => meeting.introduction)
    expect(data).to include('status' => meeting.status)
    expect(data).to include('startTime' => meeting.start_time)
    expect(data).to include('endTime' => meeting.end_time)
    expect(data).to include('settings' => {"hello"=>"world"})
    expect(data['owner']).to include('id' => meeting.owner.id)
    expect(data['company']).to include('id' => company.id)
    expect(data['hosts']).to eq([{'id' => meeting.owner.id}])
  end
end
