class Locking < ApplicationRecord
  belongs_to :user
  after_create :notify_on_slack

  def notify_on_slack
    p "#{user.slack_name} さんが #{floor} の施錠をしました（通算 #{Locking.where(user: user).count} 回目）"
  end
end
