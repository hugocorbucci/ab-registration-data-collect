namespace :data_collect do
  MAX_INTERVAL_STEP = 30
  MAX_DATE_IN_THE_PAST = 179
  desc 'Generate AgileBrazil registration report'
  task collect: :environment do

    credential = Credentials.first
    PagSeguro.configure do |config|
      config.token = credential.token
      config.email = credential.email
    end

    intervals = (0..MAX_DATE_IN_THE_PAST).step(MAX_INTERVAL_STEP).to_a.reverse
    reports = intervals.map do |start|
      PagSeguro::Transaction.find_by_date(starts_at: (start + MAX_INTERVAL_STEP).days.ago, ends_at: [start.days.ago - 1.second, 1.second.ago].min)
    end

    transaction_ab = AB_Transaction.new
    transaction_ab.count_statuses reports
    transaction_ab.save!

    p 'Report generated'
  end
end
