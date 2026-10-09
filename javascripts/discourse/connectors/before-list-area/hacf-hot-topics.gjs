import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";

export default class HacfHotTopics extends Component {
  @service router;

  @tracked topics = [];

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
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
    this.topics = list.slice(0, settings.hot_topics_count).map((t) => {
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

  get visible() {
    return (
      ["discovery.latest", "discovery.categories"].includes(
        this.router.currentRouteName
      ) && this.topics.length > 0
    );
  }

  <template>
    {{#if this.visible}}
      <section class="hacf-hot">
        <h2 class="hacf-hot__title">{{icon settings.hot_topics_icon}} Sujets chauds</h2>
        <ul class="hacf-hot__list">
          {{#each this.topics as |topic|}}
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
  </template>
}
