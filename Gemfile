source 'https://rubygems.org'

group :jekyll_plugins do
  gem 'jekyll'
  gem 'jekyll-feed'
  gem 'jekyll-sitemap'
  gem 'jekyll-redirect-from'
  gem 'jemoji'
  gem 'webrick', '~> 1.8'
end

gem 'github-pages'
gem 'connection_pool', '2.5.0'

group :test do
  # No html-proofer: every 5.x release reports "Checking 0 internal links" and
  # passes a control document with a deliberately broken link. See
  # .github/scripts/check-links.rb, which uses nokogiri (already present via
  # jekyll) to do the internal link checking directly.
  gem 'nokogiri'
end
