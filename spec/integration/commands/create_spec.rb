RSpec.describe 'Commands / Create' do
  let(:gateway) { ROM::Elasticsearch::Gateway.new(db_options) }
  let(:conn)    { gateway.connection }

  let!(:env) do
    ROM.container(:elasticsearch, db_options) do |rom|
      rom.relation(:users)

      rom.commands(:users) do
        define(:create) do
          input ->(attrs) { attrs.merge('street' => attrs['street'].upcase) }
        end
      end
    end
  end

  let(:rom)     { env }
  let(:users)   { rom.commands[:users] }
  let(:data)    { Hash['name' => 'John Doe', 'street' => 'Main Street'] }

  before { create_index(conn) }

  it 'returns a tuple' do
    result = users.try do
      users[:create].call(data)
    end

    result = result.value.to_a.first
    expect(result[:name]).to eql(data['name'])
    expect(result[:street]).to eql('MAIN STREET')

    refresh_index(conn)

    result = rom.relation(:users).to_a.first
    expect(result[:name]).to eq('John Doe')
  end
end
