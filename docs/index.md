---
layout: home
title: Terra Nullius
---

Welcome to Terra Nullius, Alexei Lednev's personal blog. Here you'll find a collection of articles on Docker, Kubernetes, and other cloud-native technologies.

## Latest Posts

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%B %d, %Y" }}
{% endfor %}