class Locking < ApplicationRecord
  belongs_to :user
  after_create :notify_on_slack

  def self.ranking
    ranking_hash = select(:user_id).group(:user_id).order("count_user_id desc").limit(5).count
    ranking_hash.reduce("") do |str, arr|
      user_id = arr[0]
      count   = arr[1]
      str += "#{User.find(user_id).slack_name} さん : #{count} 回\n"
    end
  end

  def notify_on_slack
    notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"]
    notifier.ping <<~"EOF"
      #{user.slack_name} さんが #{floor} の施錠をしました（通算 #{Locking.where(user: user).count} 回目）
      ----------
      ■ 通算成績
      #{Locking.ranking}
    EOF
  end
end
