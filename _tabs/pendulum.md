---
icon: fas fa-atom
order: 5
---

<style>
#dp-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}
#dp-wrap canvas {
  border-radius: 10px;
  background: #0d1117;
  cursor: crosshair;
  max-width: 100%;
  display: block;
  touch-action: none;
}
#dp-wrap .dp-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
}
#dp-wrap button {
  padding: 0.35rem 0.9rem;
  border-radius: 6px;
  border: 1px solid #374151;
  background: #1f2937;
  color: #e5e7eb;
  cursor: pointer;
  font-size: 0.83rem;
  transition: background 0.15s, border-color 0.15s;
}
#dp-wrap button:hover { background: #374151; }
#dp-wrap button.dp-active {
  background: #1d4ed8;
  border-color: #3b82f6;
}
#dp-wrap .dp-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem 1.2rem;
  justify-content: center;
  max-width: 660px;
  width: 100%;
}
#dp-wrap .dp-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  min-width: 110px;
}
#dp-wrap .dp-group label {
  font-size: 0.8rem;
  font-weight: 600;
  color: #9ca3af;
  white-space: nowrap;
}
#dp-wrap .dp-group input[type="range"] {
  width: 110px;
  cursor: pointer;
}
#dp-wrap .dp-note {
  font-size: 0.78rem;
  color: #6b7280;
  text-align: center;
  max-width: 540px;
  line-height: 1.55;
  margin-top: -0.2rem;
}
</style>

<div id="dp-wrap">
  <div class="dp-buttons">
    <button id="dp-pause">Pause</button>
    <button id="dp-reset">Reset</button>
    <button id="dp-add">+ Add Ghost</button>
    <button id="dp-clear">Clear Trail</button>
  </div>

  <canvas id="dp-canvas" width="600" height="520"></canvas>

  <div class="dp-controls">
    <div class="dp-group">
      <label>Gravity: <span id="dv-g">9.8</span></label>
      <input type="range" id="ds-g" min="1" max="30" step="0.1" value="9.8">
    </div>
    <div class="dp-group">
      <label>Length₁: <span id="dv-l1">1.5</span></label>
      <input type="range" id="ds-l1" min="0.3" max="2.5" step="0.05" value="1.5">
    </div>
    <div class="dp-group">
      <label>Length₂: <span id="dv-l2">1.5</span></label>
      <input type="range" id="ds-l2" min="0.3" max="2.5" step="0.05" value="1.5">
    </div>
    <div class="dp-group">
      <label>Mass₁: <span id="dv-m1">1.0</span></label>
      <input type="range" id="ds-m1" min="0.5" max="5" step="0.1" value="1.0">
    </div>
    <div class="dp-group">
      <label>Mass₂: <span id="dv-m2">1.0</span></label>
      <input type="range" id="ds-m2" min="0.5" max="5" step="0.1" value="1.0">
    </div>
    <div class="dp-group">
      <label>Damping: <span id="dv-damp">0.00</span></label>
      <input type="range" id="ds-damp" min="0" max="0.5" step="0.01" value="0">
    </div>
    <div class="dp-group">
      <label>Trail: <span id="dv-trail">400</span></label>
      <input type="range" id="ds-trail" min="0" max="3000" step="50" value="400">
    </div>
    <div class="dp-group">
      <label>Speed: <span id="dv-speed">1.0</span>×</label>
      <input type="range" id="ds-speed" min="0.1" max="5" step="0.1" value="1.0">
    </div>
  </div>

  <p class="dp-note">
    Drag either bob to reposition the pendulum. <strong>+ Add Ghost</strong> spawns a copy offset by 0.001 rad — watch identical-looking pendulums diverge wildly, a hallmark of <em>deterministic chaos</em>. Bob size reflects mass; trail length and simulation speed are adjustable.
  </p>
</div>

