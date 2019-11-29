require 'line/bot'

class WebhookController < ApplicationController
  protect_from_forgery except: [:callback] # CSRF対策無効化

  def callback
    line_bot = LineBot.new

    unless line_bot.valid_signature?(request)
      head 470
    end

    line_bot.reply_to(request)
    head :ok
  end
end
