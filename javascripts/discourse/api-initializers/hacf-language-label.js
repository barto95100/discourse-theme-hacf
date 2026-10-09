import { apiInitializer } from "discourse/lib/api";

// Sélecteur de langue :
// - bouton : nom complet sur desktop (le CSS gère desktop/mobile)
// - liste : on masque la partie entre parenthèses (nom complet en infobulle)
export default apiInitializer((api) => {
  const updateButton = () => {
    const el = document.querySelector(".language-switcher__locale");
    if (!el) {
      return;
    }
    const lang = (document.documentElement.lang || "fr").replace("_", "-");
    let name = lang;
    try {
      name = new Intl.DisplayNames([lang], {
        type: "language",
        languageDisplay: "standard",
      }).of(lang);
    } catch {
      // Intl indisponible : on garde le code
    }
    name = name.replace(/\s*\(.*\)\s*/g, "").trim();
    name = name.charAt(0).toLocaleUpperCase(lang) + name.slice(1);
    if (el.dataset.full !== name) {
      el.dataset.full = name;
    }
  };

  const tidyMenu = () => {
    document
      .querySelectorAll(
        '.fk-d-menu[data-identifier="language-switcher"] .d-button-label'
      )
      .forEach((label) => {
        const node = label.firstChild;
        if (!node || node.nodeType !== Node.TEXT_NODE) {
          return;
        }
        const full = node.textContent.trim();
        if (!full.includes("(") || label.dataset.hacfFull === full) {
          return;
        }
        label.dataset.hacfFull = full;
        label.closest("button, a")?.setAttribute("title", full);
        node.textContent = full.replace(/\s*\(.*$/, "").trim();
      });
  };

  let headerObserver = null;
  let bodyObserver = null;

  api.onPageChange(() => {
    updateButton();
    if (!headerObserver) {
      const header = document.querySelector(".d-header");
      if (header) {
        headerObserver = new MutationObserver(updateButton);
        headerObserver.observe(header, { childList: true, subtree: true });
      }
    }
    if (!bodyObserver) {
      bodyObserver = new MutationObserver(tidyMenu);
      bodyObserver.observe(document.body, { childList: true, subtree: true });
    }
  });
});
