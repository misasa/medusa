class TableRefreshWorker < BaseWorker
#    include Sidekiq::Worker
#    include Sidekiq::Status::Worker
  
    def perform(table_id, opts = {})
      table = Table.find(table_id)
      at 0, "refreshing table #{table.global_id} ..."
      total 1
      table.refresh_data
      table.save
      at 1, "Table refreshing job for #{table.global_id} is done."
    end
  end
  