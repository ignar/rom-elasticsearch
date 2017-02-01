module Helpers
  def db_options
    { url: "http://#{ENV.fetch('ELASTICSEARCH_URL')}", index: ENV.fetch('ELASTICSEARCH_INDEX') }
  end

  def create_index(connection)
    if connection.indices.exists?(index: ENV.fetch('ELASTICSEARCH_INDEX'))
      connection.delete_by_query(index: ENV.fetch('ELASTICSEARCH_INDEX'), body: {query: {match_all: {}}})
    else
      connection.indices.create(index: ENV.fetch('ELASTICSEARCH_INDEX'))
    end
  rescue
  end

  def refresh_index(connection)
    connection.indices.refresh(index: ENV.fetch('ELASTICSEARCH_INDEX'))
  end
end
