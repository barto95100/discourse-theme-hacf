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
  @tracked articles = [];
  @tracked contributors = [];
  @tracked team = [];

  constructor() {
    super(...arguments);
    this.loadOnline();
    this.pillars = this.buildPillars();
    this.loadStats();
    this.loadEvents();
    this.loadArticles();
    this.loadContributors();
    this.loadTeam();
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

  get membersLabel() {
    return this.stats?.[0]?.value;
  }

  get teamGroups() {
    const groups = new Map();
    for (const m of this.team) {
      const key = m.title || "";
      if (!groups.has(key)) {
        groups.set(key, []);
      }
      groups.get(key).push(m);
    }
    return [...groups.entries()].map(([title, members]) => ({
      title,
      members,
      cols: members.length > 4 ? 2 : 1,
    }));
  }

  async loadTeam() {
    try {
      const data = await ajax("/g/Equipe/members.json?limit=50");
      const rank = (t) => {
        const k = String(t || "").toLowerCase();
        if (k.startsWith("fondateur")) { return 0; }
        if (k.startsWith("mod")) { return 1; }
        if (k.startsWith("adh")) { return 9; }
        return k ? 2 : 8;
      };
      this.team = (data?.members || [])
        .filter(
          (m) => m.username && m.username !== "Equipe_HACF"
        )
        .sort(
          (a, b) =>
            rank(a.title) - rank(b.title) ||
            a.username.localeCompare(b.username)
        )
        .slice(0, 30)
        .map((m) => ({
          name: m.name || m.username,
          url: `/u/${m.username}`,
          title: m.title || "",
          avatar: m.avatar_template.replace("{size}", "96"),
        }));
    } catch {
      // pas d'équipe : le panneau reste caché
    }
  }

  async loadContributors() {
    try {
      const data = await ajax(
        "/directory_items.json?period=weekly&order=likes_received&exclude_usernames=system,discobot"
      );
      this.contributors = (data?.directory_items || [])
        .filter((i) => i.user?.avatar_template)
        .slice(0, 8)
        .map((i) => ({
          name: i.user.username,
          url: `/u/${i.user.username}`,
          avatar: i.user.avatar_template.replace("{size}", "96"),
        }));
    } catch {
      // pas de contributeurs : la bande reste cachée
    }
  }

  async loadArticleImages() {
    const list = await Promise.all(
      this.articles.map(async (a) => {
        if (a.image) {
          return a;
        }
        const key = `hacf-thumb-${a.id}`;
        try {
          const cached = sessionStorage.getItem(key);
          if (cached !== null) {
            return { ...a, image: cached || null };
          }
        } catch {
          // stockage indisponible : on interroge le serveur
        }
        try {
          const d = await ajax(`/t/${a.id}.json`);
          const html = d?.post_stream?.posts?.[0]?.cooked || "";
          const doc = new DOMParser().parseFromString(html, "text/html");
          const img = doc.querySelector("img.thumbnail");
          const src = img?.getAttribute("src") || null;
          try {
            sessionStorage.setItem(key, src || "");
          } catch {
            // ignoré
          }
          return { ...a, image: src };
        } catch {
          return a;
        }
      })
    );
    this.articles = list;
  }

  async loadArticles() {
    try {
      const data = await ajax("/tag/hacf-blog.json");
      const lang = document.documentElement.lang || "fr";
      const fmtDate = new Intl.DateTimeFormat(lang, {
        day: "numeric",
        month: "long",
        year: "numeric",
      });
      this.articles = (data?.topic_list?.topics || [])
        .filter((t) => t.created_at)
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, 3)
        .map((t) => {
          const m = String(t.title).match(/^\s*\[([^\]]+)\]\s*(.*)$/);
          return {
            id: t.id,
            url: `/t/${t.slug}/${t.id}`,
            title: m ? m[2] : t.title,
            badge: m ? m[1] : "",
            image: t.image_url,
            date: fmtDate.format(new Date(t.created_at)),
          };
        });
      this.loadArticleImages();
    } catch {
      // pas d'articles : la section reste cachée
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

  @tracked online = null;
  _onlineTimer = null;

  async loadOnline() {
    const url = settings.presence_url;
    if (!url) {
      return;
    }
    const refresh = async () => {
      if (document.hidden) {
        return;
      }
      try {
        const r = await fetch(url);
        if (!r.ok) {
          return;
        }
        const d = await r.json();
        const max = settings.presence_max_avatars || 20;
        const users = (d.users || []).slice(0, max).map((u) => ({
          name: u.username,
          url: `/u/${u.username}`,
          avatar: u.avatar_template.replace("{size}", "48"),
        }));
        const count = d.count || 0;
        this.online = { count, users, more: Math.max(0, count - users.length) };
      } catch {
        // silencieux : la ligne reste simplement masquée
      }
    };
    this._onlineTimer = setInterval(refresh, 60000);
    await refresh();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this._onlineTimer);
  }

  get year() {
    return new Date().getFullYear();
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
        {{#if this.contributors.length}}
          <div class="hacf-home__members">
            <span class="hacf-home__avatars">
              {{#each this.contributors as |c|}}
                <a class="hacf-home__avatar" href={{c.url}} title={{c.name}}>
                  <img src={{c.avatar}} alt={{c.name}} loading="lazy" />
                </a>
              {{/each}}
            </span>
            {{#unless this.currentUser}}{{#if this.membersLabel}}
              <span class="hacf-home__join">{{i18n
                  (themePrefix "home_join")
                  members=this.membersLabel
                }}</span>
            {{/if}}{{/unless}}
          </div>
        {{/if}}
              {{#if this.online.count}}
          <div class="hacf-online">
            <span class="hacf-online__dot"></span>
            <span class="hacf-online__label">{{i18n (themePrefix "home_online")}}</span>
            <span class="hacf-online__count">{{this.online.count}}</span>
            <span class="hacf-online__avatars">
              {{#each this.online.users as |u|}}
                <a class="hacf-online__avatar" href={{u.url}} title={{u.name}}>
                  <img src={{u.avatar}} alt={{u.name}} loading="lazy" />
                </a>
              {{/each}}
            </span>
            {{#if this.online.more}}
              <span class="hacf-online__more">+{{this.online.more}}</span>
            {{/if}}
          </div>
        {{/if}}
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
        <section class="hacf-upcoming">
          <h2 class="hacf-upcoming__title">{{i18n (themePrefix "home_events_title")}}</h2>
          <div class="hacf-upcoming__list">
            {{#each this.events as |ev|}}
              <a class="hacf-upcoming-item" href={{ev.url}}>
                <span class="hacf-upcoming-item__icon">{{icon "calendar-days"}}</span>
                <span class="hacf-upcoming-item__body">
                  <span class="hacf-upcoming-item__date">{{ev.date}}</span>
                  <span class="hacf-upcoming-item__name">{{ev.title}}</span>
                </span>
              </a>
            {{/each}}
          </div>
          <a class="hacf-upcoming__all" href="/upcoming-events">{{i18n (themePrefix "home_events_all")}}</a>
        </section>
      {{/if}}

      {{#if this.team.length}}
        <section class="hacf-team">
          <h2 class="hacf-team__title">{{i18n (themePrefix "home_team_title")}}</h2>
          <div class="hacf-team__groups">
            {{#each this.teamGroups as |g|}}
              <div class="hacf-team-group" data-cols={{g.cols}}>
                <h3 class="hacf-team-group__title">
                  {{if g.title g.title (i18n (themePrefix "home_team_other"))}}
                  <span class="hacf-team-group__count">{{g.members.length}}</span>
                </h3>
                <div class="hacf-team-group__members">
                {{#each g.members as |m|}}
                  <a class="hacf-team-member" href={{m.url}}>
                    <img class="hacf-team-member__avatar" src={{m.avatar}} alt="" loading="lazy" />
                    <span class="hacf-team-member__name">{{m.name}}</span>
                  </a>
                {{/each}}
                </div>
              </div>
            {{/each}}
          </div>
          <a class="hacf-team__all" href="/g/Equipe">{{i18n (themePrefix "home_team_all")}}</a>
        </section>
      {{/if}}

      {{#if this.articles.length}}
        <section class="hacf-news">
          <h2 class="hacf-news__title">{{i18n (themePrefix "home_articles_title")}}</h2>
          <div class="hacf-news__list">
            {{#each this.articles as |art|}}
              <a class="hacf-news-card" href={{art.url}}>
                {{#if art.image}}
                  <img class="hacf-news-card__img" src={{art.image}} alt="" loading="lazy" />
                {{else}}
                  <span class="hacf-news-card__img hacf-news-card__img--empty"></span>
                {{/if}}
                <span class="hacf-news-card__body">
                  {{#if art.badge}}
                    <span class="hacf-news-card__badge">{{art.badge}}</span>
                  {{/if}}
                  <span class="hacf-news-card__name">{{art.title}}</span>
                  <span class="hacf-news-card__date">{{art.date}}</span>
                </span>
              </a>
            {{/each}}
          </div>
          <a class="hacf-news__all" href="/tag/hacf-blog">{{i18n (themePrefix "home_articles_all")}}</a>
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

      <footer class="hacf-footer">
      <div class="hacf-footer__inner">
        <div class="hacf-footer__brand">
          <strong>Home Assistant Communauté Francophone</strong>
          <p>{{i18n (themePrefix "footer_tagline")}}</p>
        </div>

        <nav class="hacf-footer__col">
          <h4>{{i18n (themePrefix "footer_col_hacf")}}</h4>
          <a href="https://www.hacf.fr" target="_blank" rel="noopener">{{i18n (themePrefix "footer_site")}}</a>
          <a href="https://www.hacf.fr/association-hacf/" target="_blank" rel="noopener">{{i18n (themePrefix "footer_association")}}</a>
          <a href="https://adherer.hacf.fr" target="_blank" rel="noopener">{{i18n (themePrefix "footer_join")}}</a>
        </nav>

        <nav class="hacf-footer__col">
          <h4>{{i18n (themePrefix "footer_col_community")}}</h4>
          <a href="https://discord.hacf.fr" target="_blank" rel="noopener">{{i18n (themePrefix "footer_discord")}}</a>
          <a href="https://facebook.hacf.fr" target="_blank" rel="noopener">{{i18n (themePrefix "footer_facebook")}}</a>
        </nav>

        <nav class="hacf-footer__col">
          <h4>{{i18n (themePrefix "footer_col_forum")}}</h4>
          <a href="/guidelines">{{i18n (themePrefix "footer_about")}}</a>
          <a href="/tos">{{i18n (themePrefix "footer_tos")}}</a>
          <a href="/privacy">{{i18n (themePrefix "footer_privacy")}}</a>
        </nav>
      </div>

      <div class="hacf-footer__bottom">
        {{i18n (themePrefix "footer_rights") year=this.year}}
      </div>
    </footer>
    </div>
  </template>
}
