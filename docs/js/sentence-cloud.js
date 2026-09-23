(function () {
  function esc(s) {
    const d = document.createElement("div");
    d.textContent = s;
    return d.innerHTML;
  }
  function rand(a, b) { return Math.random() * (b - a) + a; }

  function init() {
    const layer = document.getElementById("cloudLayer");
    const dataEl = document.getElementById("cloudData");
    const preview = document.getElementById("quotePreview");
    if (!layer || !dataEl) return;
    let cloud;
    try { cloud = JSON.parse(dataEl.textContent); } catch (e) { return; }

    const GRAD_NEG = [
      ["#C45C26", "#E8A54B"], ["#B42318", "#C45C26"], ["#9A3F16", "#E07A2E"],
      ["#D97706", "#C45C26"], ["#E8A54B", "#B45309"], ["#F59E0B", "#C45C26"],
    ];
    const GRAD_RISK = [
      ["#E8A54B", "#F6D59A"], ["#F0C674", "#C45C26"], ["#D4A373", "#E8A54B"],
      ["#E07A2E", "#F4C98B"], ["#C45C26", "#F0B429"], ["#B45309", "#E8A54B"],
    ];
    const FLOAT = ["f1", "f2", "f3", "f4", "f5", "f6"];
    function fontSize() {
      const w = window.innerWidth;
      if (w <= 480) return rand(13, 14.5);
      if (w <= 768) return rand(14, 15.5);
      return rand(17, 19);
    }
    const w = window.innerWidth;
    const SLOTS = w <= 768 ? [
      { x: "3%", y: "10%", w: "30ch", a: "left", side: "left" },
      { x: "3%", y: "10%", w: "28ch", a: "right", side: "right" },
      { x: "4%", y: "22%", w: "30ch", a: "left", side: "left" },
      { x: "3%", y: "22%", w: "28ch", a: "right", side: "right" },
      { x: "4%", y: "58%", w: "30ch", a: "left", side: "left" },
      { x: "3%", y: "58%", w: "28ch", a: "right", side: "right" },
      { x: "4%", y: "70%", w: "30ch", a: "left", side: "left" },
      { x: "3%", y: "70%", w: "28ch", a: "right", side: "right" },
    ] : [
      { x: "2%", y: "16%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "16%", w: "42ch", a: "right", side: "right" },
      { x: "2%", y: "26%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "26%", w: "42ch", a: "right", side: "right" },
      { x: "2%", y: "36%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "36%", w: "42ch", a: "right", side: "right" },
      { x: "2%", y: "50%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "50%", w: "42ch", a: "right", side: "right" },
      { x: "2%", y: "60%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "60%", w: "42ch", a: "right", side: "right" },
      { x: "2%", y: "70%", w: "42ch", a: "left", side: "left" },
      { x: "2%", y: "70%", w: "42ch", a: "right", side: "right" },
    ];
    const neg = (cloud.negative || []).map((t) => ({ text: t, group: "negative" }));
    const risk = (cloud.risky || []).map((t) => ({ text: t, group: "risky" }));
    const quotes = [];
    let ni = 0, ri = 0;
    while (quotes.length < SLOTS.length && (ni < neg.length || ri < risk.length)) {
      if (ni < neg.length) quotes.push(neg[ni++]);
      if (quotes.length >= SLOTS.length) break;
      if (ri < risk.length) quotes.push(risk[ri++]);
    }
    const elements = [];
    quotes.slice(0, SLOTS.length).forEach((q, i) => {
      const slot = SLOTS[i];
      const palette = q.group === "risky" ? GRAD_RISK : GRAD_NEG;
      const grad = palette[i % palette.length];
      const el = document.createElement("span");
      el.className = "cloud-span";
      const isRight = slot.side.includes("right");
      const pos = isRight ? `right:${slot.x};left:auto;` : `left:${slot.x};`;
      el.style.cssText = `${pos}top:${slot.y};font-size:${fontSize()}px;opacity:0;--c1:${grad[0]};--c2:${grad[1]};--slot-width:${slot.w};--align:${slot.a};`;
      el.innerHTML = `<span class="label">&ldquo;${esc(q.text)}&rdquo;</span>`;
      if (preview) {
        el.addEventListener("mouseenter", () => {
          preview.textContent = `"${q.text}"`;
          preview.classList.add("visible");
        });
        el.addEventListener("mouseleave", () => preview.classList.remove("visible"));
      }
      layer.appendChild(el);
      elements.push({
        el, opacity: rand(0.42, 0.58),
        anim: FLOAT[Math.floor(Math.random() * FLOAT.length)],
        dur: rand(14, 30), delay: rand(-20, 0),
      });
    });
    setTimeout(() => {
      const groups = {};
      const PAD = 10;
      elements.forEach((item, idx) => {
        const slot = SLOTS[idx];
        const key = slot.side;
        groups[key] = groups[key] || [];
        let r = item.el.getBoundingClientRect();
        let rect = { left: r.left, top: r.top, right: r.right, bottom: r.bottom };
        let attempts = 0;
        while (attempts < 6) {
          let hit = false;
          for (const pr of groups[key]) {
            if (!(rect.right + PAD < pr.left || rect.left - PAD > pr.right ||
                  rect.bottom + PAD < pr.top || rect.top - PAD > pr.bottom)) {
              hit = true;
              const shift = pr.bottom - rect.top + PAD + 4;
              item.el.style.top = `calc(${item.el.style.top} + ${shift}px)`;
              r = item.el.getBoundingClientRect();
              rect = { left: r.left, top: r.top, right: r.right, bottom: r.bottom };
              break;
            }
          }
          if (!hit) break;
          attempts++;
        }
        if (attempts >= 6) item.el.style.display = "none";
        else {
          groups[key].push(rect);
          item.el.style.opacity = item.opacity;
          item.el.style.animation = `${item.anim} ${item.dur}s ease-in-out ${item.delay}s infinite`;
        }
      });
    }, 80);
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
