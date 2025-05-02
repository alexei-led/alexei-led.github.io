---
layout: home
title: "Alexei Lednev's Blog"
---

This is a collection of articles I've written over the years about Kubernetes, Docker, cloud infrastructure, and other technical topics.

## Posts by Year

{% assign posts_by_year = site.posts | group_by_exp:"post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}
## {{ year.name }}

{% for post in year.items %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%b %-d, %Y" }}{% if post.tags.size > 0 %} - *Tags: {{ post.tags | join: ", " }}*{% endif %}
{% endfor %}

{% endfor %}
