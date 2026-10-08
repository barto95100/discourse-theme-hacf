import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import Category from "discourse/models/category";

export default class HacfFeaturedCategories extends Component {
  @service router;

  get visible() {
    return (
      ["discovery.latest", "discovery.categories"].includes(
        this.router.currentRouteName
      ) && this.cards.length > 0
    );
  }

  get cards() {
    return (settings.featured_categories || [])
      .map((item) => {
        const id = item.category?.[0];
        const cat = id ? Category.findById(id) : null;
        if (!cat) {
          return null;
        }
        return {
          url: cat.url,
          name: item.title || cat.name,
          description: item.description || cat.description_text || "",
          icon: item.icon || "layer-group",
          count: cat.topic_count,
          style: htmlSafe(`--hacf-card-color: #${cat.color};`),
        };
      })
      .filter(Boolean);
  }

  <template>
    {{#if this.visible}}
      <section class="hacf-cards">
        {{#each this.cards as |card|}}
          <a class="hacf-card" href={{card.url}} style={{card.style}}>
            <span class="hacf-card__icon">{{icon card.icon}}</span>
            <span class="hacf-card__title">{{card.name}}</span>
            <span class="hacf-card__desc">{{card.description}}</span>
            <span class="hacf-card__count">{{card.count}} sujets</span>
          </a>
        {{/each}}
      </section>
    {{/if}}
  </template>
}
