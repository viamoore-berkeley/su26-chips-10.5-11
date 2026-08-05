# frozen_string_literal: true

module RepresentativesHelper
  def twitter_url(handle)
    "https://twitter.com/#{handle.to_s.delete_prefix('@')}"
  end

  def facebook_url(handle)
    "https://www.facebook.com/#{handle}"
  end

  def youtube_url(handle)
    "https://www.youtube.com/#{handle}"
  end
end
