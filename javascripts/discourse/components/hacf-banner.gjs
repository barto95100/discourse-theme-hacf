import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

const ICONS = {
  info: "circle-info",
  success: "circle-check",
  warning: "triangle-exclamation",
};

function hash(str) {
  let h = 5381;
  for (let i = 0; i < str.length; i++) {
    h = ((h << 5) + h + str.charCodeAt(i)) | 0;
  }
  return String(h);
}

export default class HacfBanner extends Component {
  @service router;
  @tracked closed = false;

  get message() {
    return (settings.banner_message || "").trim();
  }

  get key() {
    return `hacf-banner:${hash(this.message + settings.banner_link_url)}`;
  }

  get expired() {
    const d = (settings.banner_expires || "").trim();
    if (!d) {
      return false;
    }
    const end = new Date(`${d}T23:59:59`);
    return !isNaN(end) && Date.now() > end.getTime();
  }

  get dismissed() {
    if (this.closed) {
      return true;
    }
    try {
      return localStorage.getItem(this.key) === "1";
    } catch {
      return false;
    }
  }

  get onDiscovery() {
    return (this.router.currentRouteName || "").startsWith("discovery.");
  }

  get show() {
    return (
      settings.banner_enabled &&
      this.message &&
      !this.expired &&
      !this.dismissed &&
      this.onDiscovery
    );
  }

  get type() {
    return ICONS[settings.banner_type] ? settings.banner_type : "info";
  }

  get iconName() {
    return ICONS[this.type];
  }

  get hasLink() {
    return !!(settings.banner_link_url || "").trim();
  }

  @action
  close() {
    this.closed = true;
    try {
      localStorage.setItem(this.key, "1");
    } catch {
      // stockage indisponible : fermé pour cette page seulement
    }
  }

  <template>
    {{#if this.show}}
      <div class="hacf-banner hacf-banner--{{this.type}}" role="status">
        <span class="hacf-banner__icon">{{icon this.iconName}}</span>
        <span class="hacf-banner__body">
          {{#if settings.banner_badge}}
            <span class="hacf-banner__badge">{{settings.banner_badge}}</span>
          {{/if}}
          <span class="hacf-banner__text">{{this.message}}</span>
        </span>
        {{#if this.hasLink}}
          <a class="hacf-banner__link" href={{settings.banner_link_url}}>
            {{settings.banner_link_label}}
          </a>
        {{/if}}
        {{#if settings.banner_dismissible}}
          <button
            type="button"
            class="hacf-banner__close"
            aria-label={{i18n (themePrefix "banner_close")}}
            title={{i18n (themePrefix "banner_close")}}
            {{on "click" this.close}}
          >{{icon "xmark"}}</button>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
