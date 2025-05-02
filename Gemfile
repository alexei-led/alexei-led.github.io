source "https://rubygems.org"

gem "jekyll", "~> 3.9.3"
gem "minima", "~> 2.5.1"
gem "github-pages", "~> 228", group: :jekyll_plugins
gem "jekyll-feed", "~> 0.15.1"
gem "jekyll-seo-tag", "~> 2.8.0"
gem "csv" # Required for Ruby 3.4+
gem "webrick" # Required for Ruby 3.4+
gem "faraday-retry" # For Faraday retry middleware

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]
