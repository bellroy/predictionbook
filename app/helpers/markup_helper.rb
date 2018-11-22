# frozen_string_literal: true

module MarkupHelper
  # A copy of the private AUTO_LINK_RE from ActionView::Helpers::TextHelper,
  # slightly simplified.
  SIMPLER_AUTO_LINK_RE = %r{
    (                          # leading text
      <\w+.*?>|                # leading HTML tag, or
      [^=!:'"/]|               # leading punctuation, or
      ^                        # beginning of line
    )
    (
      https?://
      [-\w]+                   # subdomain or domain
      (?:\.[-\w]+)*            # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[~\w\+@%=\(\)-]|(?:[,.;:][^\s$]))+)?)* # path
      (?:\?[\w\+@%&=.;-]+)?    # query string
      (?:\#[\w\-]*)?           # trailing anchor
    )
    ([[:punct:]]|<|$|)       # trailing text
   }x.freeze

  def show_user(user, cls = nil)
    link_to h(user), user_path(user), class: classes('user', cls)
  end

  def confidence_and_count(prediction)
    "#{prediction.wager_count} with #{prediction.mean_confidence}%"
  end

  def linkify_for_redcloth(text)
    text.gsub(SIMPLER_AUTO_LINK_RE) do
      all = $&
      leading = Regexp.last_match(1)
      url = Regexp.last_match(2)
      trailing = Regexp.last_match(3)
      %(#{leading}"#{url}":#{url}#{trailing})
      # The above is slightly wrong because *bold* and _italic_ in
      # "{url}:" portion (the link text, equivalent to the target)
      # will be made bold/italic by RedCloth.  But that's slightly tricky to
      # fix, and the URL points to the correct target anyway.
    end
  end

  def markup(text)
    CleanCloth.new(linkify_for_redcloth(text)).to_html
  end

  def classes(*args)
    args.flatten.compact.join(' ')
  end

  def certainty_heading(heading)
    case heading
    when '100'
      link_to heading, 'http://en.wikipedia.org/wiki/Almost_surely', class: 'egg', title: 'Almost surely'
    else
      heading
    end
  end

  def outcome(prediction)
    content_tag(:span, title: prediction.readable_outcome) do
      case prediction.outcome
      when true then '✔'
      when false then '✘'
      else '?'
      end
    end
  end

  def style_for_confidence(confidence)
    # http://www.w3.org/TR/css3-color/#hsl-examples
    "background-color: hsl(#{(confidence * (200 / 100.0) - 70)}, 100%, 90%);".html_safe
  end
end
