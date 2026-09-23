(function () {
  const D = window.CAVE_DESIGN;
  const NAV = [
    { href: "index.html", id: "home", label: "Home", icon: "home" },
    { href: "gallery.html", id: "gallery", label: "Gallery", icon: "grid" },
    { href: "findings.html", id: "findings", label: "Findings", icon: "scale" },
    { href: "run.html", id: "run", label: "Run", icon: "play" },
  ];
  const ICONS = {
    home: '<path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>',
    grid: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
    scale: '<path d="M12 3v18"/><path d="M5 7h14"/><path d="M6 7l-4 8h8L6 7z"/><path d="M18 7l-4 8h8l-4-8z"/>',
    play: '<polygon points="6 4 20 12 6 20 6 4"/>',
    gh: '<path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.44 9.8 8.21 11.39.6.11.82-.26.82-.58v-2.23c-3.34.73-4.04-1.42-4.04-1.42-.55-1.39-1.33-1.76-1.33-1.76-1.09-.74.08-.73.08-.73 1.2.09 1.84 1.24 1.84 1.24 1.07 1.83 2.8 1.3 3.49 1 .11-.78.42-1.31.76-1.61-2.67-.3-5.47-1.33-5.47-5.93 0-1.31.47-2.38 1.24-3.22-.13-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 016 0c2.29-1.55 3.3-1.23 3.3-1.23.66 1.66.25 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.62-5.49 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0024 12C24 5.37 18.63 0 12 0z"/>',
  };

  function svg(name, fill) {
    const inner = ICONS[name] || "";
    const fillAttr = fill ? ' fill="currentColor"' : ' fill="none" stroke="currentColor" stroke-width="2"';
    return `<svg width="16" height="16" viewBox="0 0 24 24"${fillAttr} stroke-linecap="round" stroke-linejoin="round">${inner}</svg>`;
  }

  window.CAVE = {
    esc(s) {
      return String(s ?? "").replace(/[&<>"']/g, (c) => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
      }[c]));
    },
    logoKey(id) {
      const s = String(id || "").toLowerCase();
      if (s.startsWith("claude")) return "claude";
      if (s.startsWith("gpt")) return "gpt";
      if (s.startsWith("glm")) return "glm";
      if (s.startsWith("kimi")) return "kimi";
      if (s.startsWith("minimax")) return "minimax";
      if (s.startsWith("qwen")) return "qwen";
      if (s.startsWith("grok")) return "grok";
      if (s.startsWith("hy")) return "hunyuan";
      return "claude";
    },
    logo(id) {
      const k = this.logoKey(id);
      return `<img class="mark" src="assets/logos/${k}.svg" alt="${this.esc(id)}" width="28" height="28">`;
    },
    mountHeader(active) {
      const links = NAV.map((n) => {
        const on = n.id === active ? " active" : "";
        const cur = n.id === active ? ' aria-current="page"' : "";
        return `<a class="header-link${on}" href="${n.href}"${cur}>${svg(n.icon)}<span>${n.label}</span></a>`;
      }).join("");
      const extra = `${D.github ? `<a class="header-link" href="${D.github}" target="_blank" rel="noopener">${svg("gh", true)}<span>GitHub</span></a>` : ""}${D.huggingface ? `<a class="header-link" href="${D.huggingface}" target="_blank" rel="noopener"><span>HF</span></a>` : ""}<a class="header-link" href="#arxiv"><span>arXiv</span></a>`;
      document.body.insertAdjacentHTML("afterbegin", `
        <div class="scroll-progress" id="scrollProgress"></div>
        <header class="header" id="header">
          <a class="logo-link" href="index.html">
            <img class="logo-mark" src="assets/favicon.svg" alt="">
            <span class="logo-text">
              <span class="logo-title">CAVE-Bench</span>
              <span class="logo-sub">False blame, real damage</span>
            </span>
          </a>
          <button class="hamburger" id="hamburger" aria-label="Menu">${svg("grid")}</button>
          <nav class="header-actions" id="headerActions">${links}${extra}</nav>
        </header>`);
      document.getElementById("hamburger").addEventListener("click", () => {
        document.getElementById("headerActions").classList.toggle("open");
      });
    },
    mountFooter() {
      document.body.insertAdjacentHTML("beforeend", `
        <footer class="footer">
          <div class="wrap foot-grid">
            <div>
              <div class="foot-brand">CAVE-Bench</div>
              <p style="margin-top:8px;max-width:440px">365 false-blame tasks for LLM agents that already did the work. Research use. Run inside disposable sandboxes.</p>
            </div>
            <div>
              <div style="color:#fff;font-weight:700;margin-bottom:8px">Browse</div>
              <div style="display:flex;flex-direction:column;gap:6px">
                <a href="gallery.html">Gallery</a>
                <a href="findings.html">Findings</a>
                <a href="run.html">How to run</a>
                <a href="https://github.com/henrymao2004/agent-over-correction">GitHub</a>
                <a href="https://huggingface.co/datasets/sevens2004/cave_bench">Hugging Face</a>
              </div>
            </div>
          </div>
        </footer>`);
    },
    boot(page, opts) {
      opts = opts || {};
      this.mountHeader(page);
      if (opts.footer !== false && page !== "gallery") this.mountFooter();
      const bar = document.getElementById("scrollProgress");
      const header = document.getElementById("header");
      const onScroll = () => {
        const h = document.documentElement;
        const max = h.scrollHeight - h.clientHeight;
        if (bar) bar.style.width = (max > 0 ? (h.scrollTop / max) * 100 : 0) + "%";
        if (header) header.classList.toggle("scrolled", window.scrollY > 40);
      };
      window.addEventListener("scroll", onScroll, { passive: true });
      onScroll();
    },
    index: null,
    async loadIndex() {
      if (this.index) return this.index;
      const r = await fetch("data/index.json");
      this.index = await r.json();
      return this.index;
    },
    casePath(id) {
      const [model, file] = String(id || "").split("/");
      return `cases/${encodeURIComponent(model)}/tasks/${encodeURIComponent(file)}.json`;
    },
    async loadCase(id) {
      const r = await fetch(this.casePath(id));
      if (!r.ok) throw new Error("Case not found");
      return r.json();
    },
  };
})();
