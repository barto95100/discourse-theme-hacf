import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import Category from "discourse/models/category";
import I18n, { i18n } from "discourse-i18n";

// La catégorie + toutes ses sous-catégories, à tous les niveaux
function withDescendants(cat) {
  const subs = cat.subcategories || [];
  return [cat, ...subs.flatMap(withDescendants)];
}

const fmt = (n) =>
  new Intl.NumberFormat((I18n.locale || "fr").replace("_", "-")).format(n || 0);

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
        const all = withDescendants(cat);
        const topics = all.reduce((sum, c) => sum + (c.topic_count || 0), 0);
        const posts = all.reduce((sum, c) => sum + (c.post_count || 0), 0);
        return {
          url: cat.url,
          name: item.title || cat.name,
          description: item.description || cat.description_text || "",
          icon: item.icon || "layer-group",
          topics: fmt(topics),
          posts: fmt(posts),
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
            <span class="hacf-card__count">{{i18n
                (themePrefix "card_counts")
                topics=card.topics
                posts=card.posts
              }}</span>
          </a>
        {{/each}}
      </section>
    {{/if}}
  </template>
}
