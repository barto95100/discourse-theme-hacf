import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

export default class HacfHome extends Component {
  @service currentUser;

  @tracked stats = null;
  @tracked events = [];

  constructor() {
    super(...arguments);
    this.pillars = this.buildPillars();
    this.loadStats();
    this.loadEvents();
  }

  pillars = [];

  buildPillars() {
    const fmt = new Intl.NumberFormat(document.documentElement.lang || "fr");
    try {
      return (settings.featured_categories || [])
        .map((item) => {
          const id = item.category?.[0];
          const cat = id ? Category.findById(id) : null;
          return cat
            ? {
                name: cat.name,
                url: cat.url,
                icon: item.icon || "folder",
                description: String(item.description ?? ""),
                counts: i18n(themePrefix("card_counts"), {
                  topics: fmt.format(cat.topic_count ?? 0),
                  posts: fmt.format(cat.post_count ?? 0),
                }),
              }
            : null;
        })
        .filter(Boolean);
    } catch {
      return [];
    }
  }

  async loadEvents() {
    try {
      const data = await ajax("/discourse-post-event/events.json");
      const lang = document.documentElement.lang || "fr";
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      this.events = (data?.events || [])
        .filter((e) => e.starts_at && new Date(e.ends_at || e.starts_at) >= today)
        .sort((a, b) => new Date(a.starts_at) - new Date(b.starts_at))
        .slice(0, 3)
        .map((e) => {
          const dateOnly = String(e.starts_at).length === 10;
          const opts = { weekday: "short", day: "numeric", month: "short" };
          if (dateOnly) {
            opts.timeZone = "UTC";
          } else {
            opts.hour = "2-digit";
            opts.minute = "2-digit";
          }
          return {
            url: e.post?.url || "/upcoming-events",
            title: e.name || e.post?.topic?.title || "",
            date: new Intl.DateTimeFormat(lang, opts).format(new Date(e.starts_at)),
          };
        });
    } catch {
      // pas d'événements : la section reste cachée
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
            <span class="hacf-pillar__icon">{{icon pillar.icon}}</span>
            <h3 class="hacf-pillar__title">{{pillar.name}}</h3>
            <p class="hacf-pillar__desc">{{pillar.description}}</p>
            <span class="hacf-pillar__count">{{pillar.counts}}</span>
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

      {{#if this.events.length}}
        <section class="hacf-events">
          <h2 class="hacf-events__title">{{i18n (themePrefix "home_events_title")}}</h2>
          <div class="hacf-events__list">
            {{#each this.events as |ev|}}
              <a class="hacf-event" href={{ev.url}}>
                <span class="hacf-event__icon">{{icon "calendar-days"}}</span>
                <span class="hacf-event__body">
                  <span class="hacf-event__date">{{ev.date}}</span>
                  <span class="hacf-event__name">{{ev.title}}</span>
                </span>
              </a>
            {{/each}}
          </div>
          <a class="hacf-events__all" href="/upcoming-events">{{i18n (themePrefix "home_events_all")}}</a>
        </section>
      {{/if}}

      <section class="hacf-steps">
        <h2 class="hacf-steps__title">{{i18n (themePrefix "home_steps_title")}}</h2>
        <div class="hacf-steps__list">
          <div class="hacf-step">
            <span class="hacf-step__num">1</span>
            <h3 class="hacf-step__title">{{i18n (themePrefix "home_step1_title")}}</h3>
            <span class="hacf-step__desc">{{i18n (themePrefix "home_step1_desc")}}</span>
          </div>
          <div class="hacf-step">
            <span class="hacf-step__num">2</span>
            <h3 class="hacf-step__title">{{i18n (themePrefix "home_step2_title")}}</h3>
            <span class="hacf-step__desc">{{i18n (themePrefix "home_step2_desc")}}</span>
          </div>
          <div class="hacf-step">
            <span class="hacf-step__num">3</span>
            <h3 class="hacf-step__title">{{i18n (themePrefix "home_step3_title")}}</h3>
            <span class="hacf-step__desc">{{i18n (themePrefix "home_step3_desc")}}</span>
          </div>
        </div>
      </section>
    </div>
  </template>
}
