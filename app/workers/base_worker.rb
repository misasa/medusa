class BaseWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    sidekiq_options retry: 1
    sidekiq_retries_exhausted do |msg, ex|
        Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
        notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
            channel: ENV['SLACK_CHANNEL_SIDEKIQ_FAILURE'],
            username: "sidekiq-bot"

        attachments = [{
          title: "Sidekiq failure",
          text: "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}",
          #text: "%s failure \n QueueName %s \n Error %s \n JobId %s \n Arguments %s" % [self.class, self.queue_name, e.inspect, self.job_id, self.arguments],
          color: "#fb2489"
        }]
        notifier.post attachments: attachments
    end

    def perform()
    end    
end