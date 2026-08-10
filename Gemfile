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
  gem 'html-proofer', '~> 5.0'
  # html-proofer 5.2.2 extracts zero links under nokogiri 1.18.x -- proven with
  # a hand-written control file, both inside and outside the bundle. Pin to the
  # 1.16 series, which github-pages also accepts (it wants >= 1.13.6, < 2.0).
  gem 'nokogiri', '~> 1.16.0'
end
