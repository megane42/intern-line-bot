class User < ApplicationRecord
  has_many :lockings

  def state
    if new_record?
      :new
    elsif slack_name.nil?
      :name_hearing
    else
      :confirmed
    end
  end
end
