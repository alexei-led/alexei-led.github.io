---
layout: home
title: Recent Posts
---

# Alexei Lednev's Blog

This is a collection of articles I've written over the years about Kubernetes, Docker, cloud infrastructure, and other technical topics. 

You can explore posts by year below.

<ul class="post-list" style="margin-top: 30px;">
  {% assign posts_by_year = site.posts | group_by_exp:"post", "post.date | date: '%Y'" %}
  {% for year in posts_by_year %}
    <li>
      <h2 id="{{ year.name }}">{{ year.name }}</h2>
      <ul>
        {% for post in year.items %}
          <li>
            <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
            <small><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: site.minima.date_format }}</time></small>
            {% if post.tags.size > 0 %}
              <small style="display: block; margin-top: 4px; color: #828282;">
                <em>Tags: {{ post.tags | join: ", " }}</em>
              </small>
            {% endif %}
            {% if post.excerpt %}
              <p style="margin-top: 6px;">{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
            {% endif %}
          </li>
        {% endfor %}
      </ul>
    </li>
  {% endfor %}
</ul>
