RSpec.describe 'CreateHome', type: :request do
  include_context 'authenticated user'

  def query()
    <<~GQL
    mutation CreateHome($number: Int, $hight: Int, $indexNew: String!) {
      createHome(input: {number: $number, hight: $hight, indexNew: $indexNew}) {
          id
          number
          cilivilians
          hight
          indexNew
        }
      }
    GQL
  end

  it 'create_home success' do
    home = build(:home)
    variables = as_json(home)

    json = graphql(query, variables: variables)
    data = json['createHome']

    expect(data).to include('id' => be_present)
  end
end
