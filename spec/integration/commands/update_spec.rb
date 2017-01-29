RSpec.describe 'Commands / Updates' do
  let(:gateway) { ROM::Elasticsearch::Gateway.new(db_options) }
  let(:conn)    { gateway.connection }

  let!(:env) do
    ROM.container(:elasticsearch, db_options) do |rom|
      rom.relation(:users) do
        def get_by_id(id)
          dataset.get(id)
        end
      end

      rom.commands(:users) do
        define :update do
          relation :users
          result :one
          register_as :update
        end
      end
    end
  end

  let(:rom)     { env }
  let(:users)   { rom.command(:users) }
  let(:element) { rom.relation(:users).to_a.first }

  before { create_index(conn) }

  before do
    [
      { name: 'John', street: 'Main Street' }
    ].each do |data|
      gateway.dataset('users') << data
    end

    refresh_index(conn)
  end

  it 'has data' do
    expect(element[:name]).to eql('John')
    expect(element[:street]).to eql('Main Street')
  end

  it 'partial updates on original data' do
    found = gateway.dataset(:users).get(element[:_id]).to_a.first
    result = users.try do
      users[:update].with(found).call(street: '2nd Street')
    end

    result = result.value
    expect(result[:name]).to eq('John')
    expect(result[:street]).to eq('2nd Street')
  end
end