<script>
(function () {
  /* ── Parameters ──────────────────────────────────────────────────────── */
  let G = 9.8, L1 = 1.5, L2 = 1.5, M1 = 1.0, M2 = 1.0;
  let DAMP = 0.0, TRAIL_MAX = 400, SPEED = 1.0;

  const SCALE = 82;
  const canvas = document.getElementById('dp-canvas');
  const ctx    = canvas.getContext('2d');
  const OX = canvas.width  / 2;
  const OY = Math.round(canvas.height * 0.22);

  /* ── Pendulum factory ────────────────────────────────────────────────── */
  function mkPend(th1, om1, th2, om2, color, delta) {
    return { s: [th1, om1, th2, om2], trail: [], color, delta: delta || 0 };
  }

  let pends = [mkPend(Math.PI * 0.75, 0, Math.PI * 0.5, 0, '#60a5fa')];
  const GHOST_COLORS = ['#f87171','#34d399','#fbbf24','#a78bfa','#fb923c','#e879f9'];
  let ghostIdx = 0;

  /* ── Equations of motion (Lagrangian, exact) ─────────────────────────── */
  function deriv([th1, om1, th2, om2]) {
    const d     = th1 - th2;
    const cos2d = Math.cos(2 * d);
    const denom = 2 * M1 + M2 - M2 * cos2d;

    const dom1 = (
      -G * (2 * M1 + M2) * Math.sin(th1)
      - M2 * G * Math.sin(th1 - 2 * th2)
      - 2 * Math.sin(d) * M2 * (om2 * om2 * L2 + om1 * om1 * L1 * Math.cos(d))
    ) / (L1 * denom);

    const dom2 = (
      2 * Math.sin(d) * (
        om1 * om1 * L1 * (M1 + M2)
        + G  * (M1 + M2) * Math.cos(th1)
        + om2 * om2 * L2 * M2 * Math.cos(d)
      )
    ) / (L2 * denom);

    return [om1, dom1 - DAMP * om1, om2, dom2 - DAMP * om2];
  }

  function rk4(s, dt) {
    const k1 = deriv(s);
    const k2 = deriv(s.map((v, i) => v + k1[i] * dt / 2));
    const k3 = deriv(s.map((v, i) => v + k2[i] * dt / 2));
    const k4 = deriv(s.map((v, i) => v + k3[i] * dt));
    return s.map((v, i) => v + (k1[i] + 2*k2[i] + 2*k3[i] + k4[i]) * dt / 6);
  }

  /* ── Cartesian positions ─────────────────────────────────────────────── */
  function xy(p) {
    const [th1, , th2] = p.s;
    const x1 = OX + L1 * SCALE * Math.sin(th1);
    const y1 = OY + L1 * SCALE * Math.cos(th1);
    const x2 = x1 + L2 * SCALE * Math.sin(th2);
    const y2 = y1 + L2 * SCALE * Math.cos(th2);
    return { x1, y1, x2, y2 };
  }

  /* ── Draw one pendulum ───────────────────────────────────────────────── */
  function drawPend(p, isMain) {
    const { x1, y1, x2, y2 } = xy(p);

    /* Trail — fade from transparent to opaque */
    if (TRAIL_MAX > 0 && p.trail.length > 1) {
      ctx.save();
      ctx.lineWidth = 1.5;
      for (let i = 1; i < p.trail.length; i++) {
        const alpha = (i / p.trail.length) * 0.7;
        ctx.strokeStyle = p.color;
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        ctx.moveTo(p.trail[i-1].x, p.trail[i-1].y);
        ctx.lineTo(p.trail[i].x,   p.trail[i].y);
        ctx.stroke();
      }
      ctx.restore();
    }

    /* Rods */
    ctx.save();
    ctx.strokeStyle = isMain ? '#94a3b8' : '#475569';
    ctx.lineWidth   = isMain ? 2.5 : 1.8;
    ctx.beginPath(); ctx.moveTo(OX, OY); ctx.lineTo(x1, y1); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();
    ctx.restore();

    /* Pivot */
    if (isMain) {
      ctx.fillStyle = '#cbd5e1';
      ctx.beginPath();
      ctx.arc(OX, OY, 5, 0, Math.PI * 2);
      ctx.fill();
    }

    /* Bob 1 */
    ctx.fillStyle = isMain ? '#94a3b8' : '#475569';
    ctx.beginPath();
    ctx.arc(x1, y1, 5 + M1 * 3, 0, Math.PI * 2);
    ctx.fill();

    /* Bob 2 */
    ctx.fillStyle = p.color;
    ctx.beginPath();
    ctx.arc(x2, y2, 5 + M2 * 3, 0, Math.PI * 2);
    ctx.fill();
    if (isMain) {
      ctx.save();
      ctx.strokeStyle = '#e2e8f0';
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.restore();
    }
  }

  /* ── Animation loop ──────────────────────────────────────────────────── */
  let paused = false, lastTs = null;

  function frame(ts) {
    if (!paused) {
      const elapsed = lastTs ? Math.min((ts - lastTs) / 1000, 0.05) : 0.016;
      lastTs = ts;
      const SUBSTEPS = 16;
      const dt = elapsed * SPEED / SUBSTEPS;
      for (const p of pends) {
        for (let i = 0; i < SUBSTEPS; i++) p.s = rk4(p.s, dt);
        if (TRAIL_MAX > 0) {
          const { x2, y2 } = xy(p);
          p.trail.push({ x: x2, y: y2 });
          if (p.trail.length > TRAIL_MAX) p.trail.shift();
        }
      }
    } else {
      lastTs = null;
    }

    /* Background */
    ctx.fillStyle = '#0d1117';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    /* Faint grid */
    ctx.strokeStyle = '#161e2a';
    ctx.lineWidth = 1;
    for (let x = 0; x < canvas.width; x += 50) {
      ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
    }
    for (let y = 0; y < canvas.height; y += 50) {
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
    }

    /* Draw ghosts first, main pendulum last (on top) */
    for (let i = pends.length - 1; i >= 0; i--) drawPend(pends[i], i === 0);

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);

  /* ── Pointer interaction (mouse + touch) ─────────────────────────────── */
  let dragBob = null;

  function evXY(e) {
    const r  = canvas.getBoundingClientRect();
    const sx = canvas.width  / r.width;
    const sy = canvas.height / r.height;
    const src = e.touches ? e.touches[0] : e;
    return { x: (src.clientX - r.left) * sx, y: (src.clientY - r.top) * sy };
  }

  canvas.addEventListener('pointerdown', e => {
    e.preventDefault();
    canvas.setPointerCapture(e.pointerId);
    const { x, y } = evXY(e);
    const { x1, y1, x2, y2 } = xy(pends[0]);
    dragBob = Math.hypot(x-x1, y-y1) < Math.hypot(x-x2, y-y2) ? 1 : 2;
    paused = true;
  });

  canvas.addEventListener('pointermove', e => {
    if (!dragBob) return;
    e.preventDefault();
    const { x, y } = evXY(e);
    const p = pends[0];
    if (dragBob === 1) {
      p.s[0] = Math.atan2(x - OX, y - OY);
      p.s[1] = 0;
    } else {
      const { x1, y1 } = xy(p);
      p.s[2] = Math.atan2(x - x1, y - y1);
      p.s[3] = 0;
    }
    for (let i = 1; i < pends.length; i++) {
      pends[i].s = [pends[0].s[0] + pends[i].delta, 0, pends[0].s[2], 0];
    }
    for (const p of pends) p.trail = [];
  });

  canvas.addEventListener('pointerup', e => {
    if (!dragBob) return;
    e.preventDefault();
    dragBob = null;
    paused = false;
  });

  /* ── Buttons ─────────────────────────────────────────────────────────── */
  const btnPause = document.getElementById('dp-pause');
  btnPause.addEventListener('click', function () {
    paused = !paused;
    this.textContent = paused ? 'Play' : 'Pause';
    this.classList.toggle('dp-active', paused);
  });

  document.getElementById('dp-reset').addEventListener('click', () => {
    pends    = [mkPend(Math.PI * 0.75, 0, Math.PI * 0.5, 0, '#60a5fa')];
    ghostIdx = 0;
    paused   = false;
    btnPause.textContent = 'Pause';
    btnPause.classList.remove('dp-active');
  });

  document.getElementById('dp-add').addEventListener('click', () => {
    if (pends.length >= 7) return;
    ghostIdx++;
    const sign  = ghostIdx % 2 === 0 ? 1 : -1;
    const delta = sign * Math.ceil(ghostIdx / 2) * 1e-3;
    const base  = pends[0].s;
    const color = GHOST_COLORS[(ghostIdx - 1) % GHOST_COLORS.length];
    pends.push(mkPend(base[0] + delta, 0, base[2], 0, color, delta));
  });

  document.getElementById('dp-clear').addEventListener('click', () => {
    for (const p of pends) p.trail = [];
  });

  /* ── Sliders ─────────────────────────────────────────────────────────── */
  function bindSlider(id, valId, setter, dp) {
    document.getElementById(id).addEventListener('input', function () {
      const v = parseFloat(this.value);
      document.getElementById(valId).textContent = v.toFixed(dp === undefined ? 1 : dp);
      setter(v);
      for (const p of pends) p.trail = [];
    });
  }

  bindSlider('ds-g',     'dv-g',     v => { G    = v; });
  bindSlider('ds-l1',    'dv-l1',    v => { L1   = v; });
  bindSlider('ds-l2',    'dv-l2',    v => { L2   = v; });
  bindSlider('ds-m1',    'dv-m1',    v => { M1   = v; });
  bindSlider('ds-m2',    'dv-m2',    v => { M2   = v; });
  bindSlider('ds-damp',  'dv-damp',  v => { DAMP = v; }, 2);
  bindSlider('ds-trail', 'dv-trail', v => { TRAIL_MAX = v; }, 0);
  bindSlider('ds-speed', 'dv-speed', v => { SPEED = v; });
})();
</script>
