require 'net/http'
require 'json'

CONTENT_POLICY_TEXT = <<~POLICY.freeze
  THE VERIDION BOOK HUNT — CONTENT POLICY

  Books we welcome:
  - Fiction and non-fiction for general audiences
  - Children's, YA, middle-grade, educational, scientific, historical, reference, cookbooks, craft, travel, hobby
  - Classic and contemporary literature, any language

  Books we DO NOT accept:
  - Explicit/adult sexual content or graphic nudity
  - Hate speech or content promoting discrimination/violence based on protected characteristics
  - Detailed instructions for weapons, explosives, illegal drugs, or serious harm
  - Content designed to harass or threaten specific individuals
  - Books submitted with false information about title, author, or condition

  Physical condition standards (minimum: Acceptable):
  - Like New: no wear, clean pages
  - Good: minor wear, no missing pages, no heavy markings
  - Acceptable: visible wear OK, pages intact and readable
  - Poor: generally rejected (unless rare/special)

  Automatic rejection triggers:
  - Strong offensive odor (heavy mold, chemicals, smoke damage)
  - Missing significant pages
  - Extensive writing/highlighting that impairs readability
  - Water damage making the book unreadable

  Disclosed minor issues (light mustiness, pencil notes, minor highlighting) are generally acceptable.
POLICY

class BookAiReviewService
  HACK_CLUB_AI_URL = 'https://ai.hackclub.com/proxy/v1/chat/completions'.freeze
  MODEL            = 'qwen/qwen3-next-80b-a3b-instruct'.freeze

  def initialize(book)
    @book = book
  end

  # Non-streaming: runs to completion, saves result, used by background job
  def call
    result = ''
    stream { |chunk| result += chunk }
    @book.update_columns(ai_review: result, ai_reviewed_at: Time.current)
  rescue => e
    Rails.logger.error "[BookAiReviewService] Failed for book #{@book.id}: #{e.message}"
    @book.update_columns(
      ai_review: "AI review failed: #{e.message}",
      ai_reviewed_at: Time.current
    )
  end

  # Streaming: yields text chunks as they arrive, does NOT save — caller handles persistence
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
    <<~PROMPT
      You are a content moderation assistant for The Veridion Book Hunt, a community book-sharing game.
      Your job is to pre-screen book submissions and produce a structured review for a human admin.

      Do NOT make final approve/reject decisions — only surface findings and flag concerns.
      Be concise. Use plain language. Format your response using Markdown with ## headers and bullet points.
      For bullet points, use "~ " at the start of each bullet line (NOT "- ").
      Never use hyphen bullets. Hyphens may appear inside titles/subtitles and should stay plain text.
      If you need an inline separator in prose, use an em dash (—) instead of a hyphen (-).

      ---
      CONTENT POLICY:
      #{CONTENT_POLICY_TEXT}

      ---
      SUBMISSION TO REVIEW:
      Title: #{@book.title}
      Author: #{@book.author}
      ISBN: #{@book.isbn.presence || 'Not provided'}
      Condition declared: #{@book.condition_label.presence || 'Not specified'}
      Maturity rating (from Google Books): #{@book.maturity_rating.presence || 'Unknown'}
      Submission notes from user: #{@book.submission_notes.presence || 'None'}

      ---
      YOUR REVIEW — respond in exactly this Markdown format. IMPORTANT: always put a blank line between a heading and its content, and between sections. Use "~ " bullets where needed:

      ## Book Lookup

      [What is publicly known about this title and author? Is the title/author combination real and recognized? Any notable content concerns from public knowledge?]

      ## Policy Check

      [Does this submission appear to comply with the content policy? List any specific concerns or red flags. If none, say "No concerns identified."]

      ## Condition Assessment

      [Based on the declared condition and submission notes, does the physical condition seem acceptable? Note any disclosed issues.]

      ## Fraud Signals

      [Any signs this submission might be fraudulent? E.g. nonsensical title, mismatched author/title, invalid ISBN check digit, suspicious notes. If none, say "None detected."]

      ## Recommendation

      [Write ONLY ONE of these three exact words on a line by itself: LOOKS GOOD, NEEDS HUMAN ATTENTION, or LIKELY REJECT — then on the next line, write one sentence explaining why.]
    PROMPT
  end
end
