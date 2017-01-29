RSpec.describe 'Commands / Delete' do
  let(:gateway) { ROM::Elasticsearch::Gateway.new(db_options) }
  let(:conn)    { gateway.connection }

  let!(:env) do
    ROM.container(:elasticsearch, db_options) do |rom|
      rom.relation(:users) do
        def by_id(id)
          where(_id: id)
        end
      end

      rom.commands(:users) do
        define :delete
      end
    end
  end

  let(:rom)     { env }
  let(:users)   { rom.commands[:users] }
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

  it 'deletes all tuples in a restricted relation' do
    found = gateway.dataset(:users).get(element[:_id]).to_a.first
    result = users.try do
      users[:delete].with(found).call
    end

    result = result.value

    expect(result[:name]).to eql('John')
    expect(result[:street]).to eql('Main Street')

    refresh_index(conn)

    result = rom.relation(:users).to_a
    expect(result.count).to eql(0)
  end
end
