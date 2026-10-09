import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

export default class HacfFooter extends Component {
  get year() {
    return new Date().getFullYear();
  }

  <template>
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
          <a href="/about">{{i18n (themePrefix "footer_about")}}</a>
          <a href="/tos">{{i18n (themePrefix "footer_tos")}}</a>
          <a href="/privacy">{{i18n (themePrefix "footer_privacy")}}</a>
        </nav>
      </div>

      <div class="hacf-footer__bottom">
        {{i18n (themePrefix "footer_rights") year=this.year}}
      </div>
    </footer>
  </template>
}
