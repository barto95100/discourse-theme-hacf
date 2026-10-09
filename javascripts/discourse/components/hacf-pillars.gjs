import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

function withDescendants(cat) {
  return [cat, ...(cat.subcategories || []).flatMap(withDescendants)];
}

export default class HacfPillars extends Component {
  get pillars() {
    return (settings.featured_categories || [])
      .map((item) => {
        const id = item.category?.[0];
        const cat = id ? Category.findById(id) : null;
        if (!cat) {
          return null;
        }
        const all = withDescendants(cat);
        return {
          url: cat.url,
          name: item.title || cat.name,
          description: item.description || cat.description_text || "",
          icon: item.icon || "layer-group",
          topics: all.reduce((n, c) => n + (c.topic_count || 0), 0),
          posts: all.reduce((n, c) => n + (c.post_count || 0), 0),
          style: htmlSafe(`--hacf-card-color: #${cat.color}`),
        };
      })
      .filter(Boolean);
  }

  <template>
    {{#if this.pillars.length}}
      <section class="hacf-pillars">
        {{#each this.pillars as |p|}}
          <a class="hacf-pillar" href={{p.url}} style={{p.style}}>
            <span class="hacf-pillar__icon">{{icon p.icon}}</span>
            <h3 class="hacf-pillar__title">{{p.name}}</h3>
            <p class="hacf-pillar__desc">{{p.description}}</p>
            <span class="hacf-pillar__count">{{i18n
                (themePrefix "card_counts")
                topics=p.topics
                posts=p.posts
              }}</span>
          </a>
        {{/each}}
      </section>
    {{/if}}
  </template>
}
