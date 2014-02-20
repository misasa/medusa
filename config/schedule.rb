set :output, {:error => 'error.log', :standard => 'cron.log'}

every :day, at: "1:00am" do
  rake "backup"
end
