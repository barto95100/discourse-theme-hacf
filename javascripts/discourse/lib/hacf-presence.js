import { tracked } from "@glimmer/tracking";

class HacfPresence {
  @tracked data = null;
  _timer = null;
  _users = 0;

  acquire() {
    this._users++;
    if (this._users === 1) {
      this.refresh();
      this._timer = setInterval(() => this.refresh(), 60000);
    }
  }

  release() {
    this._users = Math.max(0, this._users - 1);
    if (this._users === 0) {
      clearInterval(this._timer);
      this._timer = null;
    }
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
