class User < ApplicationRecord
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
