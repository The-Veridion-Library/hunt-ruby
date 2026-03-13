require 'net/http'
require 'json'

class LocationAiReviewService
  HACK_CLUB_AI_URL = 'https://ai.hackclub.com/proxy/v1/chat/completions'.freeze
  MODEL            = 'google/gemini-2.5-flash'.freeze

  def initialize(location)
    @location = location
  end

  # Non-streaming: used by background job
  def call
    result = ''
    stream { |chunk| result += chunk }
    @location.update_columns(ai_review: result, ai_reviewed_at: Time.current)
  rescue => e
    Rails.logger.error "[LocationAiReviewService] Failed for location #{@location.id}: #{e.message}"
    @location.update_columns(
      ai_review: "AI review failed: #{e.message}",
      ai_reviewed_at: Time.current
    )
  end

  # Streaming: yields text chunks, does NOT save — caller handles persistence
  def stream(&block)
    api_key = ENV.fetch('HACK_CLUB_AI_KEY', nil)
    unless api_key
      yield "⚠️ AI review skipped — HACK_CLUB_AI_KEY environment variable not set."
      return
    end

    uri  = URI(HACK_CLUB_AI_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.read_timeout = 180
    http.open_timeout = 15

    request = Net::HTTP::Post.new(uri)
    request['Content-Type']  = 'application/json'
    request['Authorization'] = "Bearer #{api_key}"
    request.body = JSON.generate({
      model:    MODEL,
      messages: [{ role: 'user', content: build_prompt }],
      temperature: 0.3,
      max_tokens:  900,
      stream:      true
    })

    http.request(request) do |response|
      response.read_body do |raw_chunk|
        raw_chunk.split("\n").each do |line|
          next unless line.start_with?('data: ')
          payload = line[6..]
          next if payload.strip == '[DONE]'
          begin
            parsed = JSON.parse(payload)
            content = parsed.dig('choices', 0, 'delta', 'content')
            yield content if content.present?
          rescue JSON::ParserError
            # skip malformed SSE lines
          end
        end
      end
    end
  end

  private

  def build_prompt
    website_note = if @location.website.present?
      "Website provided: #{@location.website} — please consider what you know about this URL/domain when researching the venue."
    else
      "No website provided."
    end

    <<~PROMPT
      You are a location vetting assistant for The Veridion Book Hunt, a community book-hiding and finding game.
      Your job is to research nominated venue locations and produce a structured review for a human admin.

      The game places QR-coded books at partner locations (libraries, bookstores, cafes, parks, etc.).
      Partners must be public-facing, welcoming of community book programs, and appropriate for all ages.

      Do NOT make final approve/decline decisions — only surface findings and flag concerns.
      Be concise. Use plain language. Format your response using Markdown with ## headers and bullet points.

      ---
      LOCATION SUBMISSION:
      Name: #{@location.name}
      Type: #{@location.location_type}
      Address: #{@location.full_address}
      #{website_note}
      Contact hint: #{@location.contact_name.presence || 'Not provided'}
      Nomination notes: #{@location.nomination_notes.presence || 'None'}

      ---
      YOUR REVIEW — respond in exactly this Markdown format. IMPORTANT: always put a blank line between a heading and its content, and between sections:

      ## Venue Research

      [What do you know about this venue? Is it a recognized business or public space? What kind of place is it? How well-established does it appear to be?]

      ## Chain or Independent?

      [Is this a chain/franchise location (e.g. Starbucks, Barnes & Noble, McDonald's) or an independent local venue? Chains may have corporate policies that complicate partnerships. Note which it is and any implications.]

      ## Existing Book Programs

      [Does this venue appear to already have a book exchange, Little Free Library, or similar community reading program? If so, describe it — this could be a strong positive signal.]

      ## Address Validation

      [Does the address appear real and plausible? Does the name match what would be expected at that address based on your knowledge? Flag anything suspicious.]

      ## Suitability Assessment

      [Is this venue type generally suitable for hiding books? Consider: is it public-facing, open reasonable hours, appropriate for all ages, and likely to welcome a book-sharing program?]

      ## Concerns

      [List any red flags, concerns, or things the admin should investigate further. If none, say "None identified."]

      ## Recommendation

      [Write ONLY ONE of these three exact words on a line by itself: LOOKS GOOD, NEEDS HUMAN ATTENTION, or LIKELY DECLINE — then on the next line, write one sentence explaining why.]
    PROMPT
  end
end
