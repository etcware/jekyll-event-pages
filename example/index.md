---
title: jekyll-event-pages example project
layout: basic
---

<p>These are the events for all blog posts:</p>
<ul>
{% for event in site.categories %}
<li><a href="{{ site.url }}/jekyll/event/{{ event | first | url_encode }}/index.html">{{ event | first }}</a></li>
{% endfor %}
</ul>
<p>They link to the corresponding index pages!</p>

