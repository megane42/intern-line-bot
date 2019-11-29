class LineBot
  def valid_signature?(request)
    client.validate_signature(
      request.body.read,
      request.env["HTTP_X_LINE_SIGNATURE"]
    )
  end

  def reply_to(request)
    events = client.parse_events_from(request.body.read)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          uid = event["source"]["userId"]
          text = event.message["text"]
          user = User.find_or_initialize_by(uid: uid)

          context = define_context_by(text)
          action  = define_action_by(context, user)
          message = "ちょっと何言ってるかわかんないですね"

          case action
          when :hear_name
            user.save
            message = "はじめまして！名前を教えてもらえますか？（この名前は Slack に投稿されます）"
          when :remember_name
            user.update(slack_name: text)
            message = "覚えました！すいません、もう 1 回施錠ボタンを押してください..."
          when :notify_slack
            user.lockings.create(floor: extract_floor_from(text))
            message = "いつも遅くまでお疲れさまです！"
          end

          client.reply_message(event["replyToken"], text_message(message))
        end
      end
    }
  end

  private
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token  = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    def define_context_by(user_text)
      if ["4F 施錠しました", "2F 施錠しました"].include?(user_text)
        :locking
      else
        :naming
      end
    end

    def define_action_by(context, user)
      case context
      when :locking
        case user.state
        when :new, :name_hearing
          :hear_name
        when :confirmed
          :notify_slack
        end
      when :naming
        case user.state
        when :name_hearing
          :remember_name
        end
      end
    end

    def extract_floor_from(user_text)
      if user_text.include?("4F")
        "4F"
      elsif user_text.include?("2F")
        "2F"
      end
    end

    def text_message(text)
      {
        type: "text",
        text: text
      }
    end
end
