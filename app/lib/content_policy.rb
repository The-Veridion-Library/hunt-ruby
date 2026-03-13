# app/lib/content_policy.rb
# Referenced by BookAiReviewService when prompting the AI.
# Keep this in sync with the Linear document: TVBH Content Policy

module ContentPolicy
  TEXT = <<~POLICY.freeze
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
    - Water damage that makes the book unreadable

    Disclosed minor issues (light mustiness, pencil notes, minor highlighting) are generally acceptable.
  POLICY
end