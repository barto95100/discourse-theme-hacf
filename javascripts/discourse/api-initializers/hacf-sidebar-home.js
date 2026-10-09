import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

export default apiInitializer((api) => {
  api.addCommunitySectionLink({
    name: "hacf-home",
    href: "/",
    title: i18n(themePrefix("nav_home")),
    text: i18n(themePrefix("nav_home")),
    icon: "house",
  });
});
