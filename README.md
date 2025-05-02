# Personal Blog

This is a Jekyll-based blog hosted on GitHub Pages at [alexei-led.github.io](https://alexei-led.github.io).

## About

This blog uses Jekyll with the Minima theme and is deployed using GitHub Pages.

## Setup and Local Development

### Prerequisites

- Ruby (2.5.0 or higher)
- RubyGems
- GCC and Make

### macOS Setup

1. Install dependencies with Homebrew:

```bash
# Install Ruby if not already installed
brew install ruby

# Add the Homebrew Ruby to your PATH (for fish shell)
fish_add_path /opt/homebrew/opt/ruby/bin

# Verify you're using Homebrew's Ruby
which ruby
# Should show /usr/local/opt/ruby/bin/ruby or /opt/homebrew/opt/ruby/bin/ruby

# Install Jekyll and Bundler using Homebrew's Ruby
gem install jekyll bundler
```

2. Clone the repository:

```bash
git clone https://github.com/alexei-led/alexei-led.github.io.git
cd alexei-led.github.io
```

3. Install dependencies:

```bash
# You might need to use the Homebrew Ruby's bundler directly
/opt/homebrew/opt/ruby/bin/bundle install

# If you've properly set up your PATH in previous steps:
bundle install
```

### Running Locally

Start the local development server:

```bash
bundle exec jekyll serve
```

Your site should now be available at [http://localhost:4000](http://localhost:4000).

To enable live reloading during development:

```bash
bundle exec jekyll serve --livereload
```

## Writing New Posts

1. Create a new Markdown file in the `_posts` directory with the filename format: `YYYY-MM-DD-title.md`
2. Add the YAML front matter at the top of the file:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD HH:MM:SS +0000
categories: category1 category2
---
```

3. Write your post content in Markdown format below the front matter.

## Adding Images

1. Place image files in the `/assets/images/` directory
2. Reference images in your posts using absolute paths from the site root:

```markdown
![Image Alt Text](/assets/images/your-image.png)
```

## Deployment

This blog is automatically deployed to GitHub Pages. To deploy changes:

1. Commit your changes:

```bash
git add .
git commit -m "Your commit message"
```

2. Push to the GitHub repository:

```bash
git push origin master
```

GitHub Actions will automatically build and deploy your site to GitHub Pages.

## Customization

### Site Configuration

Edit `_config.yml` to update site-wide settings.

### Theme Customization

The site uses the Minima theme. To customize:

- Edit files in `_sass/minima/` to modify the CSS
- Update templates in `_layouts/` and `_includes/` to change the site structure

## Troubleshooting

If images aren't displaying:
- Ensure images are in the `/assets/images/` directory
- Use absolute paths in markdown: `/assets/images/image.png`
- Check that the baseurl in `_config.yml` is set correctly
