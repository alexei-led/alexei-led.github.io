---
layout: home
title: "Posts"
---

## Alexei Ledenev's Blog

This is a collection of articles I've written over the years about different technology topics I find interesting. The articles are organized by year and cover a range of subjects, including cloud computing, AI, DevOps, and software development.

## Posts by Year

{% assign posts_by_year = site.posts | group_by_exp:"post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}

## {{ year.name }}

{% for post in year.items %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%b %-d, %Y" }}{% if post.tags.size > 0 %} - *Tags: {{ post.tags | join: ", " }}*{% endif %}
{% endfor %}

{% endfor %}
