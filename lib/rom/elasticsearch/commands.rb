require 'rom/commands'

module ROM
  module Elasticsearch
    class Commands
      class Create < ROM::Commands::Create
        def execute(tuple)
          attributes = input[tuple]
          result = relation.dataset.insert(attributes.to_h)
          relation.get(result['_id'])
        end
      end

      class Update < ROM::Commands::Update
        def execute(data, tuple)
          attributes = input[tuple]
          result = relation.dataset.update(attributes.to_h, data[:_id])
          relation.get(result['_id'])
        end
      end

      class Delete < ROM::Commands::Delete
        def execute(data)
          relation.dataset.delete(data[:_id])
          data
        end
      end
    end
  end
end
