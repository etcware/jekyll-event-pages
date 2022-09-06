---
title: jekyll-event-pages example project
layout: basic
---

<p>These are the events for all blog posts: 3</p>
<ul>
{% for event in site.data['events'] %}
<li><a href="{{ site.url }}/jekyll/event/{{ event | first | slugify }}/index.html">{{ event | first }}</a></li>
{% endfor %}
</ul>
<p>They link to the corresponding index pages!</p>

