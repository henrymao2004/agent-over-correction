(function () {
  const C = window.CAVE;
  const D = window.CAVE_DESIGN;
  C.boot("findings");

  const metrics = document.getElementById("metrics");
  if (metrics) {
    metrics.innerHTML = D.metrics.map((m) => `
      <article class="dim">
        <header><h3>${C.esc(m.id)} · ${C.esc(m.name)}</h3><span class="tag">${C.esc(m.stage)}</span></header>
        <p class="muted" style="margin-top:8px">${C.esc(m.blurb)}</p>
      </article>`).join("");
  }
  const axes = document.getElementById("axes");
  if (axes) {
    axes.innerHTML = D.axes.map((a) => `
      <article class="axis">
        <h3>${C.esc(a.name)}</h3>
        ${a.items.map(([k, v]) => `<div class="axis-item"><span class="tag">${k}</span><span>${C.esc(v)}</span></div>`).join("")}
      </article>`).join("");
  }
  const paths = document.getElementById("pathGrid");
  if (paths) {
    paths.innerHTML = D.paths.map((p) => `
      <article class="dim">
        <header><h3>${C.esc(p.id)} · ${C.esc(p.name)}</h3></header>
        <p class="muted" style="margin-top:8px">${C.esc(p.detail)}</p>
      </article>`).join("");
  }
  const table = document.getElementById("sysTable");
  if (table) {
    table.innerHTML = `<thead><tr><th>Model</th><th>FCS</th><th>FCR</th><th>ERF</th><th>CDC</th><th>ROH</th><th>OCR</th><th>CAVE</th></tr></thead>
      <tbody>${D.models.map((m, i) => {
        const hi = i === D.models.length - 1 || m.ocr === 60.06;
        return `<tr>
          <td>${C.esc(m.id)}</td>
          <td>${m.fcs.toFixed(2)}</td><td>${m.fcr.toFixed(2)}</td>
          <td>${m.erf.toFixed(2)}</td><td>${m.cdc.toFixed(2)}</td>
          <td>${m.roh.toFixed(2)}</td>
          <td class="${m.ocr >= 48 ? "hi" : m.ocr <= 20 ? "lo" : ""}">${m.ocr.toFixed(2)}</td>
          <td class="${m.cave >= 40 ? "hi" : m.cave <= 10 ? "lo" : ""}">${m.cave.toFixed(2)}</td>
        </tr>`;
      }).join("")}</tbody>`;
  }
  const toc = document.getElementById("findToc");
  if (toc) {
    const links = [...toc.querySelectorAll("a")];
    const io = new IntersectionObserver((ents) => {
      ents.forEach((e) => {
        if (!e.isIntersecting) return;
        links.forEach((a) => a.classList.toggle("on", a.getAttribute("href") === "#" + e.target.id));
      });
    }, { rootMargin: "-40% 0px -50% 0px" });
    links.forEach((a) => {
      const el = document.querySelector(a.getAttribute("href"));
      if (el) io.observe(el);
    });
  }
})();
