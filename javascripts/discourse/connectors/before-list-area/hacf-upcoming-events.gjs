import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";

const fmtDay = new Intl.DateTimeFormat("fr-FR", { day: "numeric" });
const fmtMonth = new Intl.DateTimeFormat("fr-FR", { month: "short" });
const fmtWhen = new Intl.DateTimeFormat("fr-FR", {
  weekday: "long",
  hour: "2-digit",
  minute: "2-digit",
});
const fmtWhenAllDay = new Intl.DateTimeFormat("fr-FR", { weekday: "long" });

export default class HacfUpcomingEvents extends Component {
  @service router;

  @tracked events = [];

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
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

  get visible() {
    return (
      ["discovery.latest", "discovery.categories"].includes(
        this.router.currentRouteName
      ) && this.events.length > 0
    );
  }

  <template>
    {{#if this.visible}}
      <section class="hacf-events">
        <h2 class="hacf-events__title">{{icon settings.upcoming_events_icon}}
          Prochains événements</h2>
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
  </template>
}
