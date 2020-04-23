set :output, {:error => 'log/error.log', :standard => 'log/cron.log'}

every :day, at: "1:00am" do
  rake "backup"
end

every :day, at: "5:00am" do
  runner 'Table.refresh_data'
end
