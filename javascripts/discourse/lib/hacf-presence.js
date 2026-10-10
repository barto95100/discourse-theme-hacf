import { tracked } from "@glimmer/tracking";

class HacfPresence {
  @tracked data = null;
  _timer = null;
  _users = 0;

  acquire() {
    this._users++;
    if (this._users === 1) {
      this.refresh();
      this._schedule();
    }
  }

  release() {
    this._users = Math.max(0, this._users - 1);
    if (this._users === 0) {
      clearTimeout(this._timer);
      this._timer = null;
    }
  }

  // Rafraîchit à intervalle réglable, avec un décalage aléatoire par navigateur
  // pour éviter que tous les visiteurs appellent le serveur au même instant.
  _schedule() {
    const base = (settings.presence_refresh_seconds || 120) * 1000;
    const jitter = Math.random() * 30000;
    this._timer = setTimeout(async () => {
      await this.refresh();
      if (this._users > 0) {
        this._schedule();
      }
    }, base + jitter);
  }

  async refresh() {
    const url = settings.presence_url;
    if (!url || document.hidden) {
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
      this.data = { count, users, more: Math.max(0, count - users.length) };
    } catch {
      // silencieux : la pastille reste masquée
    }
  }
}

export default new HacfPresence();
