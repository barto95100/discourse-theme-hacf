import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";
import I18n, { i18n } from "discourse-i18n";

// La langue de l'utilisateur pilote aussi les dates et les nombres
const locale = () => (I18n.locale || "fr").replace("_", "-");

export default class HacfAside extends Component {
  @service router;

  @tracked hot = [];
  @tracked events = [];
  @tracked contributors = [];

  constructor() {
    super(...arguments);
    this.loadHot();
    this.loadEvents();
    this.loadContributors();
  }

  async loadHot() {
    if (!settings.show_hot_topics) {
      return;
    }
    let data;
    try {
      data = await ajax("/hot.json");
    } catch {
      try {
        data = await ajax("/top.json?period=weekly");
      } catch {
        return;
      }
    }
    const list = (data?.topic_list?.topics || []).filter(
      (t) => !t.pinned && t.archetype !== "private_message"
    );
    this.hot = list.slice(0, settings.hot_topics_count).map((t) => {
      const cat = Category.findById(t.category_id);
      return {
        url: `/t/${t.slug}/${t.id}`,
        title: htmlSafe(t.fancy_title || t.title),
        category: cat?.name,
        style: htmlSafe(`--hacf-dot: #${cat?.color || "888888"};`),
        replies: t.reply_count ?? Math.max((t.posts_count || 1) - 1, 0),
      };
    });
  }

  async loadEvents() {
    if (!settings.show_upcoming_events) {
      return;
    }
    let data;
    try {
      data = await ajax("/discourse-post-event/events.json");
    } catch {
      return;
    }
    const now = Date.now();
    const items = [];
    for (const ev of data?.events || []) {
      const occurrences = ev.occurrences?.length
        ? ev.occurrences
        : [{ starts_at: ev.starts_at, ends_at: ev.ends_at, all_day: false }];
      for (const o of occurrences) {
        const start = new Date(o.starts_at);
        const end = o.ends_at ? new Date(o.ends_at) : start;
        if (end.getTime() < now) {
          continue;
        }
        items.push({ ev, start, allDay: o.all_day });
      }
    }
    items.sort((a, b) => a.start - b.start);

    const l = locale();
    const fmtDay = new Intl.DateTimeFormat(l, { day: "numeric" });
    const fmtMonth = new Intl.DateTimeFormat(l, { month: "short" });
    const fmtWhen = new Intl.DateTimeFormat(l, {
      weekday: "long",
      hour: "2-digit",
      minute: "2-digit",
    });
    const fmtWhenAllDay = new Intl.DateTimeFormat(l, { weekday: "long" });

    this.events = items
      .slice(0, settings.upcoming_events_count)
      .map(({ ev, start, allDay }) => ({
        url: ev.post?.url,
        title: ev.name || ev.post?.topic?.title,
        day: fmtDay.format(start),
        month: fmtMonth.format(start).replace(".", ""),
        when: (allDay ? fmtWhenAllDay : fmtWhen).format(start),
      }));
  }

  async loadContributors() {
    if (!settings.show_top_contributors) {
      return;
    }
    const exclude = (settings.top_contributors_exclude || "")
      .split(",")
      .map((x) => x.trim().toLowerCase())
      .filter(Boolean);
    const count = settings.top_contributors_count;
    const id = settings.top_contributors_leaderboard_id;
    let data;
    try {
      data = await ajax(`/leaderboard/${id}.json`, {
        data: { period: "weekly", user_limit: count + exclude.length + 5 },
      });
    } catch {
      return;
    }
    const fmtNumber = new Intl.NumberFormat(locale());
    this.contributors = (data?.users || [])
      .filter(
        (u) =>
          (u.total_score || 0) > 0 &&
          !exclude.includes(u.username.toLowerCase())
      )
      .slice(0, count)
      .map((u) => ({
        url: `/u/${u.username}`,
        name: u.username,
        avatar: u.avatar_template?.replace("{size}", "64"),
        score: fmtNumber.format(u.total_score),
      }));
  }

  get onHome() {
    return [
      "discovery.latest",
      "discovery.categories",
      "discovery.new",
      "discovery.top",
      "discovery.unread",
      "discovery.hot",
    ].includes(
      this.router.currentRouteName
    );
  }

  get showHot() {
    return this.onHome && this.hot.length > 0;
  }

  get showEvents() {
    return this.onHome && this.events.length > 0;
  }

  get showContributors() {
    return this.onHome && this.contributors.length > 0;
  }

  get visible() {
    return this.showHot || this.showEvents || this.showContributors;
  }

  <template>
    {{#if this.visible}}
      <aside class="hacf-aside">
        {{#if this.showHot}}
          <section class="hacf-hot">
            <h2 class="hacf-hot__title">{{icon settings.hot_topics_icon}}
              {{i18n (themePrefix "hot_title")}}</h2>
            <ul class="hacf-hot__list">
              {{#each this.hot as |topic|}}
                <li class="hacf-hot__item" style={{topic.style}}>
                  <a class="hacf-hot__link" href={{topic.url}}>{{topic.title}}</a>
                  <span class="hacf-hot__meta">
                    {{#if topic.category}}
                      <span class="hacf-hot__cat">{{topic.category}}</span>
                    {{/if}}
                    <span class="hacf-hot__replies">{{icon "comment"}}
                      {{topic.replies}}</span>
                  </span>
                </li>
              {{/each}}
            </ul>
          </section>
        {{/if}}

        {{#if this.showEvents}}
          <section class="hacf-events">
            <h2 class="hacf-events__title">{{icon
                settings.upcoming_events_icon
              }}
              {{i18n (themePrefix "events_title")}}</h2>
            <ul class="hacf-events__list">
              {{#each this.events as |event|}}
                <li class="hacf-events__item">
                  <a class="hacf-events__link" href={{event.url}}>
                    <span class="hacf-events__date">
                      <span class="hacf-events__day">{{event.day}}</span>
                      <span class="hacf-events__month">{{event.month}}</span>
                    </span>
                    <span class="hacf-events__text">
                      <span class="hacf-events__name">{{event.title}}</span>
                      <span class="hacf-events__when">{{event.when}}</span>
                    </span>
                  </a>
                </li>
              {{/each}}
            </ul>
          </section>
        {{/if}}

        {{#if this.showContributors}}
          <section class="hacf-top">
            <h2 class="hacf-top__title">{{icon settings.top_contributors_icon}}
              {{i18n (themePrefix "top_title")}}</h2>
            <ul class="hacf-top__list">
              {{#each this.contributors as |c|}}
                <li class="hacf-top__item">
                  <a class="hacf-top__link" href={{c.url}}>
                    <img
                      class="hacf-top__avatar"
                      src={{c.avatar}}
                      width="32"
                      height="32"
                      alt=""
                      loading="lazy"
                    />
                    <span class="hacf-top__name">{{c.name}}</span>
                    <span class="hacf-top__score">{{icon "star"}}
                      {{c.score}}</span>
                  </a>
                </li>
              {{/each}}
            </ul>
            <p class="hacf-top__note">{{i18n (themePrefix "top_note")}}</p>
          </section>
        {{/if}}
      </aside>
    {{/if}}
  </template>
}
