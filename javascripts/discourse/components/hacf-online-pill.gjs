import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";
import presence from "../lib/hacf-presence";

export default class HacfOnlinePill extends Component {
  constructor() {
    super(...arguments);
    presence.acquire();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    presence.release();
  }

  get data() {
    return presence.data;
  }

  get isList() {
    return this.args.variant === "list";
  }

  get names() {
    return (this.data?.users || []).map((u) => u.name).join(", ");
  }

  <template>
    {{#if this.data.count}}
      <div
        class="hacf-pill {{if this.isList 'hacf-pill--list' 'hacf-pill--header'}}"
        title={{this.names}}
      >
        <span class="hacf-pill__dot"></span>
        {{#if this.isList}}
          <span class="hacf-pill__label">{{i18n
              (themePrefix "home_online")
            }}</span>
        {{/if}}
        <span class="hacf-pill__count">{{this.data.count}}</span>
        {{#if this.isList}}
          <span class="hacf-pill__avatars">
            {{#each this.data.users as |u|}}
              <a class="hacf-pill__avatar" href={{u.url}} title={{u.name}}>
                <img src={{u.avatar}} alt={{u.name}} loading="lazy" />
              </a>
            {{/each}}
          </span>
          {{#if this.data.more}}
            <span class="hacf-pill__more">+{{this.data.more}}</span>
          {{/if}}
        {{/if}}
      </div>
    {{/if}}
  </template>
}
