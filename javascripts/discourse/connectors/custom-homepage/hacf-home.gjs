import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class HacfHome extends Component {
  @service currentUser;

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
    </div>
  </template>
}
