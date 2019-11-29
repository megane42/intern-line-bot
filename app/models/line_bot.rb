class LineBot
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token  = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

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
          message = {
            type: "text",
            text: event.message["text"]
          }
          client.reply_message(event["replyToken"], message)
        end
      end
    }
  end
end
