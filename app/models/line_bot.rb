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
          context = define_context_by(event.message["text"])
          message = define_message_by(context, event["source"]["userId"], event.message["text"])
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

    def define_message_by(context, user_id, user_text)
      user = User.find_or_initialize_by(uid: user_id)
      case context
      when :locking
        if user.new_record?
          "はじめまして！名前を教えてもらえますか？（この名前は Slack に投稿されます）"
        else
          "いつも遅くまでお疲れさまです！"
        end
      when :naming
        if user.new_record?
          user.slack_name = user_text
          user.save
          "覚えました！お疲れさまでした。"
        else
          "ちょっと何言ってるかわかんないですね"
        end
      end
    end

    def text_message(text)
      {
        type: "text",
        text: text
      }
    end
end
