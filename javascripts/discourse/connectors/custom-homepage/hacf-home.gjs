import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

export default class HacfHome extends Component {
  @service currentUser;

  @tracked stats = null;

  constructor() {
    super(...arguments);
    this.pillars = this.buildPillars();
    this.loadStats();
  }

  pillars = [];

  buildPillars() {
    try {
      return (settings.featured_categories || [])
        .map((item) => {
          const id = item.category?.[0];
          const cat = id ? Category.findById(id) : null;
          return cat
            ? {
                name: cat.name,
                url: cat.url,
                description: String(item.description ?? ""),
              }
            : null;
        })
        .filter(Boolean);
    } catch {
      return [];
    }
  }

  async loadStats() {
    try {
      const data = await ajax("/about.json");
      const s = data?.about?.stats;
      if (!s) {
        return;
      }
      const fmt = new Intl.NumberFormat(document.documentElement.lang || "fr");
      this.stats = [
        { key: "home_stat_members", value: fmt.format(s.users_count ?? s.user_count ?? 0) },
        { key: "home_stat_topics", value: fmt.format(s.topics_count ?? s.topic_count ?? 0) },
        { key: "home_stat_posts", value: fmt.format(s.posts_count ?? s.post_count ?? 0) },
      ];
    } catch {
      // pas de statistiques : on n'affiche rien
    }
  }

  <template>
    <div class="hacf-home">
      <section class="hacf-home__hero">
        <h1 class="hacf-home__title">{{i18n (themePrefix "home_title")}}</h1>
        <p class="hacf-home__subtitle">{{i18n
            (themePrefix "home_subtitle")
          }}</p>
        <div class="hacf-home__cta">
          {{#unless this.currentUser}}
            <a class="btn btn-primary" href="/signup">{{i18n
                (themePrefix "home_cta_signup")
              }}</a>
          {{/unless}}
          <a class="btn btn-default" href="/latest">{{i18n
              (themePrefix "home_cta_browse")
            }}</a>
        </div>
      </section>

      <section class="hacf-pillars">
        {{#each this.pillars as |pillar|}}
          <a class="hacf-pillar" href={{pillar.url}}>
            <h3 class="hacf-pillar__title">{{pillar.name}}</h3>
            <p class="hacf-pillar__desc">{{pillar.description}}</p>
          </a>
        {{/each}}
      </section>

      {{#if this.stats}}
        <section class="hacf-home__stats">
          {{#each this.stats as |stat|}}
            <div class="hacf-home__stat">
              <span class="hacf-home__stat-value">{{stat.value}}</span>
              <span class="hacf-home__stat-label">{{i18n
                  (themePrefix stat.key)
                }}</span>
            </div>
          {{/each}}
        </section>
      {{/if}}
    </div>
  </template>
}
