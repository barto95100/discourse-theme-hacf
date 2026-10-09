(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import Component from "@glimmer/component";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import { service } from "@ember/service";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import { htmlSafe } from "@ember/template";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import icon from "discourse/helpers/d-icon";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import I18n, { i18n } from "discourse-i18n";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))import Category from "discourse/models/category";
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))// La catégorie + toutes ses sous-catégories, à tous les niveaux
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))function withDescendants(cat) {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  const subs = cat.subcategories || [];
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  return [cat, ...subs.flatMap(withDescendants)];
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))}
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))const fmt = (n) => (n || 0).toLocaleString("fr-FR");
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))export default class HacfFeaturedCategories extends Component {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  @service router;
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  get visible() {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))    return (
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      ["discovery.latest", "discovery.categories"].includes(
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        this.router.currentRouteName
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      ) && this.cards.length > 0
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))    );
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  }
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  get cards() {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))    return (settings.featured_categories || [])
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      .map((item) => {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        const id = item.category?.[0];
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        const cat = id ? Category.findById(id) : null;
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        if (!cat) {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          return null;
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        }
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        const all = withDescendants(cat);
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        const topics = all.reduce((sum, c) => sum + (c.topic_count || 0), 0);
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        const posts = all.reduce((sum, c) => sum + (c.post_count || 0), 0);
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        return {
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          url: cat.url,
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          name: item.title || cat.name,
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          description: item.description || cat.description_text || "",
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          icon: item.icon || "layer-group",
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          topics: fmt(topics),
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          posts: fmt(posts),
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          style: htmlSafe(`--hacf-card-color: #${cat.color};`),
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        };
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      })
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      .filter(Boolean);
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  }
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  <template>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))    {{#if this.visible}}
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      <section class="hacf-cards">
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        {{#each this.cards as |card|}}
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          <a class="hacf-card" href={{card.url}} style={{card.style}}>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))            <span class="hacf-card__icon">{{icon card.icon}}</span>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))            <span class="hacf-card__title">{{card.name}}</span>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))            <span class="hacf-card__desc">{{card.description}}</span>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))            <span class="hacf-card__count">{{i18n (themePrefix "card_counts") topics=card.topics posts=card.posts}}</span>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))          </a>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))        {{/each}}
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))      </section>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))    {{/if}}
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))  </template>
(n || 0).toLocaleString(I18n.locale.replace("_", "-"))}
