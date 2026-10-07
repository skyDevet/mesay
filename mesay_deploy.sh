#!/bin/bash
set -e
echo "Creating project files..."
cat > package.json << 'END'
{
  "name": "mesayabebe",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0"
  },
  "dependencies": { "preact": "^10.20.1" },
  "devDependencies": { "@preact/preset-vite": "^2.8.2", "vite": "^5.2.0" }
}
END
cat > vite.config.js << 'END'
import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
export default defineConfig({ plugins: [preact()], server: { host: '0.0.0.0', port: 5173 } });
END
cat > server.js << 'END'
END
cat > index.html << 'END'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mesay Abebe General Contractor</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
END
cat > .gitignore << 'END'
# Dependencies
node_modules/
.cache/

# Build outputs - THESE WILL NOT BE PUSHED
dist/
.vite/
build/
.capacitor/


# OS files
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temporary
tmp/
backup_*/
END
mkdir -p src/components src/admin src/data 
cat > src/main.jsx << 'END'
import { render } from 'preact';
import { App } from './app.jsx';
import './style.css';
import './admin/admin.css';
import './print.css';
render(<App />, document.getElementById('app'));
END
cat > src/app.jsx << 'END'
import { useState, useEffect } from 'preact/hooks';
import { Nav } from './components/Nav.jsx';
import { Hero } from './components/Hero.jsx';
import { TrustStats } from './components/TrustStats.jsx';
import { Services } from './components/Services.jsx';
import { Projects } from './components/Projects.jsx';
import { Catalog } from './components/Catalog.jsx';
import { RequestMaterials } from './components/RequestMaterials.jsx';
import { RequestServices } from './components/RequestServices.jsx';
import { Reviews } from './components/Reviews.jsx';
import { ProjectModal } from './components/ProjectModal.jsx';
import { Footer } from './components/Footer.jsx';
import { StaffLogin } from './admin/StaffLogin.jsx';
import { Admin } from './admin/Admin.jsx';
import { getRateBookMeta, seedFromModule } from './data/ratebook.js';

export function App() {
  const [activeProject, setActiveProject] = useState(null);
  const [staff, setStaff] = useState(sessionStorage.getItem('mesay_staff') === '1');
  const [loginOpen, setLoginOpen] = useState(false);
  const [cart, setCart] = useState([]);

  useEffect(() => {
    (async () => {
      try {
        const meta = await getRateBookMeta();
        if (!meta) {
          const res = await seedFromModule();
          console.log('Rate book auto-seeded:', res);
        }
      } catch (e) { console.error('Auto-seed failed:', e); }
    })();
  }, []);

  if (staff) return <Admin onExit={() => setStaff(false)} />;
  if (loginOpen) return <StaffLogin onSuccess={() => { setLoginOpen(false); setStaff(true); }} onExit={() => setLoginOpen(false)} />;

  return (
    <>
      <Nav onStaff={() => setLoginOpen(true)} />
      <Hero />
      <TrustStats />
      <Services />
      <Projects onOpen={setActiveProject} />
      <Catalog cart={cart} setCart={setCart} />
      <RequestMaterials cart={cart} setCart={setCart} />
      <RequestServices />
      <Reviews />
      <Footer />
      {activeProject && <ProjectModal project={activeProject} onClose={() => setActiveProject(null)} />}
    </>
  );
}
END
cat > src/style.css << 'END'
:root { --primary: #f59e0b; --primary-dark: #d97706; --dark: #1f2937; --darker: #111827; --light: #f9fafb; --gray: #6b7280; --border: #e5e7eb; --success: #10b981; --ethio-green: #078930; --ethio-yellow: #fcdd09; --ethio-red: #da121a; --radius: 10px; --shadow: 0 4px 14px rgba(0,0,0,0.08); }
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans Ethiopic", sans-serif; color: var(--dark); background: var(--light); line-height: 1.6; -webkit-font-smoothing: antialiased; }
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; border: none; background: none; }
img { max-width: 100%; display: block; }
.container { max-width: 1100px; margin: 0 auto; padding: 0 20px; }
.nav { background: var(--darker); color: white; position: sticky; top: 0; z-index: 100; box-shadow: 0 2px 10px rgba(0,0,0,0.2); }
.nav-inner { display: flex; align-items: center; justify-content: space-between; padding: 14px 20px; max-width: 1100px; margin: 0 auto; }
.logo { font-weight: 800; font-size: 1.1rem; white-space: nowrap; }
.logo span { color: var(--primary); }
.nav-links { display: flex; gap: 16px; align-items: center; }
.nav-links a { font-size: 0.88rem; font-weight: 500; opacity: 0.85; }
.nav-links a:hover { color: var(--primary); opacity: 1; }
.nav-cta { background: var(--primary); color: var(--darker) !important; padding: 8px 12px; border-radius: var(--radius); font-weight: 700; opacity: 1 !important; }
.nav-toggle { display: none; color: white; font-size: 1.5rem; }
@media (max-width: 820px) { .nav-toggle { display: block; } .nav-links { position: absolute; top: 100%; left: 0; right: 0; background: var(--darker); flex-direction: column; padding: 20px; gap: 14px; display: none; } .nav-links.open { display: flex; } }
.hero { background: linear-gradient(135deg, #1f2937 0%, #111827 100%); color: white; padding: 60px 20px 70px; text-align: center; position: relative; overflow: hidden; }
.hero::before { content: ""; position: absolute; inset: 0; background-image: repeating-linear-gradient(45deg, rgba(245,158,11,0.06) 0 20px, transparent 20px 40px); }
.hero::after { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, var(--ethio-green) 33%, var(--ethio-yellow) 33% 66%, var(--ethio-red) 66%); }
.hero-content { position: relative; max-width: 800px; margin: 0 auto; }
.grade-badge { display: inline-block; background: rgba(245,158,11,0.2); color: var(--primary); padding: 6px 14px; border-radius: 50px; font-size: 0.76rem; font-weight: 700; margin-bottom: 18px; }
.hero h1 { font-size: clamp(1.5rem, 4.2vw, 2.4rem); font-weight: 800; line-height: 1.2; margin-bottom: 14px; }
.hero p { font-size: 0.98rem; opacity: 0.85; margin-bottom: 26px; }
.hero-btns { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; }
.hero-badges { display: flex; justify-content: center; gap: 18px; flex-wrap: wrap; margin-top: 26px; font-size: 0.8rem; opacity: 0.75; }
.hero-badges span::before { content: "✓ "; color: var(--success); font-weight: bold; }
.hero-contact { display: flex; justify-content: center; gap: 18px; flex-wrap: wrap; margin-top: 18px; font-size: 0.82rem; opacity: 0.85; }
.btn { display: inline-block; padding: 12px 24px; border-radius: var(--radius); font-weight: 700; font-size: 0.9rem; transition: transform 0.15s; }
.btn:hover { transform: translateY(-2px); }
.btn-primary { background: var(--primary); color: var(--darker); }
.btn-primary:hover { background: var(--primary-dark); }
.btn-outline { background: transparent; border: 2px solid white; color: white; }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-back { background: var(--border); color: var(--dark); padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 0.82rem; }
.section { padding: 55px 20px; }
.section-header { text-align: center; margin-bottom: 36px; }
.section-header h2 { font-size: clamp(1.4rem, 3.8vw, 1.9rem); font-weight: 800; margin-bottom: 8px; }
.section-header p { color: var(--gray); max-width: 560px; margin: 0 auto; font-size: 0.95rem; }
.section.alt { background: white; }
.trust-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; text-align: center; }
.trust-item { background: white; padding: 22px 14px; border-radius: var(--radius); box-shadow: var(--shadow); }
.trust-item .num { font-size: 1.5rem; font-weight: 800; color: var(--primary); display: block; }
.trust-item .lbl { font-size: 0.8rem; color: var(--gray); }
.services-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 18px; }
.service-card { background: white; padding: 24px; border-radius: var(--radius); box-shadow: var(--shadow); }
.service-icon { font-size: 2.2rem; margin-bottom: 10px; }
.service-card h3 { font-size: 1.05rem; margin-bottom: 6px; }
.service-card p { font-size: 0.88rem; color: var(--gray); }
.gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 18px; }
.project-card { background: white; border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow); cursor: pointer; transition: transform 0.2s; }
.project-card:hover { transform: translateY(-4px); }
.project-img { height: 170px; background: linear-gradient(135deg, #94a3b8, #475569); display: flex; align-items: center; justify-content: center; color: white; font-size: 2.4rem; position: relative; }
.project-tag { position: absolute; top: 12px; left: 12px; background: var(--primary); color: var(--darker); font-size: 0.68rem; font-weight: 700; padding: 3px 10px; border-radius: 50px; text-transform: uppercase; }
.project-info { padding: 14px; }
.project-info h3 { font-size: 1rem; margin-bottom: 4px; }
.project-info p { font-size: 0.84rem; color: var(--gray); }
.project-meta { display: flex; justify-content: space-between; margin-top: 10px; font-size: 0.78rem; color: var(--gray); border-top: 1px solid var(--border); padding-top: 10px; flex-wrap: wrap; gap: 6px; }
.filters { display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; margin-bottom: 24px; }
.filter-btn { padding: 7px 14px; border-radius: 50px; background: white; border: 1px solid var(--border); font-size: 0.82rem; font-weight: 600; color: var(--gray); }
.filter-btn.active { background: var(--dark); color: white; border-color: var(--dark); }
.catalog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 18px; }
.product-card { background: white; border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow); display: flex; flex-direction: column; }
.product-img { height: 120px; background: linear-gradient(135deg, #334155, #1f2937); display: flex; align-items: center; justify-content: center; position: relative; }
.product-cat { position: absolute; top: 10px; left: 10px; background: var(--primary); color: var(--darker); font-size: 0.66rem; font-weight: 700; padding: 3px 9px; border-radius: 50px; text-transform: uppercase; }
.product-icon { font-size: 2.6rem; }
.product-info { padding: 14px; flex: 1; display: flex; flex-direction: column; }
.product-info h3 { font-size: 0.95rem; margin-bottom: 6px; }
.product-meta { display: flex; justify-content: space-between; font-size: 0.76rem; color: var(--gray); margin-bottom: 10px; }
.product-actions { display: flex; gap: 6px; margin-top: auto; }
.product-actions input { width: 70px; padding: 8px; border: 1px solid var(--border); border-radius: 6px; font-size: 0.85rem; font-family: inherit; }
.btn-add-cart { flex: 1; background: var(--primary); color: var(--darker); padding: 8px; border-radius: 6px; font-weight: 700; font-size: 0.82rem; }
.cart-summary { background: var(--darker); color: white; padding: 14px 20px; border-radius: var(--radius); margin-top: 20px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; }
.reviews-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.review-card { background: white; padding: 20px; border-radius: var(--radius); box-shadow: var(--shadow); }
.review-stars { color: var(--primary); margin-bottom: 8px; letter-spacing: 2px; }
.review-card p { font-size: 0.88rem; font-style: italic; color: #374151; margin-bottom: 12px; }
.review-author { font-size: 0.82rem; font-weight: 700; }
.review-loc { font-size: 0.76rem; color: var(--gray); }
footer { background: var(--darker); color: white; padding: 36px 20px 22px; text-align: center; }
footer .license { display: inline-block; background: rgba(245,158,11,0.15); color: var(--primary); padding: 7px 14px; border-radius: 50px; font-size: 0.74rem; font-weight: 600; margin: 12px 0; }
footer p { font-size: 0.82rem; opacity: 0.7; }
footer .foot-links { margin: 14px 0; display: flex; justify-content: center; gap: 18px; flex-wrap: wrap; font-size: 0.84rem; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; padding: 20px; z-index: 1000; }
.modal { background: white; border-radius: var(--radius); max-width: 520px; width: 100%; max-height: 85vh; overflow-y: auto; padding: 26px; position: relative; }
.modal h2 { margin-bottom: 6px; font-size: 1.25rem; }
.modal-close { position: absolute; top: 14px; right: 14px; font-size: 1.5rem; color: var(--gray); }
.modal-meta { display: flex; gap: 14px; font-size: 0.8rem; color: var(--gray); margin: 14px 0; padding: 12px 0; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); flex-wrap: wrap; }
.wizard { background: white; border-radius: var(--radius); padding: 28px; max-width: 560px; margin: 0 auto; box-shadow: var(--shadow); }
.wizard-success { text-align: center; padding: 20px 0; }
.wizard-success .check { font-size: 3.5rem; color: var(--success); margin-bottom: 12px; }
.wizard-options { display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px; }
.wizard-option { padding: 14px 16px; border: 2px solid var(--border); border-radius: 8px; background: white; text-align: left; font-size: 0.92rem; font-weight: 500; }
.wizard-option.selected { border-color: var(--primary); background: #fffbeb; }
.pf-builder { background: white; padding: 24px; border-radius: var(--radius); box-shadow: var(--shadow); max-width: 1000px; margin: 0 auto; }
.pf-builder h3 { margin: 20px 0 10px; font-size: 1rem; }
.pf-builder h3:first-child { margin-top: 0; }
.pf-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.pf-grid label { display: flex; align-items: center; font-size: 0.85rem; font-weight: 600; color: var(--gray); }
@media (max-width: 600px) { .pf-grid { grid-template-columns: 1fr; } }
.pf-builder input, .pf-builder select, .pf-builder textarea { width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 8px; font-family: inherit; font-size: 0.9rem; background: white; margin-bottom: 10px; }
.pf-builder input:focus, .pf-builder select:focus, .pf-builder textarea:focus { outline: none; border-color: var(--primary); }
.pf-add-row { display: grid; grid-template-columns: 1fr 2fr 80px 80px 90px; gap: 8px; align-items: center; }
@media (max-width: 720px) { .pf-add-row { grid-template-columns: 1fr 1fr; } }
.pf-add-row input, .pf-add-row select { margin-bottom: 0; }
.pf-unit { font-size: 0.76rem; color: var(--gray); text-align: center; }
.pf-table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 0.86rem; }
.pf-table th, .pf-table td { padding: 8px 10px; border-bottom: 1px solid var(--border); text-align: left; }
.pf-table th { background: #f9fafb; font-size: 0.74rem; text-transform: uppercase; color: var(--gray); }
.pf-table input { width: 85px; padding: 4px 6px; margin: 0; font-size: 0.85rem; }
.pf-totals { background: #f9fafb; padding: 16px; border-radius: 8px; margin-top: 16px; }
.pf-totals > div { display: flex; justify-content: space-between; padding: 4px 0; font-size: 0.88rem; }
.pf-grand { border-top: 2px solid var(--dark); margin-top: 8px; padding-top: 10px !important; font-weight: 800; font-size: 1rem !important; }
.pf-grand span:last-child { color: var(--primary); }
.pf-lead { color: var(--success); font-size: 0.8rem !important; font-weight: 600; }
.pf-actions { display: flex; gap: 10px; margin-top: 18px; flex-wrap: wrap; }
.pf-actions .btn-primary { flex: 1; min-width: 160px; }
.pf-status { padding: 3px 10px; border-radius: 50px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
.pf-status.draft { background: #e5e7eb; color: #374151; }
.pf-status.sent { background: #fef3c7; color: #92400e; }
.pf-status.accepted, .pf-status.quoted { background: #d1fae5; color: #065f46; }
.pf-status.rejected, .pf-status.expired { background: #fee2e2; color: #991b1b; }
.pf-doc { background: white; padding: 36px; border-radius: var(--radius); box-shadow: var(--shadow); max-width: 900px; margin: 0 auto; }
.pf-doc-header { display: flex; justify-content: space-between; gap: 20px; border-bottom: 2px solid var(--dark); padding-bottom: 18px; margin-bottom: 18px; flex-wrap: wrap; }
.pf-doc-header h1 { font-size: 1.25rem; margin-bottom: 6px; }
.pf-doc-header p { font-size: 0.82rem; color: var(--gray); }
.pf-doc-meta { text-align: right; }
.pf-doc-meta h2 { font-size: 0.95rem; letter-spacing: 3px; color: var(--gray); margin-bottom: 6px; }
.pf-doc-meta strong { font-size: 1.05rem; color: var(--primary); }
.pf-doc-client { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 22px; }
@media (max-width: 600px) { .pf-doc-client { grid-template-columns: 1fr; } }
.pf-doc-client strong { display: block; font-size: 0.72rem; text-transform: uppercase; color: var(--gray); margin-bottom: 6px; }
.pf-doc-client p { font-size: 0.88rem; }
.pf-doc-table { margin: 18px 0; }
.pf-doc-totals { margin-left: auto; max-width: 340px; margin-top: 12px; }
.pf-doc-totals > div { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.88rem; }
.pf-doc-totals .pf-grand { font-size: 1.05rem; }
.pf-doc-terms { margin-top: 22px; padding-top: 18px; border-top: 1px solid var(--border); font-size: 0.82rem; color: var(--gray); }
.pf-doc-terms strong { display: block; color: var(--dark); margin-bottom: 4px; font-size: 0.85rem; }
.pf-doc-sign { display: flex; justify-content: space-between; margin-top: 50px; font-size: 0.78rem; color: var(--gray); gap: 20px; flex-wrap: wrap; }

/* --- Before & After Slider --- */
.before-after-wrapper {
  position: relative;
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
  aspect-ratio: 16 / 9; /* Adjust to match your images */
  overflow: hidden;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  user-select: none; /* Prevents text selection while dragging */
}

.ba-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  pointer-events: none; /* Prevents images from interfering with the slider */
}

/* The "After" image is inside a container that gets clipped */
.ba-after-clip {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  overflow: hidden;
  border-right: 3px solid #fff; /* The white line of the slider */
  z-index: 2;
}

.ba-after {
  /* Ensure the after image stays the same size as the wrapper, even when clipped */
  width: 100vw; 
  max-width: 900px; /* Must match wrapper max-width */
  height: 100%;
}

/* The vertical slider line and handle */
.ba-slider-line {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 3px;
  background: #fff;
  z-index: 3;
  transform: translateX(-50%);
  pointer-events: none;
}

.ba-slider-handle {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 40px;
  height: 40px;
  background: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 10px rgba(0,0,0,0.3);
  color: #333;
  font-size: 1.2rem;
  font-weight: bold;
}

/* The invisible range input that covers the whole area to capture dragging */
.ba-range-input {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: ew-resize; /* Shows left-right arrow cursor */
  z-index: 10;
  margin: 0;
}

/* Before/After Text Labels */
.ba-label {
  position: absolute;
  bottom: 1rem;
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  z-index: 4;
  pointer-events: none;
}

.ba-label-before {
  right: 1rem;
}

.ba-label-after {
  left: 1rem;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
  .before-after-wrapper {
    aspect-ratio: 4 / 3;
  }
  .ba-slider-handle {
    width: 32px;
    height: 32px;
  }
}END
cat > src/print.css << 'END'
@media print { .nav, footer, .no-print, .section-header, .admin-header, .admin-tabs, .pf-actions, .pf-mode-tabs { display: none !important; } body { background: white; } .section { padding: 0; } .container { max-width: 100%; padding: 0; } .pf-doc { box-shadow: none; padding: 0; margin: 0; } .pf-doc-header { border-bottom-color: #000; } }
END
cat > src/admin/admin.css << 'END'
.admin { min-height: 100vh; background: #f3f4f6; }
.admin-header { background: var(--darker); color: white; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 50; }
.admin-header-actions { display: flex; gap: 8px; }
.admin-header button { padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 0.85rem; }
.btn-view { background: var(--primary); color: var(--darker); }
.btn-danger { background: #dc2626; color: white; padding: 8px 14px; border-radius: 8px; font-weight: 700; font-size: 0.85rem; }
.admin-tabs { display: flex; gap: 4px; padding: 12px 20px; background: white; border-bottom: 1px solid var(--border); overflow-x: auto; position: sticky; top: 54px; z-index: 40; }
.admin-tab { padding: 8px 14px; border-radius: 8px; background: transparent; font-weight: 600; font-size: 0.85rem; color: var(--gray); white-space: nowrap; }
.admin-tab.active { background: var(--dark); color: white; }
.admin-body { padding: 20px; max-width: 1000px; margin: 0 auto; }
.admin-panel h2 { margin-bottom: 18px; font-size: 1.2rem; }
.admin-panel-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; gap: 10px; flex-wrap: wrap; }
.admin-field { margin-bottom: 14px; }
.admin-field label { display: block; font-size: 0.8rem; font-weight: 600; margin-bottom: 4px; color: var(--gray); }
.admin-field input, .admin-field textarea, .admin-field select { width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 8px; font-family: inherit; font-size: 0.9rem; background: white; }
.admin-field input:focus, .admin-field textarea:focus { outline: none; border-color: var(--primary); }
.admin-grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.admin-grid3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; }
@media (max-width: 600px) { .admin-grid2, .admin-grid3 { grid-template-columns: 1fr; } }
.admin-card { background: white; border-radius: 10px; padding: 16px; margin-bottom: 14px; box-shadow: 0 1px 4px rgba(0,0,0,0.05); }
.admin-subcard { background: #f9fafb; border-radius: 8px; padding: 12px; margin-bottom: 8px; border: 1px solid var(--border); }
.admin-card-head { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
.admin-card-title { flex: 1; font-size: 0.95rem; font-weight: 700; border: 1px solid transparent; background: transparent; padding: 6px; border-radius: 6px; font-family: inherit; min-width: 120px; }
.admin-card-title:hover, .admin-card-title:focus { border-color: var(--border); background: white; outline: none; }
.admin-card-icon { width: 48px; text-align: center; font-size: 1.3rem; padding: 6px; border: 1px solid transparent; border-radius: 6px; background: transparent; }
.admin-card-icon:focus { border-color: var(--border); background: white; outline: none; }
.admin-row3 { display: grid; grid-template-columns: 90px 1fr 1fr 40px; gap: 8px; margin-bottom: 8px; align-items: center; }
.admin-row3 input { padding: 8px; border: 1px solid var(--border); border-radius: 6px; font-family: inherit; font-size: 0.88rem; }
.btn-add { background: var(--success); color: white; padding: 8px 14px; border-radius: 8px; font-weight: 700; font-size: 0.85rem; }
.btn-del { background: #fee2e2; color: #dc2626; padding: 6px 12px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; }
.nav-admin { background: transparent; color: white; font-size: 0.95rem; opacity: 0.7; }
.nav-admin:hover { opacity: 1; color: var(--primary); }
.nav-lang { background: rgba(245,158,11,0.2); color: var(--primary); padding: 6px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 700; }
.admin-msg { background: #fef3c7; color: #92400e; padding: 10px 14px; border-radius: 8px; font-size: 0.85rem; margin-bottom: 14px; font-weight: 600; }
.staff-login { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: var(--darker); padding: 20px; }
.staff-login-card { background: white; padding: 32px; border-radius: var(--radius); width: 100%; max-width: 400px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); }
.staff-login-card h2 { margin-bottom: 8px; font-size: 1.3rem; }
.staff-login-card p { font-size: 0.85rem; color: var(--gray); margin-bottom: 20px; }
.staff-login-card input { width: 100%; padding: 12px; border: 2px solid var(--border); border-radius: 8px; font-size: 1rem; font-family: inherit; margin-bottom: 12px; }
.staff-login-card input:focus { outline: none; border-color: var(--primary); }
.staff-err { color: #dc2626; font-size: 0.85rem; margin-bottom: 12px; }
.staff-login-actions { display: flex; gap: 8px; }
.staff-login-actions .btn-primary { flex: 1; }
.pf-mode-tabs { display: flex; gap: 6px; margin-bottom: 12px; }
.pf-mode { padding: 8px 16px; border-radius: 8px; background: var(--border); color: var(--gray); font-weight: 600; font-size: 0.85rem; }
.pf-mode.active { background: var(--dark); color: white; }
.pf-mode:disabled { opacity: 0.4; cursor: not-allowed; }
.ratebook-row { display: grid; grid-template-columns: 70px 1fr 70px 100px 70px; gap: 8px; align-items: center; padding: 8px; border-bottom: 1px solid var(--border); font-size: 0.82rem; }
.ratebook-row:hover { background: #f9fafb; }
.rb-code { font-family: monospace; color: var(--gray); font-size: 0.75rem; }
.rb-desc { font-size: 0.82rem; }
.rb-unit { color: var(--gray); font-size: 0.75rem; }
.rb-price { font-weight: 700; color: var(--primary); font-size: 0.8rem; text-align: right; }
END
cat > src/components/Catalog.jsx << 'END'
import { useState } from 'preact/hooks';
import { useStore } from '../data/store.js';
export function Catalog({ cart, setCart }) {
  const [data, lang] = useStore();
  const [active, setActive] = useState('all');
  const list = active === 'all' ? data.products : data.products.filter(p => p.category === active);
  const inCart = (id) => cart.find(c => c.sku === id);
  const add = (p) => {
    const existing = inCart(p.id);
    if (existing) setCart(cart.map(c => c.sku === p.id ? Object.assign({}, c, { qty: c.qty + 1 }) : c));
    else setCart([...cart, { sku: p.id, name: p.name, unit: p.unit, qty: 1 }]);
  };
  const remove = (id) => setCart(cart.filter(c => c.sku !== id));
  const setQty = (id, q) => setCart(cart.map(c => c.sku === id ? Object.assign({}, c, { qty: Math.max(1, +q || 1) }) : c));
  return (
    <section class="section" id="catalog"><div class="container">
      <div class="section-header">
        <h2>{lang === 'am' ? 'የቁሳቁስ ዝርዝር' : 'Materials Catalog'}</h2>
        <p>{lang === 'am' ? 'የሚፈልጉትን ይምረጡ እና ዋጋ ይጠይቁ።' : 'Select items and request a quote.'}</p>
      </div>
      <div class="filters">
        <button class={'filter-btn ' + (active === 'all' ? 'active' : '')} onClick={() => setActive('all')}>{lang === 'am' ? 'ሁሉም' : 'All'}</button>
        {data.categories.map(c => (<button class={'filter-btn ' + (active === c.id ? 'active' : '')} onClick={() => setActive(c.id)}>{c.icon} {lang === 'am' ? c.nameAm : c.name}</button>))}
      </div>
      <div class="catalog-grid">
        {list.map(p => {
          const added = inCart(p.id);
          const cat = data.categories.find(c => c.id === p.category);
          return (
            <div class="product-card">
              <div class="product-img"><span class="product-cat">{cat ? (lang === 'am' ? cat.nameAm : cat.name) : p.category}</span><span class="product-icon">{cat ? cat.icon : '📦'}</span></div>
              <div class="product-info"><h3>{p.name}</h3>
                <div class="product-meta"><span>per {p.unit}</span><span>Stock: {p.stock}</span></div>
                <div class="product-actions">
                  {added ? (<><input type="number" min="1" value={added.qty} onInput={e => setQty(p.id, e.target.value)} /><button class="btn-add-cart" onClick={() => remove(p.id)}>Remove</button></>) : (<button class="btn-add-cart" style="width:100%;" onClick={() => add(p)}>+ {lang === 'am' ? 'ወደ ዝርዝር ጨምር' : 'Add to Request List'}</button>)}
                </div>
              </div>
            </div>
          );
        })}
      </div>
      {cart.length > 0 && (
        <div class="cart-summary"><strong>{cart.length} item{cart.length > 1 ? 's' : ''}</strong> in your request list<a href="#request-materials" class="btn btn-primary" style="margin-left: 12px;">Continue to Request →</a></div>
      )}
    </div></section>
  );
}
END
cat > src/components/Footer.jsx << 'END'
import { useStore } from '../data/store.js';
export function Footer() {
  const [data, lang] = useStore();
  const b = data.business;
  return (
    <footer><div class="container">
      <div class="logo" style="font-size:1.4rem;">Mesay <span>Abebe</span></div>
      <div class="license">{b.fieldOfBusiness} · License {b.businessLicenseNo} · TIN {b.tin}</div>
      <div class="foot-links">
        <a href="#services">{lang === 'am' ? 'አገልግሎቶች' : 'Services'}</a>
        <a href="#projects">{lang === 'am' ? 'ፕሮጀክቶች' : 'Projects'}</a>
        <a href="#catalog">{lang === 'am' ? 'ቁሳቁሶች' : 'Materials'}</a>
        <a href={'tel:' + b.cell1.replace(/\s/g, '')}>{b.cell1}</a>
        <a href={'mailto:' + b.email}>{b.email}</a>
      </div>
      <p>{b.addressEn}</p>
      <p style="margin-top:4px;font-size:0.76rem;">Issued by {b.bureau} · Renewal {b.renewalDate} · Capital {b.capital}</p>
      <p style="margin-top:8px;">© 2024 {b.nameEn}. All rights reserved.</p>
    </div></footer>
  );
}
END
cat > src/components/Hero.jsx << 'END'
import { useStore } from '../data/store.js';

export function Hero() {
  const [data, lang] = useStore();
  const b = data.business, h = data.hero;

  return (
    <header class="hero">
      <div class="hero-content">
        
        {/* --- LOGO ADDED HERE --- */}
        <img 
          src="img/logof.jpg" 
          alt="Messay Abebebe General Contractor Logo" 
          class="hero-logo" 
        />

        <div class="grade-badge">
          {lang === 'am' ? 'አጠቃላይ ተቋራጭ' : 'GENERAL CONTRACTOR'} · G5
        </div>
        
        <h1>{lang === 'am' ? b.taglineAm : b.taglineEn}</h1>
        <p>{lang === 'am' ? b.subtitleAm : b.subtitleEn}</p>
        
        <div class="hero-btns">
          <a href="#request-services" class="btn btn-primary">
            {lang === 'am' ? 'የአገልግሎት ዋጋ ጠይቅ' : 'Request Service Quote'}
          </a>
          <a href="#request-materials" class="btn btn-outline">
            {lang === 'am' ? 'የቁሳቁስ ዋጋ ጠይቅ' : 'Request Materials Quote'}
          </a>
        </div>
        
        <div class="hero-badges">
          <span>{lang === 'am' ? h.badge1Am : h.badge1En}</span>
          <span>{lang === 'am' ? h.badge2Am : h.badge2En}</span>
          <span>{lang === 'am' ? h.badge3Am : h.badge3En}</span>
        </div>
        
        <div class="hero-contact">
          <span>📞 {b.cell1}</span>
          <span>📞 {b.cell2}</span>
          <span>📍 {b.zoneSubCity} · Woreda {b.woreda}</span>
        </div>
        
      </div>
    </header>
  );
}END
cat > src/components/Nav.jsx << 'END'
import { useState } from 'preact/hooks';
import { useStore } from '../data/store.js';
export function Nav({ onStaff }) {
  const [open, setOpen] = useState(false);
  const [data, lang, setLang] = useStore();
  const links = [
    ['#services', lang === 'am' ? 'አገልግሎቶች' : 'Services'],
    ['#projects', lang === 'am' ? 'ፕሮጀክቶች' : 'Projects'],
    ['#catalog', lang === 'am' ? 'ቁሳቁሶች' : 'Materials'],
    ['#request-materials', lang === 'am' ? 'ዋጋ ጠይቅ' : 'Request Quote'],
  ];
  return (
    <nav class="nav">
      <div class="nav-inner">
        <a href="#" class="logo">Mesay <span>Abebe</span></a>
        <button class="nav-toggle" onClick={() => setOpen(!open)}>☰</button>
        <div class={'nav-links ' + (open ? 'open' : '')}>
          {links.map(([h, l]) => <a href={h} onClick={() => setOpen(false)}>{l}</a>)}
          <button class="nav-lang" onClick={() => setLang(lang === 'en' ? 'am' : 'en')}>{lang === 'en' ? 'አማ' : 'EN'}</button>
          <a href={'tel:' + data.business.cell1.replace(/\s/g, '')} class="nav-cta">📞</a>
          <button class="nav-admin" onClick={onStaff}>🔒</button>
        </div>
      </div>
    </nav>
  );
}
END
cat > src/components/ProjectModal.jsx << 'END'
export function ProjectModal({ project, onClose }) {
  if (!project) return null;
  return (
    <div class="modal-overlay" onClick={onClose}>
      <div class="modal" onClick={e => e.stopPropagation()}>
        <button class="modal-close" onClick={onClose}>✕</button>
        <h2>{project.title}</h2>
        <p style="color: var(--gray); font-size: 0.9rem;">{project.desc}</p>
        <div class="modal-meta">
          <span><strong>Type:</strong> {project.type}</span>
          <span><strong>Budget:</strong> {project.budget}</span>
          <span><strong>Duration:</strong> {project.duration}</span>
          <span><strong>Year:</strong> {project.year}</span>
          <span><strong>Client:</strong> {project.client}</span>
        </div>
        <a href="#request-services" onClick={onClose} class="btn btn-primary" style="display:block;text-align:center;margin-top:14px;">Request Similar Project</a>
      </div>
    </div>
  );
}
END
cat > src/components/Projects.jsx << 'END'
import { useStore } from '../data/store.js';
export function Projects({ onOpen }) {
  const [data] = useStore();
  return (
    <section class="section alt" id="projects"><div class="container">
      <div class="section-header"><h2>Recent Projects</h2><p>Delivered across Addis Ababa — buildings, roads, fit-outs.</p></div>
      <div class="gallery-grid">
        {data.projects.map(p => (
          <div class="project-card" onClick={() => onOpen(p)}>
            <div class="project-img"><span class="project-tag">{p.type}</span>{p.icon}</div>
            <div class="project-info"><h3>{p.title}</h3><p>{p.desc}</p>
              <div class="project-meta"><span>💰 {p.budget}</span><span>⏱ {p.duration}</span></div>
            </div>
          </div>
        ))}
      </div>
    </div></section>
  );
}
END
cat > src/components/RequestMaterials.jsx << 'END'
import { useState } from 'preact/hooks';
import { useStore } from '../data/store.js';
import { saveRequest, newRequestId } from '../data/requests.js';
export function RequestMaterials({ cart, setCart }) {
  const [data, lang] = useStore();
  const [client, setClient] = useState({ name: '', phone: '', email: '', company: '', projectName: '', siteAddress: '', zone: 'addis', requiredBy: '', notes: '' });
  const [done, setDone] = useState(false);
  const [busy, setBusy] = useState(false);
  const set = (k, v) => setClient(Object.assign({}, client, { [k]: v }));
  const submit = async () => {
    if (!client.name || !client.phone || cart.length === 0) return;
    setBusy(true);
    await saveRequest({ id: newRequestId(), kind: 'materials', createdAt: new Date().toISOString(), status: 'new', client: Object.assign({}, client), cart: cart.slice() });
    setBusy(false); setDone(true); setCart([]);
  };
  if (done) return (
    <section class="section alt" id="request-materials"><div class="container"><div class="wizard" style="text-align:center;"><div class="wizard-success">
      <div class="check">✓</div><h2>Request Received!</h2>
      <p style="color: var(--gray); margin-top: 8px;">Thanks {client.name}! Our staff will send you a formal quote within 24 hours.</p>
    </div></div></div></section>
  );
  return (
    <section class="section alt" id="request-materials"><div class="container">
      <div class="section-header"><h2>{lang === 'am' ? 'የቁሳቁስ ዋጋ ጠይቅ' : 'Request Materials Quote'}</h2><p>Send us your list.</p></div>
      <div class="pf-builder">
        <h3>Your List ({cart.length} items)</h3>
        {cart.length === 0 ? (<p style="color: var(--gray); font-size:0.9rem;">Your list is empty. <a href="#catalog" style="color:var(--primary);">Browse the catalog →</a></p>) : (
          <table class="pf-table"><thead><tr><th>Item</th><th>Qty</th><th>Unit</th><th></th></tr></thead><tbody>
            {cart.map(l => (<tr><td>{l.name}</td>
              <td><input type="number" min="1" value={l.qty} onInput={e => setCart(cart.map(c => c.sku === l.sku ? Object.assign({}, c, { qty: Math.max(1, +e.target.value || 1) }) : c))} /></td>
              <td>{l.unit}</td><td><button class="btn-del" onClick={() => setCart(cart.filter(c => c.sku !== l.sku))}>✕</button></td></tr>))}
          </tbody></table>
        )}
        <h3>Your Details</h3>
        <div class="pf-grid">
          <input placeholder="Full name *" value={client.name} onInput={e => set('name', e.target.value)} />
          <input placeholder="Phone *" value={client.phone} onInput={e => set('phone', e.target.value)} />
          <input placeholder="Email" value={client.email} onInput={e => set('email', e.target.value)} />
          <input placeholder="Company" value={client.company} onInput={e => set('company', e.target.value)} />
          <input placeholder="Project name" value={client.projectName} onInput={e => set('projectName', e.target.value)} />
          <input placeholder="Site address" value={client.siteAddress} onInput={e => set('siteAddress', e.target.value)} />
          <select value={client.zone} onChange={e => set('zone', e.target.value)}>{data.freight.zones.map(z => <option value={z.id}>{z.name}</option>)}</select>
          <input type="date" value={client.requiredBy} onInput={e => set('requiredBy', e.target.value)} />
        </div>
        <textarea rows="3" placeholder="Additional notes" value={client.notes} onInput={e => set('notes', e.target.value)} />
        <div class="pf-actions"><button class="btn btn-primary" disabled={busy || !client.name || !client.phone || cart.length === 0} onClick={submit}>{busy ? 'Sending...' : (lang === 'am' ? 'ጥያቄ ላክ' : 'Submit Request')}</button></div>
      </div>
    </div></section>
  );
}
END
cat > src/components/RequestServices.jsx << 'END'
import { useState } from 'preact/hooks';
import { useStore } from '../data/store.js';
import { saveRequest, newRequestId } from '../data/requests.js';
export function RequestServices() {
  const [data, lang] = useStore();
  const [form, setForm] = useState({ serviceType: 'sv1', name: '', phone: '', email: '', company: '', projectName: '', siteAddress: '', description: '', budgetRange: '', timeline: 'planning' });
  const [done, setDone] = useState(false);
  const [busy, setBusy] = useState(false);
  const set = (k, v) => setForm(Object.assign({}, form, { [k]: v }));
  const submit = async () => {
    if (!form.name || !form.phone || !form.description) return;
    setBusy(true);
    await saveRequest({ id: newRequestId(), kind: 'services', createdAt: new Date().toISOString(), status: 'new',
      client: { name: form.name, phone: form.phone, email: form.email, company: form.company, projectName: form.projectName, siteAddress: form.siteAddress },
      serviceType: form.serviceType, description: form.description, budgetRange: form.budgetRange, timeline: form.timeline });
    setBusy(false); setDone(true);
  };
  if (done) return (
    <section class="section" id="request-services"><div class="container"><div class="wizard" style="text-align:center;"><div class="wizard-success">
      <div class="check">✓</div><h2>Request Received!</h2>
      <p style="color: var(--gray); margin-top: 8px;">Thanks {form.name}! Our estimating team will be in touch.</p>
    </div></div></div></section>
  );
  return (
    <section class="section" id="request-services"><div class="container">
      <div class="section-header"><h2>{lang === 'am' ? 'የአገልግሎት ዋጋ ጠይቅ' : 'Request Service Quote'}</h2><p>Tell us about your project.</p></div>
      <div class="pf-builder">
        <h3>Project Type</h3>
        <div class="wizard-options">
          {data.services.map(s => (<button class={'wizard-option ' + (form.serviceType === s.id ? 'selected' : '')} onClick={() => set('serviceType', s.id)}>{s.icon} {lang === 'am' ? s.titleAm : s.titleEn}</button>))}
        </div>
        <h3>Your Details</h3>
        <div class="pf-grid">
          <input placeholder="Full name *" value={form.name} onInput={e => set('name', e.target.value)} />
          <input placeholder="Phone *" value={form.phone} onInput={e => set('phone', e.target.value)} />
          <input placeholder="Email" value={form.email} onInput={e => set('email', e.target.value)} />
          <input placeholder="Company" value={form.company} onInput={e => set('company', e.target.value)} />
          <input placeholder="Project name" value={form.projectName} onInput={e => set('projectName', e.target.value)} />
          <input placeholder="Site address" value={form.siteAddress} onInput={e => set('siteAddress', e.target.value)} />
          <select value={form.budgetRange} onChange={e => set('budgetRange', e.target.value)}>
            <option value="">Estimated budget (optional)</option>
            <option value="lt5m">Under ETB 5M</option>
            <option value="5-20m">ETB 5M – 20M</option>
            <option value="20-100m">ETB 20M – 100M</option>
            <option value="100m+">ETB 100M+</option>
          </select>
          <select value={form.timeline} onChange={e => set('timeline', e.target.value)}>
            <option value="planning">Just planning</option><option value="3-6mo">3–6 months</option>
            <option value="1-3mo">1–3 months</option><option value="asap">ASAP</option>
          </select>
        </div>
        <textarea rows="4" placeholder="Describe your project *" value={form.description} onInput={e => set('description', e.target.value)} />
        <div class="pf-actions"><button class="btn btn-primary" disabled={busy || !form.name || !form.phone || !form.description} onClick={submit}>{busy ? 'Sending...' : (lang === 'am' ? 'ጥያቄ ላክ' : 'Submit Request')}</button></div>
      </div>
    </div></section>
  );
}
END
cat > src/components/Reviews.jsx << 'END'
import { useState } from 'react';
import { useStore } from '../data/store.js';

export function Reviews() {
  const [data, lang] = useStore();
  const [sliderPos, setSliderPos] = useState(50); // 50% default position

  return (
    <section class="section alt">
      <div class="container">
        
        {/* --- REVIEWS SECTION (Unchanged) --- */}
        <div class="section-header">
          <h2>{lang === 'am' ? 'የደንበኞች አስተያየት' : 'What Clients Say'}</h2>
        </div>
        <div class="reviews-grid">
          {data.reviews.map(r => (
            <div class="review-card" key={r.name}>
              <div class="review-stars">{'★'.repeat(r.stars)}</div>
              <p>"{r.text}"</p>
              <div class="review-author">{r.name}</div>
              <div class="review-loc">{r.loc}</div>
            </div>
          ))}
        </div>

        {/* --- BEFORE & AFTER SLIDER SECTION --- */}
        <div class="section-header" style={{ marginTop: '4rem' }}>
          <h2>{lang === 'am' ? 'የፕሮጀክት ለውጥ' : 'Project Transformations'}</h2>
          <p style={{ color: 'var(--text-muted, #666)', marginTop: '0.5rem' }}>
            {lang === 'am' ? 'በፊት እና በኋላ ያለውን ልዩነት ለማየት መስመሩን ይጎትቱ' : 'Drag the slider to see the before and after'}
          </p>
        </div>

        {/* Replace these with your actual image paths */}
        <div class="before-after-wrapper">
          {/* Before Image (Background) */}
          <img 
            src="/images/before-project.jpg" 
            alt="Before Construction" 
            class="ba-image ba-before" 
          />
          
          {/* After Image (Foreground, clipped by slider) */}
          <div 
            class="ba-after-clip" 
            style={{ width: `${sliderPos}%` }}
          >
            <img 
              src="/images/after-project.jpg" 
              alt="After Construction" 
              class="ba-image ba-after" 
            />
          </div>

          {/* Draggable Slider Line & Handle */}
          <div class="ba-slider-line" style={{ left: `${sliderPos}%` }}>
            <div class="ba-slider-handle">
              <span>↔</span>
            </div>
          </div>

          {/* Invisible Range Input to control the slider */}
          <input 
            type="range" 
            min="0" 
            max="100" 
            value={sliderPos} 
            onChange={(e) => setSliderPos(e.target.value)} 
            class="ba-range-input"
            aria-label="Before and after slider"
          />
          
          {/* Labels */}
          <span class="ba-label ba-label-before">Before</span>
          <span class="ba-label ba-label-after">After</span>
        </div>

      </div>
    </section>
  );
}END
cat > src/components/Services.jsx << 'END'
import { useStore } from '../data/store.js';
export function Services() {
  const [data, lang] = useStore();
  return (
    <section class="section" id="services"><div class="container">
      <div class="section-header">
        <h2>{lang === 'am' ? 'አገልግሎቶቻችን' : 'Our Services'}</h2>
        <p>{lang === 'am' ? 'በፈቃዳችን መሰረት የምንሰጣቸው አገልግሎቶች።' : 'Licensed capabilities under our General Contractor 511114 field of business.'}</p>
      </div>
      <div class="services-grid">
        {data.services.map(s => (<div class="service-card"><div class="service-icon">{s.icon}</div><h3>{lang === 'am' ? s.titleAm : s.titleEn}</h3><p>{s.descEn}</p></div>))}
      </div>
    </div></section>
  );
}
END
cat > src/components/TrustStats.jsx << 'END'
import { useStore } from '../data/store.js';
export function TrustStats() {
  const [data, lang] = useStore();
  return (
    <section class="section alt"><div class="container"><div class="trust-grid">
      {data.stats.map(s => (<div class="trust-item"><span class="num">{s.num}</span><span class="lbl">{lang === 'am' ? s.lblAm : s.lblEn}</span></div>))}
    </div></div></section>
  );
}
END
cat > src/data/db.js << 'END'
const DB_NAME = 'mesay_db';
const DB_VERSION = 1;
let _db = null;
export function openDB() {
  if (_db) return Promise.resolve(_db);
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = (e) => {
      const db = e.target.result;
      if (!db.objectStoreNames.contains('ratebook_categories')) db.createObjectStore('ratebook_categories', { keyPath: 'id' });
      if (!db.objectStoreNames.contains('ratebook_items')) {
        const s = db.createObjectStore('ratebook_items', { keyPath: 'id' });
        s.createIndex('by-category', 'categoryId');
        s.createIndex('by-code', 'code');
      }
      if (!db.objectStoreNames.contains('quote_requests')) {
        const s = db.createObjectStore('quote_requests', { keyPath: 'id' });
        s.createIndex('by-status', 'status');
        s.createIndex('by-kind', 'kind');
      }
      if (!db.objectStoreNames.contains('proformas')) {
        const s = db.createObjectStore('proformas', { keyPath: 'id' });
        s.createIndex('by-number', 'number');
        s.createIndex('by-status', 'status');
      }
      if (!db.objectStoreNames.contains('meta')) db.createObjectStore('meta', { keyPath: 'key' });
    };
    req.onsuccess = () => { _db = req.result; resolve(_db); };
    req.onerror = () => reject(req.error);
  });
}
function tx(store, mode) { return openDB().then(db => db.transaction(store, mode).objectStore(store)); }
export function put(store, value) { return tx(store, 'readwrite').then(s => new Promise((res, rej) => { const r = s.put(value); r.onsuccess = () => res(r.result); r.onerror = () => rej(r.error); })); }
export function putAll(store, values) { return openDB().then(db => new Promise((res, rej) => { const t = db.transaction(store, 'readwrite'); const s = t.objectStore(store); values.forEach(v => s.put(v)); t.oncomplete = () => res(values.length); t.onerror = () => rej(t.error); })); }
export function get(store, id) { return tx(store, 'readonly').then(s => new Promise((res, rej) => { const r = s.get(id); r.onsuccess = () => res(r.result); r.onerror = () => rej(r.error); })); }
export function getAll(store) { return tx(store, 'readonly').then(s => new Promise((res, rej) => { const r = s.getAll(); r.onsuccess = () => res(r.result); r.onerror = () => rej(r.error); })); }
export function getAllBy(store, indexName, value) { return tx(store, 'readonly').then(s => new Promise((res, rej) => { const r = s.index(indexName).getAll(value); r.onsuccess = () => res(r.result); r.onerror = () => rej(r.error); })); }
export function del(store, id) { return tx(store, 'readwrite').then(s => new Promise((res, rej) => { const r = s.delete(id); r.onsuccess = () => res(); r.onerror = () => rej(r.error); })); }
export function clearStore(store) { return tx(store, 'readwrite').then(s => new Promise((res, rej) => { const r = s.clear(); r.onsuccess = () => res(); r.onerror = () => rej(r.error); })); }
END
cat > src/data/pricing.js << 'END'
const round2 = (n) => Math.round(n * 100) / 100;
export function tierPrice(product, qty) {
  const tiers = (product.tiers || []).filter(t => qty >= t.min).sort((a, b) => b.min - a.min);
  return tiers.length ? tiers[0].price : product.basePrice;
}
export function calcLine(product, qty, opts = {}) {
  const basePrice = opts.basePriceOverride != null ? opts.basePriceOverride : tierPrice(product, qty);
  const contractorPrice = opts.contractorPrice != null ? opts.contractorPrice : basePrice;
  return { sku: product.id, name: product.name || product.description, unit: product.unit, qty, basePrice, contractorPrice, lineTotal: round2(qty * contractorPrice), margin: round2((contractorPrice - basePrice) * qty), taxable: product.taxable !== false, leadTimeDays: product.leadTimeDays || 0 };
}
export function calcLineFromRate(rateItem, qty, contractorPriceOverride) {
  const basePrice = rateItem.basePrice == null ? 0 : rateItem.basePrice;
  const contractorPrice = contractorPriceOverride != null ? contractorPriceOverride : (rateItem.contractorPrice != null ? rateItem.contractorPrice : basePrice);
  return { sku: rateItem.id, name: rateItem.description, unit: rateItem.unit, qty, basePrice, contractorPrice, lineTotal: round2(qty * contractorPrice), margin: round2((contractorPrice - basePrice) * qty), taxable: true, leadTimeDays: 0, code: rateItem.code };
}
export function calcProforma({ lines, freightZone, zones = [], discountPct = 0, vatRate = 0, markupPct = 0, contingencyPct = 0 }) {
  const subtotal = round2(lines.reduce((s, l) => s + l.lineTotal, 0));
  const markup = round2(subtotal * (markupPct / 100));
  const afterMarkup = round2(subtotal + markup);
  const contingency = round2(afterMarkup * (contingencyPct / 100));
  const afterContingency = round2(afterMarkup + contingency);
  const discount = round2(afterContingency * (discountPct / 100));
  const afterDiscount = round2(afterContingency - discount);
  const zone = zones.find(z => z.id === freightZone);
  const totalTons = lines.reduce((s, l) => s + (l.unit === 'ton' ? l.qty : 0), 0);
  const freight = zone ? round2((zone.flat || 0) + (zone.perTon || 0) * totalTons) : 0;
  const vat = round2(afterDiscount * vatRate);
  const grandTotal = round2(afterDiscount + freight + vat);
  const totalMargin = round2(lines.reduce((s, l) => s + (l.margin || 0), 0));
  const maxLead = lines.reduce((m, l) => Math.max(m, l.leadTimeDays || 0), 0);
  return { subtotal, markup, contingency, discount, afterDiscount, freight, vat, grandTotal, totalMargin, maxLead };
}
export function nextProformaNumber(existing = []) {
  const d = new Date();
  const ymd = d.toISOString().slice(0, 10).replace(/-/g, '');
  const todays = existing.filter(p => p.number && p.number.includes(ymd));
  return 'MA-PF-' + ymd + '-' + String(todays.length + 1).padStart(4, '0');
}
export function addDays(dateStr, days) {
  const d = new Date(dateStr);
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}
export function formatMoney(n, currency = 'ETB') {
  const v = Number(n) || 0;
  const s = v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return currency === 'ETB' ? 'Br ' + s : currency + ' ' + s;
}
END
cat > src/data/proformas.js << 'END'
import { put, get, getAll, del } from './db.js';

export async function saveProforma(pf) { return put('proformas', pf); }
export async function getProforma(id) { return get('proformas', id); }
export async function getProformas() { return getAll('proformas'); }
export async function deleteProforma(id) { return del('proformas', id); }

export async function updateProforma(id, patch) {
  const current = await get('proformas', id);
  if (!current) return null;
  const next = Object.assign({}, current, patch);
  await put('proformas', next);
  return next;
}

export async function updateProformaStatus(id, status) {
  return updateProforma(id, { status });
}

export async function duplicateProforma(id) {
  const src = await get('proformas', id);
  if (!src) return null;
  const all = await getAll('proformas');
  const today = new Date().toISOString().slice(0, 10);
  const ymd = today.replace(/-/g, '');
  const todays = all.filter(p => p.number && p.number.includes(ymd));
  const number = 'MA-PF-' + ymd + '-' + String(todays.length + 1).padStart(4, '0');
  const copy = Object.assign({}, src, {
    id: 'pf_' + Math.random().toString(36).slice(2, 9),
    number,
    createdAt: today,
    status: 'draft'
  });
  await put('proformas', copy);
  return copy;
}
END
cat > src/data/ratebook-data.js << 'END'
// Bundled rate book — Addis Ababa Design and Construction Works Bureau
// 2018 4th Quarter, Direct Cost Only, ETB
// PASTE YOUR DATA BELOW, REPLACING THE EXAMPLE CATEGORY

export const RATEBOOK = {
  "document": "file.pdf",
  "source": "Addis Ababa Design and Construction Works Bureau",
  "quarter": "2018 4th Quarter (Direct Cost Only)",
  "currency": "ETB",
  "categories": [
    {
      "id": "1",
      "title": "DEMOLITION WORK",
      "items": [
        {"page":6,"code":"1.1.1","description":"Demolishing the lamera wall","unit":"m²","price":"172.41"},
        {"page":6,"code":"1.1.2","description":"Demolishing the existing CIS wall","unit":"m²","price":"32.33"},
        {"page":6,"code":"1.1.3","description":"Demolishing of wooden wall","unit":"m²","price":"182.53"},
        {"page":6,"code":"1.1.4","description":"Demolishing of gypsum wall","unit":"m²","price":"91.27"},
        {"page":6,"code":"1.1.5","description":"Demolishing the CIS roof","unit":"m²","price":"51.72"},
        {"page":6,"code":"1.1.6","description":"Demolishing of 7x5 cm zigba purline","unit":"ml","price":"25.86"},
        {"page":6,"code":"1.1.7","description":"Demolishing of eucalyptus upper & lower chords","unit":"ml","price":"79.91"},
        {"page":6,"code":"1.1.8","description":"Dimolish RHS purline","unit":"ml","price":"43.10"},
        {"page":6,"code":"1.1.9","description":"Dimolishing the RHS truss.","unit":"ml","price":"103.01"},
        {"page":6,"code":"1.1.10","description":"Desmantling Gutter","unit":"ml","price":"34.30"},
        {"page":6,"code":"1.1.11","description":"Desmantling down pipe","unit":"ml","price":"69.82"},
        {"page":6,"code":"1.1.12","description":"Demolishing the chipwood ceiling","unit":"m²","price":"119.56"},
        {"page":6,"code":"1.1.13","description":"Demolishing the timber ceiling","unit":"m²","price":"166.06"},
        {"page":6,"code":"1.1.14","description":"Demolishing the abujed ceiling","unit":"m²","price":"41.51"},
        {"page":6,"code":"1.1.15","description":"Dismantle the metal doors from the wall.","unit":"m²","price":"169.07"},
        {"page":6,"code":"1.1.16","description":"Dismantle the metal windows from the wall.","unit":"m²","price":"152.16"},
        {"page":6,"code":"1.1.17","description":"Desmantling fascia board","unit":"ml","price":"47.65"},
        {"page":6,"code":"1.1.18","description":"Desmantling ridge & copping","unit":"ml","price":"68.60"},
        {"page":6,"code":"1.1.19","description":"Demolishing the PVC floor tile","unit":"m²","price":"45.63"},
        {"page":6,"code":"1.1.20","description":"Demolishing kitchen sink","unit":"pcs","price":"70.46"},
        {"page":6,"code":"1.1.21","description":"Demolishing toilet WC,HW,turkish seat","unit":"pcs","price":"211.37"},
        {"page":6,"code":"1.1.22","description":"Desmantling of wooden door & window","unit":"m²","price":"135.47"},
        {"page":6,"code":"1.2.1","description":"Masonary Structure (BGL)","unit":"m³","price":"580.90"},
        {"page":6,"code":"1.2.2","description":"Masonary Structure (AGL)","unit":"m³","price":"774.54"},
        {"page":6,"code":"1.2.3","description":"Demolishing of 25cm thick hardcore","unit":"m²","price":"54.56"},
        {"page":6,"code":"1.2.4","description":"Concrete Structures","unit":"m³","price":"2,580.74"},
        {"page":6,"code":"1.2.5","description":"10cm thick HCB Structure","unit":"m²","price":"55.46"},
        {"page":6,"code":"1.2.6","description":"15cm thick HCB Structure","unit":"m²","price":"73.61"},
        {"page":7,"code":"1.2.7","description":"20cm thick HCB Structure","unit":"m²","price":"103.06"},
        {"page":7,"code":"1.2.8","description":"Terrazzo floor","unit":"m²","price":"114.51"},
        {"page":7,"code":"1.2.9","description":"Cement screed floor","unit":"m²","price":"25.77"},
        {"page":7,"code":"1.2.10","description":"8cm thick Mass concrete floor","unit":"m²","price":"34.35"},
        {"page":7,"code":"1.2.11","description":"30x120x3cm thick marble tread","unit":"pcs","price":"227.83"},
        {"page":7,"code":"1.2.12","description":"15x120x3cm thick marble riser","unit":"pcs","price":"170.87"},
        {"page":7,"code":"1.2.13","description":"Steel Structure","unit":"Kg","price":"10.61"},
        {"page":7,"code":"1.2.14","description":"Demolishing the ceramic wall tile","unit":"m²","price":"114.51"},
        {"page":7,"code":"1.2.15","description":"Demolishing the ceramic floor tile (6 & 8 mm thick) — 1st–3rd floor","unit":"m²","price":"128.83"},
        {"page":7,"code":"1.2.16","description":"Concrete Structures","unit":"m³","price":"3,236.74"},
        {"page":7,"code":"1.2.17","description":"10cm thick HCB Structure","unit":"m²","price":"78.23"},
        {"page":7,"code":"1.2.18","description":"15cm thick HCB Structure","unit":"m²","price":"100.59"},
        {"page":7,"code":"1.2.19","description":"20cm thick HCB Structure","unit":"m²","price":"140.82"},
        {"page":7,"code":"1.2.20","description":"Terrazzo floor","unit":"m²","price":"150.07"},
        {"page":7,"code":"1.2.21","description":"Cement screed floor","unit":"m²","price":"33.77"},
        {"page":7,"code":"1.2.22","description":"30x120x3cm thick marble tread","unit":"m²","price":"281.17"},
        {"page":7,"code":"1.2.23","description":"15x120x3cm marble riser","unit":"m²","price":"210.87"},
        {"page":7,"code":"1.2.24","description":"Steel Structure","unit":"kg","price":"13.11"},
        {"page":7,"code":"1.2.25","description":"Demolishing the ceramic wall tile","unit":"m²","price":"150.07"},
        {"page":7,"code":"1.2.26","description":"Demolishing the ceramic floor tile (6 & 8 mm thick) — 4th–7th floor","unit":"m²","price":"168.83"},
        {"page":7,"code":"1.2.27","description":"Concrete Structures","unit":"m³","price":"4,036.74"},
        {"page":7,"code":"1.2.28","description":"10cm thick HCB Structure","unit":"m²","price":"80.82"},
        {"page":7,"code":"1.2.29","description":"15cm thick HCB Structure","unit":"m²","price":"103.91"},
        {"page":7,"code":"1.2.30","description":"20cm thick HCB Structure","unit":"m²","price":"145.47"},
        {"page":7,"code":"1.2.31","description":"Terrazzo floor","unit":"m²","price":"161.63"},
        {"page":7,"code":"1.2.32","description":"Cement screed floor","unit":"m²","price":"36.37"},
        {"page":7,"code":"1.2.33","description":"30x120x3cm thick marble tread","unit":"m²","price":"324.90"},
        {"page":7,"code":"1.2.34","description":"15x120x3cm marble riser","unit":"m²","price":"243.67"},
        {"page":7,"code":"1.2.35","description":"Steel Structure","unit":"kg","price":"19.32"},
        {"page":8,"code":"1.2.36","description":"Demolishing the ceramic wall tile","unit":"m²","price":"185.62"},
        {"page":8,"code":"1.2.37","description":"Demolishing the ceramic floor tile (6 & 8 mm thick) — 8th–12th floor","unit":"m²","price":"208.83"},
        {"page":8,"code":"1.2.38","description":"Concrete Structures","unit":"m³","price":"4,836.74"},
        {"page":8,"code":"1.2.39","description":"10cm thick HCB Structure","unit":"m²","price":"115.36"},
        {"page":8,"code":"1.2.40","description":"15cm thick HCB Structure","unit":"m²","price":"126.76"},
        {"page":8,"code":"1.2.41","description":"20cm thick HCB Structure","unit":"m²","price":"177.47"},
        {"page":8,"code":"1.2.42","description":"Terrazzo floor","unit":"m²","price":"197.19"},
        {"page":8,"code":"1.2.43","description":"Cement screed floor","unit":"m²","price":"44.37"},
        {"page":8,"code":"1.2.44","description":"30x120x3cm thick marble tread","unit":"m²","price":"378.23"},
        {"page":8,"code":"1.2.45","description":"15x120x3cm marble riser","unit":"pcs","price":"283.67"},
        {"page":8,"code":"1.2.46","description":"Steel Structure","unit":"kg","price":"19.01"},
        {"page":8,"code":"1.2.47","description":"Demolishing the ceramic wall tile","unit":"m²","price":"221.18"},
        {"page":8,"code":"1.2.48","description":"Demolishing the ceramic floor tile (6 & 8 mm thick) — 13th–20th floor","unit":"m²","price":"248.83"},
        {"page":8,"code":"1.2.49","description":"Concrete Structures","unit":"m³","price":"5,636.74"},
        {"page":8,"code":"1.2.50","description":"10cm thick HCB Structure","unit":"m²","price":"116.37"},
        {"page":8,"code":"1.2.51","description":"15cm thick HCB Structure","unit":"m²","price":"149.62"},
        {"page":8,"code":"1.2.52","description":"20cm thick HCB Structure","unit":"m²","price":"209.47"},
        {"page":8,"code":"1.2.53","description":"Terrazzo floor","unit":"m²","price":"232.74"},
        {"page":8,"code":"1.2.54","description":"Cement screed floor","unit":"m²","price":"52.37"},
        {"page":8,"code":"1.2.55","description":"30x120x3cm thick marble tread","unit":"m²","price":"431.57"},
        {"page":8,"code":"1.2.56","description":"15x120x3cm marble riser","unit":"pcs","price":"323.67"},
        {"page":8,"code":"1.2.57","description":"Steel Structure","unit":"kg","price":"21.51"},
        {"page":8,"code":"1.2.58","description":"Demolishing the ceramic wall tile","unit":"m²","price":"256.73"}
      ]
    },
    {
      "id": "2",
      "title": "EXCAVATION AND EARTH WORK — MECHANIZED",
      "items": [
        {"page":8,"code":"2.1.1","description":"20cm. Clearing on wet & black soil.","unit":"m²","price":"98.79"},
        {"page":8,"code":"2.2.1","description":"Bulk excavation in loose & dry soil — depth not exceeding 1.5m","unit":"m³","price":"368.92"},
        {"page":8,"code":"2.2.2","description":"Depth 1.50m–3.00m","unit":"m³","price":"452.22"},
        {"page":8,"code":"2.2.3","description":"Depth 3.00m–4.50m","unit":"m³","price":"547.61"},
        {"page":9,"code":"2.2.4","description":"Depth 4.50m–6.00m","unit":"m³","price":"625.84"},
        {"page":9,"code":"2.2.5","description":"Depth 6.00m–7.50m","unit":"m³","price":"730.15"},
        {"page":9,"code":"2.2.6","description":"Depth 7.50m–9.00m","unit":"m³","price":"876.18"},
        {"page":9,"code":"2.2.7","description":"Depth 9.00m–10.50m","unit":"m³","price":"973.53"},
        {"page":9,"code":"2.3.1","description":"Pit excavation in loose & dry soil — depth ≤1500mm","unit":"m³","price":"417.23"},
        {"page":9,"code":"2.3.2","description":"Depth 1500–3000mm","unit":"m³","price":"476.83"},
        {"page":9,"code":"2.3.3","description":"Depth 3000–4500mm","unit":"m³","price":"556.30"},
        {"page":9,"code":"2.3.4","description":"Depth 4500–6000mm","unit":"m³","price":"667.56"},
        {"page":9,"code":"2.3.5","description":"Depth 6000–7500mm","unit":"m³","price":"834.46"},
        {"page":9,"code":"2.3.6","description":"Depth 7500–9000mm","unit":"m³","price":"1,054.05"},
        {"page":9,"code":"2.3.7","description":"Depth 9000–10500mm","unit":"m³","price":"1,430.50"},
        {"page":9,"code":"2.4.1","description":"Bulk excavation in soft rock — depth ≤1.5m","unit":"m³","price":"666.61"},
        {"page":9,"code":"2.4.2","description":"Depth 1.5m–3m","unit":"m³","price":"760.13"},
        {"page":9,"code":"2.4.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"922.70"},
        {"page":9,"code":"2.4.4","description":"Depth 4.5m–6.0m","unit":"m³","price":"1,318.14"},
        {"page":9,"code":"2.4.5","description":"Depth 6.0m–7.5m","unit":"m³","price":"1,883.05"},
        {"page":9,"code":"2.4.6","description":"Depth 7.5m–9.0m","unit":"m³","price":"2,690.08"},
        {"page":9,"code":"2.4.7","description":"Depth 9.0m–10.5m","unit":"m³","price":"3,842.97"},
        {"page":9,"code":"2.5.1","description":"Pit excavation in soft rock — depth ≤1.5m","unit":"m³","price":"829.55"},
        {"page":9,"code":"2.5.2","description":"Depth 1.5m–3m","unit":"m³","price":"911.60"},
        {"page":9,"code":"2.5.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"1,128.64"},
        {"page":9,"code":"2.5.4","description":"Depth 4.5m–6m","unit":"m³","price":"1,612.35"},
        {"page":9,"code":"2.5.5","description":"Depth 6m–7.5m","unit":"m³","price":"2,303.36"},
        {"page":9,"code":"2.5.6","description":"Depth 7.5m–9m","unit":"m³","price":"3,290.51"},
        {"page":9,"code":"2.5.7","description":"Depth 9m–10.5m","unit":"m³","price":"4,700.72"},
        {"page":9,"code":"2.6.1","description":"Bulk excavation in hard rock — depth ≤1.50m","unit":"m³","price":"1,368.24"},
        {"page":9,"code":"2.6.2","description":"Depth 1.5m–3m","unit":"m³","price":"1,706.63"},
        {"page":9,"code":"2.6.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"2,051.20"},
        {"page":10,"code":"2.6.4","description":"Depth 4.5m–6.0m","unit":"m³","price":"2,792.32"},
        {"page":10,"code":"2.6.5","description":"Depth 6.0m–7.5m","unit":"m³","price":"3,490.40"},
        {"page":10,"code":"2.6.6","description":"Depth 7.5m–9.0m","unit":"m³","price":"4,363.00"},
        {"page":10,"code":"2.6.7","description":"Depth 9.0m–10.5m","unit":"m³","price":"5,132.95"},
        {"page":10,"code":"2.7.1","description":"Pit excavation in hard rock — depth ≤1.50m","unit":"m³","price":"1,659.11"},
        {"page":10,"code":"2.7.2","description":"Depth 1.5m–3m","unit":"m³","price":"2,051.09"},
        {"page":10,"code":"2.7.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"2,666.42"},
        {"page":10,"code":"2.7.4","description":"Depth 4.5m–6m","unit":"m³","price":"3,627.78"},
        {"page":10,"code":"2.7.5","description":"Depth 6.0m–7.5m","unit":"m³","price":"5,182.55"},
        {"page":10,"code":"2.7.6","description":"Depth 7.5m–9m","unit":"m³","price":"7,403.64"},
        {"page":10,"code":"2.7.7","description":"Depth 9m–10.5m","unit":"m³","price":"10,576.63"},
        {"page":10,"code":"2.8.1","description":"Back fill selected excavated mats. from the site (mechanized)","unit":"m³","price":"982.68"},
        {"page":10,"code":"2.8.2","description":"Back fill from outside (Upto 20km) (Mechanized)","unit":"m³","price":"3,066.43"},
        {"page":10,"code":"2.8.3","description":"Back fill from outside (Upto 15km) (Mechanized)","unit":"m³","price":"2,540.36"},
        {"page":10,"code":"2.8.4","description":"Back fill from outside (Upto 10km) (Mechanized)","unit":"m³","price":"2,180.98"},
        {"page":10,"code":"2.8.5","description":"Back fill from outside (Upto 5km) (Mechanized)","unit":"m³","price":"1,821.61"},
        {"page":10,"code":"2.8.6","description":"25cm. thick basaltic hard core. (Mechanized)","unit":"m²","price":"1,099.89"}
      ]
    },
    {
      "id": "3",
      "title": "EXCAVATION AND EARTH WORK — MANUAL",
      "items": [
        {"page":10,"code":"3.0","description":"20cm. Clearing on wet & black soil.","unit":"m²","price":"98.79"},
        {"page":10,"code":"3.1.1","description":"Bulk excav. in loose and dry soil — depth ≤1500mm","unit":"m³","price":"718.65"},
        {"page":10,"code":"3.1.2","description":"Depth 1500mm–3000mm","unit":"m³","price":"829.21"},
        {"page":10,"code":"3.1.3","description":"Depth 3000mm–4500mm","unit":"m³","price":"937.37"},
        {"page":10,"code":"3.2.1","description":"Bulk excav. in soft rock — depth ≤1.5m","unit":"m³","price":"1,437.86"},
        {"page":10,"code":"3.2.2","description":"Depth 1.5m–3m","unit":"m³","price":"1,617.59"},
        {"page":10,"code":"3.2.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"1,990.89"},
        {"page":11,"code":"3.3.1","description":"Bulk excav. in hard rock — depth ≤1.50m","unit":"m³","price":"2,588.15"},
        {"page":11,"code":"3.3.2","description":"Depth 1.5m–3m","unit":"m³","price":"3,041.68"},
        {"page":11,"code":"3.3.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"4,679.51"},
        {"page":11,"code":"3.4.1","description":"Pit & Trench excav. in loose and dry soil — depth ≤1500cm","unit":"m³","price":"798.50"},
        {"page":11,"code":"3.4.2","description":"Depth 1500cm–3000mm","unit":"m³","price":"979.98"},
        {"page":11,"code":"3.4.3","description":"Depth 3000cm–4500mm","unit":"m³","price":"1,347.47"},
        {"page":11,"code":"3.5.1","description":"Pit & Trench excav. in soft rock — depth ≤1.5m","unit":"m³","price":"1,725.43"},
        {"page":11,"code":"3.5.2","description":"Depth 1.5m–3m","unit":"m³","price":"2,156.79"},
        {"page":11,"code":"3.5.3","description":"Depth 3.0m–4.5m","unit":"m³","price":"2,588.15"},
        {"page":11,"code":"3.6.1","description":"Pit Excavation in hard rock — depth ≤1.5m","unit":"m³","price":"2,875.72"},
        {"page":11,"code":"3.6.2","description":"Depth 1.5m–3m","unit":"m³","price":"3,311.63"},
        {"page":11,"code":"3.6.3","description":"Depth 3m–4.5m","unit":"m³","price":"5,793.68"},
        {"page":11,"code":"3.7.1","description":"Trench Excavation in hard rock — depth ≤1.5m","unit":"m³","price":"3,318.14"},
        {"page":11,"code":"3.7.2","description":"Depth 1.5m–3m","unit":"m³","price":"4,462.33"},
        {"page":11,"code":"3.7.3","description":"Depth 3m–4.5m","unit":"m³","price":"7,612.21"},
        {"page":11,"code":"3.8.1","description":"Back fill selected excavated mats. from the site. (Manually)","unit":"m³","price":"854.51"},
        {"page":11,"code":"3.8.2","description":"Back fill from outside site (Upto 20km) (Manually)","unit":"m³","price":"3,050.24"},
        {"page":11,"code":"3.8.3","description":"Back fill from outside site (Upto 15km) (Manually)","unit":"m³","price":"2,524.17"},
        {"page":11,"code":"3.8.4","description":"Back fill from outside site (Upto 10km) (Manually)","unit":"m³","price":"2,164.79"},
        {"page":11,"code":"3.8.5","description":"Back fill from outside site (Upto 5km) (Manually)","unit":"m³","price":"1,805.42"},
        {"page":11,"code":"3.8.6","description":"Load and Cart away surplus excavated materials to 5km","unit":"m³","price":"589.84"},
        {"page":11,"code":"3.8.7","description":"Load and Cart away surplus excavated materials to 10km","unit":"m³","price":"625.59"},
        {"page":11,"code":"3.8.8","description":"Load and Cart away surplus excavated materials to 15km","unit":"m³","price":"730.88"},
        {"page":11,"code":"3.8.9","description":"Load and Cart away surplus excavated materials to 20km","unit":"m³","price":"872.56"},
        {"page":11,"code":"3.8.10","description":"25cm. thick basaltic hard core.(basaltic stone) (Manually)","unit":"m³","price":"1,034.09"},
        {"page":11,"code":"3.8.11","description":"Supply, Spread & Compact Red Ash.","unit":"m³","price":"3,955.19"}
      ]
    },
    {
      "id": "4",
      "title": "CONCRETE WORK",
      "items": [
        {"page":12,"code":"a","description":"C-7 Lean Concrete (Hand mix)","unit":"m²","price":"779.95"},
        {"page":12,"code":"b","description":"C-5 Lean Concrete (Hand mix)","unit":"m²","price":"741.10"},
        {"page":12,"code":"c","description":"C-15 10cm thick mass concrete pavement (include hard core & 7cm selected material)","unit":"m²","price":"3,539.10"},
        {"page":12,"code":"d","description":"Mortar production (1:3)","unit":"m³","price":"16,212.93"},
        {"page":12,"code":"e","description":"Light Weight Concrete 1:2:5","unit":"m³","price":"16,333.02"},
        {"page":12,"code":"f","description":"10cm Thick C-15 mass Concrete","unit":"m²","price":"1,655.59"},
        {"page":12,"code":"g","description":"Supply & Apply polymer modified Semi elastic cementitious coating or equivalent water proofing","unit":"m²","price":"842.11"},
        {"page":12,"code":"h","description":"Supply & Apply 4mm thick approved quality water proof membrane","unit":"m²","price":"2,173.91"},
        {"page":12,"code":"i","description":"Supply & Apply ACRYLIC approved quality water proof.","unit":"m²","price":"1,391.30"},
        {"page":12,"code":"j","description":"10mm thick stayroom expansion joint between ground floor slab & beam.","unit":"ml","price":"247.80"},
        {"page":12,"code":"k","description":"20mm thick stayroom expansion joint between ground floor slab & beam.","unit":"ml","price":"343.36"},
        {"page":12,"code":"l","description":"GRP Water Tanker with all fitting accessories","unit":"m³","price":"70,000.00"},
        {"page":12,"code":"4.1.1","description":"C-15 Concrete (Mechanical Mix) 1:2:4 with admixture","unit":"m³","price":"18,101.92"},
        {"page":12,"code":"4.1.2","description":"C-15 Concrete (Mechanical Mix) 1:2:4 for Footing, Beam and slab","unit":"m³","price":"17,437.92"},
        {"page":12,"code":"4.1.3","description":"C-15 Concrete (Mechanical Mix) 1:2:4 for Column, shear wall","unit":"m³","price":"17,168.38"},
        {"page":12,"code":"4.2.1","description":"C-20 Concrete (Mechanical Mix) 1:2:3 with admixture","unit":"m³","price":"18,102.09"},
        {"page":12,"code":"4.2.2","description":"C-20 Concrete (Mechanical Mix) 1:2:3 for Footing, Beam and slab","unit":"m³","price":"17,438.09"},
        {"page":12,"code":"4.2.3","description":"C-20 Concrete (Mechanical Mix) 1:2:3 for Column, shear wall","unit":"m³","price":"18,050.38"},
        {"page":12,"code":"4.3.1","description":"C-25 Concrete (Mechanical Mix) 1:2:3 with admixture","unit":"m³","price":"19,880.42"},
        {"page":12,"code":"4.3.2","description":"C-25 Concrete (Mechanical Mix) 1:2:3 for Footing, Beam and slab","unit":"m³","price":"19,216.42"},
        {"page":12,"code":"4.3.3","description":"C-25 Concrete (Mechanical Mix) 1:2:3 for Column, shear wall","unit":"m³","price":"19,828.70"},
        {"page":12,"code":"4.3.4","description":"C-25 Concrete (Mechanical Mix) 1:2:3 for 10cm thick slab","unit":"m²","price":"1,921.64"},
        {"page":13,"code":"4.4.1","description":"C-30 Concrete (Mechanical Mix) 1:2:3 with admixture","unit":"m³","price":"20,888.42"},
        {"page":13,"code":"4.4.2","description":"C-30 Concrete (Mechanical Mix) 1:2:3 for Footing, Beam and slab","unit":"m³","price":"20,224.42"},
        {"page":13,"code":"4.4.3","description":"C-30 Concrete (Mechanical Mix) 1:2:3 for Column, shear wall","unit":"m³","price":"20,836.70"},
        {"page":13,"code":"4.5.1","description":"C-25 (Super) 1:2:3 with admixture","unit":"m³","price":"20,562.87"},
        {"page":13,"code":"4.5.2","description":"C-25 (Super) for Beam and slab","unit":"m³","price":"19,898.87"},
        {"page":13,"code":"4.5.3","description":"C-25 (Super) for Column, shear wall","unit":"m³","price":"20,600.21"},
        {"page":13,"code":"4.5.4","description":"C-25 (Super) for Stair case","unit":"m³","price":"21,101.17"},
        {"page":13,"code":"4.5.5","description":"C-25 (Super) for 15cm thick slab","unit":"m³","price":"2,882.46"},
        {"page":13,"code":"4.5.6","description":"C-25 (Super) for 18cm thick slab","unit":"m³","price":"3,458.96"},
        {"page":13,"code":"4.6.1","description":"C-30 (Super) 1:2:3 with admixture","unit":"m³","price":"21,570.87"},
        {"page":13,"code":"4.6.2","description":"C-30 (Super) for Beam and slab","unit":"m³","price":"20,906.87"},
        {"page":13,"code":"4.6.3","description":"C-30 (Super) for Column, shear wall","unit":"m³","price":"21,608.21"},
        {"page":13,"code":"4.6.4","description":"C-30 (Super) for Stair case","unit":"m³","price":"22,109.17"},
        {"page":13,"code":"4.7.1","description":"Ready-Mix C-25 (378 kg/m³) w/ water tight chemical + pump","unit":"m³","price":"21,955.23"},
        {"page":13,"code":"4.7.2","description":"Ready-Mix C-30 (420 kg/m³) w/ water tight chemical + pump","unit":"m³","price":"22,690.23"},
        {"page":13,"code":"4.7.4","description":"Ready-Mix C-40 (448 kg/m³) w/ water tight chemical + pump","unit":"m³","price":"23,845.23"},
        {"page":14,"code":"4.8.1","description":"Ready-Mix C-25 (378 kg/m³) w/ water tight chemical (no pump)","unit":"m³","price":"21,405.23"},
        {"page":14,"code":"4.8.2","description":"Ready-Mix C-30 (420 kg/m³) w/ water tight chemical (no pump)","unit":"m³","price":"22,140.23"},
        {"page":14,"code":"4.8.3","description":"Ready-Mix C-40 (504 kg/m³) w/ water tight chemical (no pump)","unit":"m³","price":"23,295.23"},
        {"page":14,"code":"4.9.1","description":"Wooden form work for Beam, Footing & Column — sub structure","unit":"m²","price":"1,190.21"},
        {"page":14,"code":"4.9.2","description":"Wooden form work for Super structure column, Floor beam & slab.","unit":"m²","price":"1,213.23"},
        {"page":14,"code":"4.9.3","description":"18mm thick Fair Faced Form work (high quality playwood) with crane.","unit":"m²","price":"1,746.99"},
        {"page":14,"code":"4.9.4","description":"Wooden scaffolding","unit":"m²","price":"118.00"}
      ]
    },
    {
      "id": "4.10",
      "title": "STEEL REINFORCEMENT",
      "items": [
        {"page":15,"code":"4.10.1","description":"Local Re-Bar Grade 75 — Dia. 6mm (Sub structure)","unit":"kg","price":"246.97"},
        {"page":15,"code":"4.10.2","description":"Local Re-Bar Grade 75 — Dia. 8mm (Sub structure)","unit":"kg","price":"242.06"},
        {"page":15,"code":"4.10.3","description":"Local Re-Bar Grade 75 — Dia. 10mm (Sub structure)","unit":"kg","price":"242.06"},
        {"page":15,"code":"4.10.4","description":"Local Re-Bar Grade 75 — Dia. 12mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.5","description":"Local Re-Bar Grade 75 — Dia. 14mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.6","description":"Local Re-Bar Grade 75 — Dia. 16mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.7","description":"Local Re-Bar Grade 75 — Dia. 20mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.8","description":"Local Re-Bar Grade 75 — Dia. 24mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.9","description":"Local Re-Bar Grade 75 — Dia. 32mm (Sub structure)","unit":"kg","price":"238.74"},
        {"page":15,"code":"4.10.10","description":"Local Re-Bar Grade 75 — Dia. 6mm (Super structure)","unit":"kg","price":"249.12"},
        {"page":15,"code":"4.10.11","description":"Local Re-Bar Grade 75 — Dia. 8mm (Super structure)","unit":"kg","price":"249.12"},
        {"page":15,"code":"4.10.12","description":"Local Re-Bar Grade 75 — Dia. 10mm (Super structure)","unit":"kg","price":"249.12"},
        {"page":15,"code":"4.10.13","description":"Local Re-Bar Grade 75 — Dia. 12mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.14","description":"Local Re-Bar Grade 75 — Dia. 14mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.15","description":"Local Re-Bar Grade 75 — Dia. 16mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.16","description":"Local Re-Bar Grade 75 — Dia. 20mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.17","description":"Local Re-Bar Grade 75 — Dia. 24mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.18","description":"Local Re-Bar Grade 75 — Dia. 32mm (Super structure)","unit":"kg","price":"241.72"},
        {"page":15,"code":"4.10.19","description":"Imported Re-Bar Grade 75 — Dia. 8mm (Sub structure)","unit":"kg","price":"252.12"},
        {"page":15,"code":"4.10.20","description":"Imported Re-Bar Grade 75 — Dia. 10mm (Sub structure)","unit":"kg","price":"252.12"},
        {"page":15,"code":"4.10.21","description":"Imported Re-Bar Grade 75 — Dia. 12mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.22","description":"Imported Re-Bar Grade 75 — Dia. 14mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.23","description":"Imported Re-Bar Grade 75 — Dia. 16mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.24","description":"Imported Re-Bar Grade 75 — Dia. 20mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.25","description":"Imported Re-Bar Grade 75 — Dia. 24mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.26","description":"Imported Re-Bar Grade 75 — Dia. 30mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.27","description":"Imported Re-Bar Grade 75 — Dia. 32mm (Sub structure)","unit":"kg","price":"243.89"},
        {"page":15,"code":"4.10.28","description":"Imported Re-Bar Grade 75 — Dia. 8mm (Super structure)","unit":"kg","price":"260.35"},
        {"page":15,"code":"4.10.29","description":"Imported Re-Bar Grade 75 — Dia. 10mm (Super structure)","unit":"kg","price":"260.35"},
        {"page":15,"code":"4.10.30","description":"Imported Re-Bar Grade 75 — Dia. 12mm (Super structure)","unit":"kg","price":"246.87"},
        {"page":15,"code":"4.10.31","description":"Imported Re-Bar Grade 75 — Dia. 14mm (Super structure)","unit":"kg","price":"246.87"},
        {"page":15,"code":"4.10.32","description":"Imported Re-Bar Grade 75 — Dia. 16mm (Super structure)","unit":"kg","price":"246.87"},
        {"page":15,"code":"4.10.33","description":"Imported Re-Bar Grade 75 — Dia. 20mm (Super structure)","unit":"kg","price":"246.87"},
        {"page":15,"code":"4.10.34","description":"Imported Re-Bar Grade 75 — Dia. 24mm (Super structure)","unit":"kg","price":"251.95"},
        {"page":15,"code":"4.10.35","description":"Imported Re-Bar Grade 75 — Dia. 30mm (Super structure)","unit":"kg","price":"246.87"},
        {"page":15,"code":"4.10.36","description":"Imported Re-Bar Grade 75 — Dia. 32mm (Super structure)","unit":"kg","price":"246.87"}
      ]
    },
    {
      "id": "5",
      "title": "MASONRY & BLOCK WORK",
      "items": [
        {"page":16,"code":"5.1.1","description":"40cm thick masonry foundation (A.G.L) Cement Mortar 1:3","unit":"m³","price":"9,291.87"},
        {"page":16,"code":"5.1.2","description":"50cm thick masonry foundation (A.G.L) Cement Mortar 1:3","unit":"m³","price":"9,179.03"},
        {"page":16,"code":"5.1.3","description":"60cm thick masonry foundation (B.G.L) Cement Mortar 1:3","unit":"m³","price":"9,095.12"},
        {"page":16,"code":"5.1.4","description":"40cm thick One Side Roughly Dressed Stone masonry (A.G.L)","unit":"m³","price":"10,086.38"},
        {"page":16,"code":"5.1.5","description":"50cm thick One Side Roughly Dressed Stone masonry (A.G.L)","unit":"m³","price":"9,950.26"},
        {"page":16,"code":"5.1.6","description":"60cm thick One Side Roughly Dressed Stone masonry (A.G.L)","unit":"m³","price":"9,851.75"},
        {"page":16,"code":"5.1.7","description":"50cm thick masonry foundation (B.G.L)","unit":"m³","price":"8,804.92"},
        {"page":16,"code":"5.1.8","description":"40cm thick masonry foundation (B.G.L)","unit":"m³","price":"9,222.41"},
        {"page":16,"code":"5.1.9","description":"400mm thick Finely dressed elevation wall Cement Mortar 1:3","unit":"m²","price":"3,955.61"},
        {"page":16,"code":"5.1.10","description":"500mm thick Finely dressed elevation wall Cement Mortar 1:3","unit":"m²","price":"5,549.60"},
        {"page":16,"code":"5.1.11","description":"10cm thick class-c HCB Wall Both Sides Left For Plastering","unit":"m²","price":"1,275.74"},
        {"page":16,"code":"5.1.12","description":"10cm thick class-c Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"1,436.53"},
        {"page":16,"code":"5.1.13","description":"15cm thick class-c HCB Wall Both Sides Left For Plastering","unit":"m²","price":"1,567.67"},
        {"page":16,"code":"5.1.14","description":"15cm thick class-c Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"1,687.10"},
        {"page":16,"code":"5.1.15","description":"20cm thick class-c HCB Wall Both Sides Left For Pointing","unit":"m²","price":"1,808.04"},
        {"page":16,"code":"5.1.16","description":"20cm thick class-c Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"1,963.31"},
        {"page":16,"code":"5.1.17","description":"10cm thick class-b HCB Wall Both Sides Left For Plastering","unit":"m²","price":"1,486.90"},
        {"page":16,"code":"5.1.18","description":"10cm thick class-b Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"1,728.30"},
        {"page":16,"code":"5.1.19","description":"15cm thick class-b HCB Wall Both Sides Left For Plastering","unit":"m²","price":"1,782.36"},
        {"page":16,"code":"5.1.21","description":"15cm thick class-b Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"2,244.25"},
        {"page":16,"code":"5.1.22","description":"20cm thick class-b HCB Wall Both Sides Left For Pointing","unit":"m²","price":"2,459.76"},
        {"page":16,"code":"5.1.23","description":"20cm thick class-b Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"2,917.44"},
        {"page":16,"code":"5.1.24","description":"10cm thick class-a HCB Wall Both Sides Left For Plastering","unit":"m²","price":"1,903.67"},
        {"page":16,"code":"5.1.25","description":"10cm thick class-a Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"2,367.29"},
        {"page":16,"code":"5.1.26","description":"15cm thick class-a HCB Wall Both Sides Left For Plastering","unit":"m²","price":"2,399.14"},
        {"page":16,"code":"5.1.27","description":"15cm thick class-a Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"3,038.49"},
        {"page":17,"code":"5.1.28","description":"20cm thick class-a HCB Wall Both Sides Left For Pointing","unit":"m²","price":"2,564.88"},
        {"page":17,"code":"5.1.29","description":"20cm thick class-a Solid CB Wall Both Sides Left For Plastering","unit":"m²","price":"3,689.88"},
        {"page":17,"code":"5.1.30","description":"40cm thick Dressed Stone Masonry Wall one side well dressed & the other plastered","unit":"m²","price":"7,580.80"},
        {"page":17,"code":"5.1.31","description":"250mm thick Double Brick Wall","unit":"m²","price":"5,272.11"},
        {"page":17,"code":"5.1.32","description":"120mm thick Single Brick Wall","unit":"m²","price":"2,744.51"},
        {"page":17,"code":"5.1.33","description":"Chika wall with all wood work /አንጨት ግድግዳ/","unit":"m²","price":"1,224.65"},
        {"page":17,"code":"5.1.34","description":"Eucalyptus wood wall with all wood work /አንጨት ግድግዳ/","unit":"m²","price":"756.45"},
        {"page":17,"code":"5.1.35","description":"2.5cm thick Timber wall with 10cm & 6cm dia. Eucalyptus and all wood work /የንጨ ጣውላ ግድግዳ/","unit":"m²","price":"1,633.75"},
        {"page":17,"code":"5.1.36","description":"G32 CIS with Eucalyptus /ላምጣር የሚሠራ ፍርፍር አንጨት ግድግዳ/","unit":"m²","price":"1,014.77"},
        {"page":17,"code":"5.1.37","description":"8mm thick Chipwood wall with Eucalyptus dia.10cm and 5x7cm shashemene batten","unit":"m²","price":"1,571.79"},
        {"page":17,"code":"5.1.38","description":"18mm thick Laminated MDF Wall with 5x7cm Shashemene batten wood work","unit":"m²","price":"2,650.00"},
        {"page":17,"code":"5.1.39","description":"18mm thick Laminated MDF Wall. Without batten","unit":"m²","price":"1,756.93"},
        {"page":17,"code":"5.1.40","description":"20x20mm and 1.5mm thick Wire mesh wall Welded on the frame","unit":"m²","price":"1,093.69"},
        {"page":17,"code":"5.1.41","description":"Barbed wire fence with 40x40x3mm Angle Iron Frame","unit":"m²","price":"1,314.44"},
        {"page":17,"code":"5.1.42","description":"Gabion — Supply & lay class A galvanized 800*1000*2.5cm hexagonal Mesh rock size 100–250 for 1m³ (የጋቢዮን ተራራ ግድግዳ)","unit":"m³","price":"6,959.18"},
        {"page":17,"code":"5.1.45","description":"Gabion — Supply & lay class A galvanized 800*1000*2.5cm hexagonal Mesh rock size 100–250 for 2m³ (የጋቢዮን ግድግዳ)","unit":"m³","price":"7,159.18"}
      ]
    },
    {
      "id": "6",
      "title": "ROOF WORK / SHEAR WALL",
      "items": [
        {"page":17,"code":"6.1.1","description":"C-25 Concrete (Mechanical Mix) 1:2:3 for Column, shear wall (river side)","unit":"m³","price":"20,000.34"},
        {"page":17,"code":"7.1.1","description":"C-30 Concrete (Mechanical Mix) 1:2:3 for Column, shear wall","unit":"m³","price":"21,027.84"},
        {"page":17,"code":"7.1.2","description":"18mm thick Fair Faced Form work (high quality playwood) with crane.","unit":"m²","price":"2,076.99"},
        {"page":18,"code":"6.1.1.1","description":"Galvanized EGA 300 roof cover — 0.30 mm thick","unit":"m²","price":"1,596.25"},
        {"page":18,"code":"6.1.1.2","description":"Galvanized EGA 300 roof cover — 0.35 mm thick","unit":"m²","price":"1,785.51"},
        {"page":18,"code":"6.1.1.3","description":"Galvanized EGA 300 roof cover — 0.40 mm thick","unit":"m²","price":"1,958.45"},
        {"page":18,"code":"6.1.1.4","description":"Galvanized EGA 300 roof cover — 0.50 mm thick","unit":"m²","price":"2,135.55"},
        {"page":18,"code":"6.1.1.5","description":"Galvanized EGA 300 roof cover — 0.60 mm thick","unit":"m²","price":"2,385.35"},
        {"page":18,"code":"6.1.1.6","description":"Galvanized EGA 300 roof cover — 0.70 mm thick","unit":"m²","price":"2,632.49"},
        {"page":18,"code":"6.1.1.7","description":"Galvanized EGA 300 roof cover — 0.80 mm thick","unit":"m²","price":"2,863.96"},
        {"page":18,"code":"6.1.1.8","description":"Galvanized EGA 300 roof cover — 1.00 mm thick","unit":"m²","price":"3,107.64"},
        {"page":18,"code":"6.1.2.1","description":"Galvanized EGA 400 roof cover — 0.30 mm thick","unit":"m²","price":"1,780.73"},
        {"page":18,"code":"6.1.2.2","description":"Galvanized EGA 400 roof cover — 0.35 mm thick","unit":"m²","price":"1,987.74"},
        {"page":18,"code":"6.1.2.3","description":"Galvanized EGA 400 roof cover — 0.40 mm thick","unit":"m²","price":"2,217.70"},
        {"page":18,"code":"6.1.2.4","description":"Galvanized EGA 400 roof cover — 0.50 mm thick","unit":"m²","price":"2,430.31"},
        {"page":18,"code":"6.1.2.5","description":"Galvanized EGA 400 roof cover — 0.60 mm thick","unit":"m²","price":"2,623.64"},
        {"page":18,"code":"6.1.2.6","description":"Galvanized EGA 400 roof cover — 0.70 mm thick","unit":"m²","price":"2,847.72"},
        {"page":18,"code":"6.1.2.7","description":"Galvanized EGA 400 roof cover — 0.80 mm thick","unit":"m²","price":"3,071.13"},
        {"page":18,"code":"6.1.2.8","description":"Galvanized EGA 400 roof cover — 1.00 mm thick","unit":"m²","price":"3,264.50"},
        {"page":18,"code":"6.1.3.1","description":"Galvanized EGA 500 roof cover — 0.30 mm thick","unit":"m²","price":"1,846.07"},
        {"page":18,"code":"6.1.3.2","description":"Galvanized EGA 500 roof cover — 0.35 mm thick","unit":"m²","price":"2,116.70"},
        {"page":18,"code":"6.1.3.3","description":"Galvanized EGA 500 roof cover — 0.40 mm thick","unit":"m²","price":"2,300.15"},
        {"page":18,"code":"6.1.3.4","description":"Galvanized EGA 500 roof cover — 0.50 mm thick","unit":"m²","price":"2,523.61"},
        {"page":18,"code":"6.1.3.5","description":"Galvanized EGA 500 roof cover — 0.60 mm thick","unit":"m²","price":"2,731.78"},
        {"page":18,"code":"6.1.3.6","description":"Galvanized EGA 500 roof cover — 0.70 mm thick","unit":"m²","price":"2,935.84"},
        {"page":18,"code":"6.1.3.7","description":"Galvanized EGA 500 roof cover — 0.80 mm thick","unit":"m²","price":"3,213.53"},
        {"page":18,"code":"6.1.3.8","description":"Galvanized EGA 500 roof cover — 1.00 mm thick","unit":"m²","price":"3,488.80"},
        {"page":18,"code":"6.1.4.1","description":"Galvanized EGA 600 roof cover — 0.30 mm thick","unit":"m²","price":"1,915.24"},
        {"page":18,"code":"6.1.4.2","description":"Galvanized EGA 600 roof cover — 0.35 mm thick","unit":"m²","price":"2,110.72"},
        {"page":18,"code":"6.1.4.3","description":"Galvanized EGA 600 roof cover — 0.40 mm thick","unit":"m²","price":"2,313.65"},
        {"page":18,"code":"6.1.4.4","description":"Galvanized EGA 600 roof cover — 0.50 mm thick","unit":"m²","price":"2,543.02"},
        {"page":18,"code":"6.1.4.5","description":"Galvanized EGA 600 roof cover — 0.60 mm thick","unit":"m²","price":"2,756.42"},
        {"page":18,"code":"6.1.4.6","description":"Galvanized EGA 600 roof cover — 0.70 mm thick","unit":"m²","price":"2,977.88"},
        {"page":18,"code":"6.1.4.7","description":"Galvanized EGA 600 roof cover — 0.80 mm thick","unit":"m²","price":"3,263.52"},
        {"page":18,"code":"6.1.4.8","description":"Galvanized EGA 600 roof cover — 1.00 mm thick","unit":"m²","price":"3,584.72"},
        {"page":18,"code":"6.1.5.1","description":"Galvanized EGA 700 roof cover — 0.30 mm thick","unit":"m²","price":"1,997.42"},
        {"page":18,"code":"6.1.5.2","description":"Galvanized EGA 700 roof cover — 0.35 mm thick","unit":"m²","price":"2,153.62"},
        {"page":18,"code":"6.1.5.3","description":"Galvanized EGA 700 roof cover — 0.40 mm thick","unit":"m²","price":"2,329.62"},
        {"page":18,"code":"6.1.5.4","description":"Galvanized EGA 700 roof cover — 0.50 mm thick","unit":"m²","price":"2,631.07"},
        {"page":18,"code":"6.1.5.5","description":"Galvanized EGA 700 roof cover — 0.60 mm thick","unit":"m²","price":"2,765.22"},
        {"page":18,"code":"6.1.5.6","description":"Galvanized EGA 700 roof cover — 0.70 mm thick","unit":"m²","price":"2,988.52"},
        {"page":18,"code":"6.1.5.7","description":"Galvanized EGA 700 roof cover — 0.80 mm thick","unit":"m²","price":"3,289.92"},
        {"page":18,"code":"6.1.5.8","description":"Galvanized EGA 700 roof cover — 1.00 mm thick","unit":"m²","price":"3,601.22"},
        {"page":18,"code":"6.1.6","description":"EGA 0.4mm thick (G-28) Coated roof cover","unit":"m²","price":"1,929.94"},
        {"page":18,"code":"6.1.10","description":"EGA 0.4mm thick (G-28) Coated For Wall","unit":"m²","price":"1,754.90"},
        {"page":18,"code":"6.1.11","description":"EGA 0.4mm thick (G-28) Coated For Wall with 10cm Dia. Vertical member & 6cm Dia. Horizontal members","unit":"m²","price":"2,022.07"},
        {"page":19,"code":"6.3.1","description":"Down pipe — G-28 devt. Length 33 cm","unit":"ml","price":"854.07"},
        {"page":19,"code":"6.3.2","description":"Down pipe — G-30 devt. Length 33 cm","unit":"ml","price":"854.07"},
        {"page":19,"code":"6.3.3","description":"Down pipe — G-28 devt. Length 40 cm","unit":"ml","price":"1,012.90"},
        {"page":19,"code":"6.3.4","description":"Down pipe — G-30 devt. Length 40 cm","unit":"ml","price":"857.70"},
        {"page":19,"code":"6.3.5","description":"Down pipe — G-28 devt. Length 50 cm","unit":"ml","price":"1,077.46"},
        {"page":19,"code":"6.3.6","description":"Down pipe — G-30 devt. Length 50 cm","unit":"ml","price":"1,044.66"},
        {"page":19,"code":"6.4.1","description":"PVC down pipe Dia.75mm","unit":"ml","price":"469.41"},
        {"page":19,"code":"6.4.2","description":"PVC down pipe Dia.110mm","unit":"ml","price":"567.84"},
        {"page":19,"code":"6.4.3","description":"PVC down pipe Dia.160mm","unit":"ml","price":"1,019.08"},
        {"page":19,"code":"6.6.1","description":"Galvanized steel flashing — G-30 dev length 50cm","unit":"ml","price":"1,082.14"},
        {"page":19,"code":"6.6.2","description":"Galvanized steel flashing — G-30 dev length 67cm","unit":"ml","price":"1,192.91"},
        {"page":19,"code":"6.6.3","description":"Galvanized steel flashing — G-30 dev length 100cm","unit":"ml","price":"1,497.41"},
        {"page":19,"code":"6.6.4","description":"Galvanized steel flashing — G-28 dev length 50cm","unit":"ml","price":"1,264.84"},
        {"page":19,"code":"6.6.5","description":"Galvanized steel flashing — G-28 dev length 67cm","unit":"ml","price":"1,472.74"},
        {"page":19,"code":"6.6.6","description":"Galvanized steel flashing — G-28 dev length 100cm","unit":"ml","price":"1,590.48"},
        {"page":19,"code":"6.7.1","description":"Galvanized steel copping — G-28 dev length 25cm","unit":"ml","price":"620.78"},
        {"page":19,"code":"6.7.2","description":"Galvanized steel copping — G-30 dev length 25cm","unit":"ml","price":"615.68"},
        {"page":19,"code":"6.7.3","description":"Galvanized steel copping — G-28 dev length 33cm","unit":"ml","price":"856.77"},
        {"page":19,"code":"6.7.4","description":"Galvanized steel copping — G-30 dev length 33cm","unit":"ml","price":"616.70"},
        {"page":19,"code":"6.7.5","description":"Galvanized steel copping — G-28 dev length 50cm","unit":"ml","price":"865.58"},
        {"page":19,"code":"6.7.6","description":"Galvanized steel copping — G-30 dev length 50cm","unit":"ml","price":"824.78"},
        {"page":19,"code":"6.8.1","description":"Galvanized steel roof ridge — G-28 dev length 33cm","unit":"ml","price":"759.81"},
        {"page":19,"code":"6.8.2","description":"Galvanized steel roof ridge — G-30 dev length 33cm","unit":"ml","price":"657.81"},
        {"page":19,"code":"6.8.3","description":"Galvanized steel roof ridge — G-28 dev length 50cm","unit":"ml","price":"889.35"},
        {"page":19,"code":"6.8.4","description":"Galvanized steel roof ridge — G-30 dev length 50cm","unit":"ml","price":"792.45"},
        {"page":19,"code":"6.9.1","description":"G28 C1S Roofing (Without Truss & Purlin)","unit":"m²","price":"1,370.13"},
        {"page":19,"code":"6.9.2","description":"G30 C1S Roofing (Without Truss & Purlin)","unit":"m²","price":"1,229.59"},
        {"page":19,"code":"6.9.3","description":"G32 C1S Roofing (Without Truss & Purlin)","unit":"m²","price":"997.16"},
        {"page":19,"code":"6.9.4","description":"G35 C1S Roofing (Without Truss & Purlin)","unit":"m²","price":"833.46"},
        {"page":19,"code":"6.9.5","description":"Aspesto roof cover with all necessary works.","unit":"m²","price":"847.68"},
        {"page":19,"code":"6.9.6","description":"Euro tile roof cover with all necessary works.","unit":"m²","price":"878.88"},
        {"page":19,"code":"6.9.7","description":"Grass roof cover with all necessary works.","unit":"m²","price":"825.13"},
        {"page":19,"code":"6.9.8","description":"2mm thick Transparent fiber Roof cover (Corrugated Type)","unit":"m²","price":"1,257.17"},
        {"page":19,"code":"6.9.9","description":"G-32 CIS roof with Shashemene Zigba purline (4x5cm)","unit":"m²","price":"1,412.24"},
        {"page":19,"code":"6.9.10","description":"Tsid Timber cladding 1cm for decorating roof purlin","unit":"m²","price":"1,453.56"},
        {"page":19,"code":"6.9.11","description":"Light Weight Concrete 1:2:5 for roof","unit":"m³","price":"15,754.06"}
      ]
    },
    {
      "id": "7",
      "title": "CARPENTRY AND JOINERY",
      "items": [
        {"page":20,"code":"7.1","description":"Supply & fix Abujedy ceiling with 5x4cm Shashemene batten","unit":"m²","price":"1,012.99"},
        {"page":20,"code":"7.2","description":"Supply & fix Fyzit ceiling 5x4cm Shashemene batten","unit":"m²","price":"1,957.97"},
        {"page":20,"code":"7.3","description":"Supply & fix Parquet ceiling 5x4cm Shashemene batten","unit":"m²","price":"3,775.20"},
        {"page":20,"code":"7.4","description":"Supply & fix 1cm thick Timber ceiling /የንጨ ንጣፍ/ with 5x4cm Shashemene batten","unit":"m²","price":"1,896.16"},
        {"page":20,"code":"7.5","description":"Supply & fix Purline ceiling 5x4cm Shashemene batten","unit":"m²","price":"1,386.58"},
        {"page":20,"code":"7.6","description":"Supply & fix Playwood ceiling /Comperesato/ 5x4cm Shashemene batten","unit":"m²","price":"2,278.08"},
        {"page":20,"code":"7.7","description":"Supply & fix Rush ceiling /የሸገ ንጣፍ/ Comperesato 5x4cm Shashemene batten","unit":"m²","price":"1,073.08"},
        {"page":20,"code":"7.8","description":"Supply & fix Ceiling made with plastic sack /የፕላስቲክ ንጣፍ/ 5x4cm Shashemene batten","unit":"m²","price":"981.79"},
        {"page":20,"code":"7.9","description":"Supply & fix Ceiling made with sack /የጎን/ 5x4cm Shashemene batten","unit":"m²","price":"739.49"},
        {"page":20,"code":"7.10","description":"Supply & fix 8mm thick chipwood Ceiling with 5x4cm Shashemene batten","unit":"m²","price":"2,466.87"},
        {"page":20,"code":"7.11","description":"Supply & fix Armstrong acoustical ceiling with Suspender and all accessories","unit":"m²","price":"3,800.00"},
        {"page":20,"code":"7.12","description":"Supply & fix Mineral fiber acoustic ceiling with all accessories","unit":"m²","price":"3,300.00"},
        {"page":20,"code":"7.13","description":"Supply & fix local gypsum ceiling without batten","unit":"m²","price":"950.00"},
        {"page":20,"code":"7.14","description":"Supply & fix PVC ceiling (laminated/imported) with 5x4cm Shashemene batten & corner list","unit":"m²","price":"2,693.80"},
        {"page":20,"code":"7.17","description":"Supply & fix 25 cm. Wide Kerrero Facia Board","unit":"ml","price":"1,002.50"},
        {"page":20,"code":"7.18","description":"Supply & fix 30 cm. Wide Kerrero Facia Board","unit":"ml","price":"1,167.50"},
        {"page":20,"code":"7.19","description":"10-12 cm. dia. Vertical Chords Eucalyptus Wood.","unit":"ml","price":"206.01"},
        {"page":20,"code":"7.20","description":"8-10 cm. dia. Vertical & Diagonal member Eucalyptus Wood.","unit":"ml","price":"191.85"},
        {"page":20,"code":"7.21","description":"Diam. 6 cm thick eucalyptus purlin","unit":"ml","price":"130.89"},
        {"page":20,"code":"7.22","description":"50 X 70mm. Tid (Shashemene) Roof Purlin","unit":"ml","price":"353.40"},
        {"page":20,"code":"7.23","description":"Supply & fix 40mm thick Mahogany plywood smooth finish flush wooden door /የምርጥ ንጣፍ በር/ with all necessary accessories","unit":"m²","price":"16,400.00"},
        {"page":20,"code":"7.24","description":"Supply & fix 40mm thick Smooth MDF board made Imported wooden door (best quality) with all necessary accessories","unit":"m²","price":"19,500.00"},
        {"page":20,"code":"7.25","description":"Supply & fix 40mm thick Antique MDF board wooden door with all necessary accessories","unit":"m²","price":"19,800.00"},
        {"page":20,"code":"7.26","description":"Supply & fix 40mm thick Solid wooden door (best quality standard) with all necessary accessories","unit":"m²","price":"23,600.00"},
        {"page":20,"code":"7.27","description":"Supply & fix best quality PVC Door — weather resistant, energy efficient, stylish design for interior/exterior. Unit price includes cylindrical door lock and all necessary accessories","unit":"m²","price":"12,980.00"},
        {"page":20,"code":"7.28","description":"Supply & fix 12mm thickness HPL door with stainless steel frame. Includes all accessories and related works","unit":"m²","price":"18,150.00"},
        {"page":20,"code":"7.29","description":"Supply & fix 12mm thickness HPL partition with stainless steel frame. Includes all accessories and related works","unit":"m²","price":"16,500.00"},
        {"page":20,"code":"7.30","description":"1cm thick timber door with 5cm wide fascia board /የስድስት ተጣጣሪ ጣውላ በር ከሁለት ጎን የስድስት ሰንቲ ሚትር ጣውላ/","unit":"m²","price":"2,727.07"},
        {"page":20,"code":"7.31","description":"3cm thick timber door /የሶስት ሰንቲ ሚትር ውፍረት ጣውላ/","unit":"m²","price":"2,692.32"},
        {"page":20,"code":"7.32","description":"1cm thick timber window /የስድስት ሰንቲ ሚትር ውፍረት ከሁለት ጎን የስድስት ሰንቲ ሚትር ጣውላ/","unit":"m²","price":"1,838.86"},
        {"page":20,"code":"7.33","description":"3cm thick timber window /የሶስት ሰንቲ ሚትር ውፍረት ጣውላ/","unit":"m²","price":"1,838.86"},
        {"page":20,"code":"7.34","description":"3cm thick timber window with 4mm thick glass /የሶስት ሰንቲ ሚትር ውፍረት ጣውላ/","unit":"m²","price":"4,046.11"},
        {"page":20,"code":"7.35","description":"G-32 CIS door with all wood work /የፍርፍር በር ከሁሉም ጎን/","unit":"m²","price":"1,418.90"},
        {"page":20,"code":"7.36","description":"G-32 CIS window with all wood work /የፍርፍር መስኮት ከሁሉም ጎን/","unit":"m²","price":"1,418.90"},
        {"page":20,"code":"7.37","description":"1cm Timber /Tsid/ door /የርዕ ጣውላ በር/","unit":"m²","price":"1,665.61"},
        {"page":20,"code":"7.38","description":"1cm Timber /Tsid/ window /የርዕ ጣውላ መስኮት/","unit":"m²","price":"1,701.61"}
      ]
    },
    {
      "id": "8",
      "title": "METAL WORK",
      "items": [
        {"page":21,"code":"8.1","description":"Fully metal doors of 38mm LTZ without grill (1.5mm thick)","unit":"m²","price":"5,621.06"},
        {"page":21,"code":"8.2","description":"Partially glazed metal doors of 38LTZ without grill","unit":"m²","price":"5,468.78"},
        {"page":21,"code":"8.3","description":"Partially glazed metal doors of 38mm LTZ with grill (1.5mm thick)","unit":"m²","price":"5,806.19"},
        {"page":21,"code":"8.4","description":"Metal Windows of 38LTZ without grill (1.5mm thick)","unit":"m²","price":"4,829.42"},
        {"page":21,"code":"8.5","description":"Metal Windows of 38LTZ (1.5mm thick) with grill","unit":"m²","price":"6,643.94"},
        {"page":21,"code":"8.6","description":"Double leaf metal doors of 38mmLTZ without grill (1.5mm thick)","unit":"m²","price":"5,457.94"},
        {"page":21,"code":"8.7","description":"Double leaf metal doors of 38mmLTZ with grill (1.5mm thick)","unit":"m²","price":"6,017.24"},
        {"page":21,"code":"8.8","description":"Fully metal doors of 28mm LTZ without grill (1.2mm thick)","unit":"m²","price":"5,230.06"},
        {"page":21,"code":"8.9","description":"Partially glazed metal doors of 28mm LTZ without grill (1.2mm thick)","unit":"m²","price":"4,489.73"},
        {"page":21,"code":"8.10","description":"Partially glazed metal doors of 28mm LTZ with grill (1.2mm thick)","unit":"m²","price":"5,040.31"},
        {"page":21,"code":"8.11","description":"Metal Windows of 28LTZ without grill (1.2mm thick)","unit":"m²","price":"3,787.65"},
        {"page":21,"code":"8.12","description":"Metal Windows of 28LTZ with grill (1.2mm thick)","unit":"m²","price":"4,592.82"},
        {"page":21,"code":"8.13","description":"Double leaf metal doors of 28mmLTZ without grill (1.2mm thick)","unit":"m²","price":"4,502.54"},
        {"page":21,"code":"8.14","description":"Double leaf metal doors of 28mmLTZ with grill (1.2mm thick)","unit":"m²","price":"5,168.93"},
        {"page":21,"code":"8.16","description":"Sliding door & window. Includes Angle Iron 40X40X3mm Bottom rail & RHS 50X50X2.5mm Top rail","unit":"m²","price":"4,364.78"},
        {"page":21,"code":"8.17","description":"Supply & fix Sheet metal partition wall (1mm thick Lamera) with RHS 30x30x2.5","unit":"m²","price":"4,292.95"},
        {"page":21,"code":"8.18","description":"Supply & fix Only 1mm thick Sheet metal (Lamera) partition wall","unit":"m²","price":"2,154.74"},
        {"page":21,"code":"8.19","description":"Supply & fix 6mm thick metal plate with all necessary accessories","unit":"m²","price":"11,700.00"},
        {"page":21,"code":"8.20","description":"Supply & fix 8mm thick metal plate with all necessary accessories","unit":"m²","price":"14,900.00"},
        {"page":21,"code":"8.21","description":"Supply & fix 10mm thick metal plate with all necessary accessories","unit":"m²","price":"16,900.00"},
        {"page":22,"code":"8.22","description":"Supply & fix 1.6mm thick Aluminium frame window with 6mm thick clear glazed with all necessary accessories","unit":"m²","price":"16,834.00"},
        {"page":22,"code":"8.23","description":"Supply & fix 1.6mm thick Aluminium frame window with 6mm thick double clear glazed with all necessary accessories","unit":"m²","price":"19,800.00"},
        {"page":22,"code":"8.24","description":"Supply & fix 1.6mm thick Aluminium framed window with 8mm thick clear glazed with all necessary accessories","unit":"m²","price":"18,517.00"},
        {"page":22,"code":"8.25","description":"Supply & fix 1.6mm thick Aluminium frame window with 8mm thick double clear glazed with all necessary accessories","unit":"m²","price":"22,425.00"},
        {"page":22,"code":"8.26","description":"Supply & fix Aluminium sun breaker (vertical sun breaker with 150*mm*150mm*1.4mm) with 1 meter C/C spacing all necessary accessories","unit":"m²","price":"10,925.00"},
        {"page":22,"code":"8.27","description":"Supply & fix 1.6mm thick Aluminium Curtain wall 6mm thick clear glass (External)","unit":"m²","price":"22,310.00"},
        {"page":22,"code":"8.28","description":"Supply & fix 1.6mm thick Aluminium Curtain wall 8mm thick clear glass (External)","unit":"m²","price":"24,035.00"},
        {"page":22,"code":"8.29","description":"Supply & fix 1.6mm Aluminium partition wall with 6mm thick frosted clear glass","unit":"m²","price":"16,128.00"},
        {"page":22,"code":"8.30","description":"Supply & fix 1.4mm Aluminium partition wall with 6mm thick frosted clear glass","unit":"m²","price":"14,916.00"},
        {"page":22,"code":"8.31","description":"Supply & fix 2mm Aluminium partition wall with 6mm thick frosted clear glass","unit":"m²","price":"16,430.00"},
        {"page":22,"code":"8.32","description":"Supply & fix 1.6mm thick Aluminium frame door with 6mm thick clear glass","unit":"m²","price":"18,300.00"},
        {"page":22,"code":"8.33","description":"Supply & fix 1.6mm thick Aluminium frame door with 4mm thick clear glass","unit":"m²","price":"15,760.00"},
        {"page":22,"code":"8.34","description":"Supply & fix 1.6mm thick Aluminium frame window with 4mm thick clear glass","unit":"m²","price":"15,625.00"},
        {"page":22,"code":"8.35","description":"Supply & fix 1.6mm thick Aluminium frame door with 5mm thick clear glass","unit":"m²","price":"16,750.00"},
        {"page":22,"code":"8.36","description":"Supply & fix 1.6mm thick Aluminium frame window with 5mm thick clear glass","unit":"m²","price":"16,228.00"},
        {"page":22,"code":"8.37","description":"Supply & fix 2mm thick Aluminium frame door with 8mm thick clear glass","unit":"m²","price":"19,240.00"},
        {"page":22,"code":"8.38","description":"Supply & fix 2mm thick aluminium profile window with 6mm thick tinted glass","unit":"m²","price":"18,550.00"},
        {"page":22,"code":"8.39","description":"Supply & fix 2mm thick aluminium profile Door with 6mm thick tinted glass","unit":"m²","price":"18,850.00"},
        {"page":22,"code":"8.40","description":"Supply & fix anodized aluminium framed sky light — 8mm VITS glass + aluminium 60*40 section, 600*800 spacing","unit":"m²","price":"26,100.00"},
        {"page":22,"code":"8.41","description":"Supply & fix 1.6mm thick Aluminium window Frames (frame only)","unit":"m²","price":"10,800.00"},
        {"page":22,"code":"8.42","description":"Supply & fix 1.6mm thick Aluminium Door Frames (frame only)","unit":"m²","price":"11,050.00"},
        {"page":22,"code":"8.43","description":"Supply & fix 2mm thick Aluminium window Frames (frame only)","unit":"m²","price":"11,300.00"},
        {"page":22,"code":"8.44","description":"Supply & fix 2mm thick Aluminium Door Frames (frame only)","unit":"m²","price":"11,550.00"},
        {"page":22,"code":"8.45","description":"Supply & fix Steel Roof Truss & Purlin with RHS — 3 coat antirust","unit":"kg","price":"314.40"},
        {"page":22,"code":"8.46","description":"Supply & fix Metal hand rail made of RHS, CHS and SHS — 3 coat antirust","unit":"kg","price":"297.10"},
        {"page":22,"code":"8.47","description":"Supply & fix Stainless steel hand rail made of RHS, CHS and SHS","unit":"kg","price":"1,400.00"},
        {"page":22,"code":"8.48","description":"Supply & fix different size and thickness Aluminum works","unit":"kg","price":"680.00"},
        {"page":22,"code":"8.49","description":"Supply & fix metal angle iron 30*30*3mm with all necessary accessories","unit":"ml","price":"489.48"},
        {"page":22,"code":"8.50","description":"Supply & fix metal angle iron 40*40*3mm with all necessary accessories","unit":"ml","price":"551.20"},
        {"page":22,"code":"8.51","description":"dia. 16 mm. deformed bars dev. Length 400mm (J-bolt)","unit":"Pcs","price":"222.53"},
        {"page":22,"code":"8.52","description":"dia. 12 mm. deformed bars dev. Length 100mm (J-bolt)","unit":"Pcs","price":"20.60"},
        {"page":22,"code":"8.53","description":"dia. 14 mm. deformed bars dev. Length 160mm (J-bolt)","unit":"Pcs","price":"67.11"},
        {"page":22,"code":"8.54","description":"dia. 20 mm. Anchor bolt dev. Length 400mm","unit":"Pcs","price":"417.61"},
        {"page":22,"code":"8.55","description":"Supply & fix Galvanized different size RHS Middle vertical post","unit":"kg","price":"380.00"},
        {"page":22,"code":"8.56","description":"Supply & fix Galvanized different size Connector plates to ground and top","unit":"kg","price":"415.00"}
      ]
    },
    {
      "id": "9",
      "title": "FINISHING WORKS",
      "items": [
        {"page":23,"code":"9.1.2","description":"3 Coats of cement plastering (1:3) — internal wall","unit":"m²","price":"913.61"},
        {"page":23,"code":"9.1.3","description":"3 Coats of cement plastering (1:3) — external wall","unit":"m²","price":"925.13"},
        {"page":23,"code":"9.1.4","description":"3 Coats of cement plastering to exposed beams and columns","unit":"m²","price":"978.42"},
        {"page":23,"code":"9.1.5","description":"3 Coats of cement plastering to Slab soffit beams soffit","unit":"m²","price":"1,103.95"},
        {"page":23,"code":"9.1.6","description":"2 Coats of cement plastering internal vertical surface","unit":"m²","price":"720.00"},
        {"page":23,"code":"9.1.7","description":"2 Coats of cement plastering External vertical surface","unit":"m²","price":"720.00"},
        {"page":23,"code":"9.1.8","description":"Cement wash vertical surface","unit":"m²","price":"309.22"},
        {"page":23,"code":"9.1.9","description":"2 Coats of cement plastering Exposed column and beam","unit":"m²","price":"721.92"},
        {"page":23,"code":"9.1.10","description":"2 Coats of cement plastering concrete soffit","unit":"m²","price":"876.09"},
        {"page":23,"code":"9.1.11","description":"Final Coat of cement Rendering","unit":"m²","price":"217.50"},
        {"page":23,"code":"9.1.12","description":"Final Coat of cement plastering vertical and exposed column and beam","unit":"m²","price":"199.52"},
        {"page":23,"code":"9.1.13","description":"Final Coat of cement plastering concrete soffit","unit":"m²","price":"269.14"},
        {"page":23,"code":"9.1.14","description":"Final Coat of Gypsum plastering Soffit","unit":"m²","price":"352.94"},
        {"page":23,"code":"9.1.15","description":"Final Coat of Gypsum plastering Vertical wall and Exposed column and beam","unit":"m²","price":"304.74"},
        {"page":23,"code":"9.1.16","description":"Final Coat of Gypsum plastering external Vertical wall and Exposed column and beam","unit":"m²","price":"283.32"},
        {"page":23,"code":"9.1.17","description":"Supply and apply high quality primer (time gypsum) plastering — HCB wall & concrete soffit smooth adhesion + final gypsum Plaster finish","unit":"m²","price":"1,011.54"},
        {"page":23,"code":"9.2.1","description":"Cement pointing to H.C.B. wall surface (1:3)","unit":"m²","price":"220.97"},
        {"page":23,"code":"9.2.2","description":"Cement pointing to Brick wall surface (1:3)","unit":"m²","price":"354.02"},
        {"page":23,"code":"9.2.3","description":"Cement pointing to stone masonry wall surface (1:3)","unit":"m²","price":"395.87"},
        {"page":23,"code":"9.3.1","description":"2mm thick PVC flooring with Adhesive glue","unit":"m²","price":"1,848.80"},
        {"page":23,"code":"9.3.2","description":"10cmx10cmx10cm Coole Stone","unit":"m²","price":"4,183.62"},
        {"page":23,"code":"9.3.3","description":"3cm Thick cement screed flooring","unit":"m²","price":"787.98"},
        {"page":23,"code":"9.3.4","description":"5cm Thick cement screed flooring","unit":"m²","price":"1,162.73"},
        {"page":23,"code":"9.3.5","description":"10 mm thick Ceramic floor tile with Adhesive powder (Local)","unit":"m²","price":"3,647.87"},
        {"page":23,"code":"9.3.6","description":"9 mm thick Ceramic floor tile with Adhesive powder (Local)","unit":"m²","price":"3,545.87"},
        {"page":23,"code":"9.3.7","description":"8mm thick Ceramic floor tile with Adhesive powder (Local)","unit":"m²","price":"2,982.66"},
        {"page":23,"code":"9.3.8","description":"8mm thick Porcelain floor tile with adhesive powder","unit":"m²","price":"4,774.07"},
        {"page":23,"code":"9.3.10","description":"9mm thick Porcelain floor tile with adhesive powder","unit":"m²","price":"5,217.55"},
        {"page":23,"code":"9.3.11","description":"10mm thick Porcelain floor tile adhesive powder","unit":"m²","price":"5,780.77"},
        {"page":23,"code":"9.3.12","description":"2mm thick Epoxy resins floor topping with one coat primer coating","unit":"m²","price":"3,000.00"},
        {"page":23,"code":"9.3.13","description":"3mm thick Epoxy resins floor topping with one coat primer coating","unit":"m²","price":"4,100.00"},
        {"page":23,"code":"9.3.14","description":"5mm thick Epoxy resins floor topping with one coat primer coating","unit":"m²","price":"5,500.00"},
        {"page":23,"code":"9.3.15","description":"2mm thick Epoxy resins floor topping with UV resistance","unit":"m²","price":"3,900.00"},
        {"page":23,"code":"9.3.16","description":"3mm thick Epoxy resins floor topping with UV resistance","unit":"m²","price":"5,000.00"},
        {"page":23,"code":"9.3.17","description":"5mm thick Epoxy resins floor topping with UV resistance","unit":"m²","price":"6,500.00"},
        {"page":23,"code":"9.3.18","description":"Terrazzo tile flooring 40cm x 40cm x 40mm thick for pedestrian with cement mortar bedding (1:3)","unit":"m²","price":"2,223.96"},
        {"page":23,"code":"9.3.19","description":"30mm thick Terrazzo tile flooring /የተራራ ወለል/ (1:3) (Local)","unit":"m²","price":"2,162.61"},
        {"page":23,"code":"9.3.20","description":"20mm thick high quality polished Terrazzo tile flooring (1:3) (Local)","unit":"m²","price":"2,095.35"},
        {"page":24,"code":"9.3.24","description":"1cm thick Granite flooring (1:3) (Local)","unit":"m²","price":"8,229.02"},
        {"page":24,"code":"9.3.25","description":"2cm thick Granite flooring (1:3) (Local)","unit":"m²","price":"8,529.02"},
        {"page":24,"code":"9.3.26","description":"3cm thick Granite flooring (1:3) (Local)","unit":"m²","price":"8,736.09"},
        {"page":24,"code":"9.3.27","description":"1cm thick Marble flooring (1:3) (Local)","unit":"m²","price":"7,145.01"},
        {"page":24,"code":"9.3.28","description":"2cm thick Marble flooring (1:3) (Local)","unit":"m²","price":"7,961.01"},
        {"page":24,"code":"9.3.29","description":"3cm thick Marble flooring (1:3) (Local)","unit":"m²","price":"7,925.51"},
        {"page":24,"code":"9.3.30","description":"Parquet (Tid) Flooring","unit":"m²","price":"3,519.62"},
        {"page":24,"code":"9.4.1","description":"6mm thick Ceramic wall tiles with adhesive powder (Local)","unit":"m²","price":"2,921.40"},
        {"page":24,"code":"9.4.2","description":"8mm thick Ceramic wall tiles with adhesive powder (Local)","unit":"m²","price":"3,494.71"},
        {"page":24,"code":"9.4.3","description":"Ceramic standard quality mosaic to external wall — includes adhesive powder bedding & white cement grouting","unit":"m²","price":"8,443.93"},
        {"page":24,"code":"9.4.4","description":"20mm thick Marble wall Cladding (Cement mortar 1:2) (Local)","unit":"m²","price":"9,949.08"},
        {"page":24,"code":"9.4.5","description":"20mm thick Granite wall Cladding (Cement mortar 1:2) (Local)","unit":"m²","price":"10,684.08"},
        {"page":24,"code":"9.4.6","description":"2mm PVC wall tile type cladding by Animal glue","unit":"m²","price":"1,422.02"},
        {"page":24,"code":"9.4.7","description":"Aluminium cladding 4mm thick (Silver) with Adhesive (without T Frame)","unit":"m²","price":"4,062.78"},
        {"page":24,"code":"9.4.8","description":"Aluminium cladding 4mm thick (golden) with Adhesive (without T Frame)","unit":"m²","price":"4,587.78"},
        {"page":24,"code":"9.4.9","description":"Aluminium cladding 4mm thick (Silver) with Adhesive (with T Frame)","unit":"m²","price":"8,153.36"},
        {"page":24,"code":"9.4.10","description":"Aluminium cladding 4mm thick (golden) with Adhesive (with T Frame)","unit":"m²","price":"8,703.36"},
        {"page":24,"code":"9.4.11","description":"Ambo stone cladding for wall","unit":"m²","price":"4,733.52"},
        {"page":24,"code":"9.4.12","description":"Ambo stone cladding for column & right angle structure","unit":"m²","price":"6,775.19"},
        {"page":24,"code":"9.5.1","description":"30mm Thick & 220mm width Marble window sill (1:3) on HCB","unit":"ml","price":"2,191.28"},
        {"page":24,"code":"9.5.2","description":"30mm Thick & 280mm width Marble window sill (1:3) on HCB","unit":"ml","price":"2,596.28"},
        {"page":24,"code":"9.5.3","description":"30mm Thick & 300mm width Marble window sill (1:3) on HCB","unit":"ml","price":"2,798.78"},
        {"page":24,"code":"9.5.4","description":"30mm Thick & 470mm width Marble window sill (1:3) on HCB","unit":"ml","price":"3,946.28"},
        {"page":24,"code":"9.5.5","description":"30mm Thick & 520mm width Marble window sill (1:3) on HCB","unit":"ml","price":"4,081.28"},
        {"page":24,"code":"9.6.1.1","description":"Marble Treads — 280mm wide & 30mm thick (1:3)","unit":"ml","price":"2,711.92"},
        {"page":24,"code":"9.6.1.2","description":"Marble Treads — 300mm wide & 30mm thick (1:3)","unit":"ml","price":"2,849.62"},
        {"page":24,"code":"9.6.1.3","description":"Marble Treads — 330mm wide & 30mm thick (1:3)","unit":"ml","price":"3,056.17"},
        {"page":24,"code":"9.6.1.4","description":"Marble Treads — 280mm wide & 20mm thick (1:3)","unit":"ml","price":"2,669.08"},
        {"page":24,"code":"9.6.1.5","description":"Marble Treads — 300mm wide & 20mm thick (1:3)","unit":"ml","price":"2,803.72"},
        {"page":24,"code":"9.6.1.6","description":"Marble Treads — 330mm wide & 20mm thick (1:3)","unit":"ml","price":"3,005.68"},
        {"page":24,"code":"9.6.2.1","description":"Granite Treads — 280mm wide & 30mm thick (1:3)","unit":"ml","price":"2,816.97"},
        {"page":24,"code":"9.6.2.2","description":"Granite Treads — 300mm wide & 30mm thick (1:3)","unit":"ml","price":"2,981.97"},
        {"page":24,"code":"9.6.2.3","description":"Granite Treads — 330mm wide & 30mm thick (1:3)","unit":"ml","price":"3,229.47"},
        {"page":24,"code":"9.6.2.4","description":"Granite Treads — 280mm wide & 20mm thick (1:3)","unit":"ml","price":"2,755.37"},
        {"page":24,"code":"9.6.2.5","description":"Granite Treads — 300mm wide & 20mm thick (1:3)","unit":"ml","price":"2,915.97"},
        {"page":24,"code":"9.6.2.6","description":"Granite Treads — 330mm wide & 20mm thick (1:3)","unit":"ml","price":"3,156.87"},
        {"page":24,"code":"9.6.3.1","description":"Terrazzo Treads — 280mm wide & 30mm thick (1:3)","unit":"ml","price":"789.77"},
        {"page":24,"code":"9.6.3.2","description":"Terrazzo Treads — 300mm wide & 30mm thick (1:3)","unit":"ml","price":"808.03"},
        {"page":24,"code":"9.6.3.3","description":"Terrazzo Treads — 330mm wide & 30mm thick (1:3)","unit":"ml","price":"835.42"},
        {"page":24,"code":"9.6.3.4","description":"Terrazzo Treads — 280mm wide & 20mm thick (1:3)","unit":"ml","price":"734.04"},
        {"page":24,"code":"9.6.3.5","description":"Terrazzo Treads — 300mm wide & 20mm thick (1:3)","unit":"ml","price":"748.32"},
        {"page":24,"code":"9.6.3.6","description":"Terrazzo Treads — 330mm wide & 20mm thick (1:3)","unit":"ml","price":"769.74"},
        {"page":25,"code":"9.7.1.1","description":"Marble Riser — 130mm wide & 20mm thick (1:3)","unit":"ml","price":"1,207.67"},
        {"page":25,"code":"9.7.1.2","description":"Marble Riser — 150mm wide & 20mm thick (1:3)","unit":"ml","price":"1,346.27"},
        {"page":25,"code":"9.7.2.1","description":"Granite Riser — 130mm wide & 20mm thick (1:3)","unit":"ml","price":"1,598.32"},
        {"page":25,"code":"9.7.2.2","description":"Granite Riser — 150mm wide & 20mm thick (1:3)","unit":"ml","price":"1,766.22"},
        {"page":25,"code":"9.7.3.1","description":"Terrazzo Riser — 130mm wide & 30mm thick (1:3)","unit":"ml","price":"422.42"},
        {"page":25,"code":"9.7.3.2","description":"Terrazzo Riser — 130mm wide & 20mm thick (1:3)","unit":"ml","price":"391.99"},
        {"page":25,"code":"9.7.3.3","description":"Terrazzo Riser — 150mm wide & 20mm thick (1:3)","unit":"ml","price":"411.77"},
        {"page":25,"code":"9.8.1.1","description":"Marble threshold — 20mm thick & 200mm wide (1:3)","unit":"ml","price":"1,736.72"},
        {"page":25,"code":"9.8.1.2","description":"Marble threshold — 20mm thick & 250mm wide (1:3)","unit":"ml","price":"2,167.19"},
        {"page":25,"code":"9.8.2.1","description":"Granite threshold — 20mm thick & 200mm wide (1:3)","unit":"ml","price":"1,979.72"},
        {"page":25,"code":"9.8.2.2","description":"Granite threshold — 20mm thick & 250mm wide (1:3)","unit":"ml","price":"2,345.69"},
        {"page":25,"code":"9.8.3.1","description":"Terrazzo threshold — 20mm thick & 200mm wide (1:3)","unit":"ml","price":"478.55"},
        {"page":25,"code":"9.8.3.2","description":"Terrazzo threshold — 20mm thick & 250mm wide (1:3)","unit":"ml","price":"639.41"},
        {"page":25,"code":"9.9.1","description":"10cm high PVC skirting 2mm thick","unit":"ml","price":"213.38"},
        {"page":25,"code":"9.9.2","description":"20mm thick terrazzo skirting (Local)","unit":"ml","price":"211.11"},
        {"page":25,"code":"9.9.3","description":"10cm high 10mm thick Porcelain skirting","unit":"ml","price":"721.07"},
        {"page":25,"code":"9.9.4","description":"100mm high wooden skirting (Local wood)","unit":"ml","price":"1,048.90"},
        {"page":25,"code":"9.9.5","description":"10cm high 2cm thick granite skirting (Local)","unit":"ml","price":"1,006.94"},
        {"page":25,"code":"9.9.6","description":"20mm Thick, 10cm high Marble skirting (Local)","unit":"ml","price":"1,014.28"},
        {"page":25,"code":"9.10.1","description":"Marble copping — 300mm wide & 30mm thick (1:3)","unit":"ml","price":"2,599.62"},
        {"page":25,"code":"9.10.2","description":"Marble copping — 450mm wide & 30mm thick (1:3)","unit":"ml","price":"3,632.37"},
        {"page":25,"code":"9.10.3","description":"Marble copping — 300mm wide & 20mm thick (1:3)","unit":"ml","price":"2,553.72"},
        {"page":25,"code":"9.10.4","description":"Marble copping — 450mm wide & 20mm thick (1:3)","unit":"ml","price":"3,563.52"},
        {"page":25,"code":"9.11.1","description":"Terrazzo copping — 300mm wide & 30mm thick (1:3)","unit":"ml","price":"806.10"},
        {"page":25,"code":"9.11.2","description":"Terrazzo copping — 450mm wide & 30mm thick (1:3)","unit":"ml","price":"942.40"},
        {"page":25,"code":"9.11.3","description":"Terrazzo copping — 300mm wide & 20mm thick (1:3)","unit":"ml","price":"725.23"},
        {"page":25,"code":"9.11.4","description":"Terrazzo copping — 450mm wide & 20mm thick (1:3)","unit":"ml","price":"821.10"},
        {"page":25,"code":"9.11.5","description":"10mm thick Ceramic floor with cement sand mortar (Local)","unit":"m²","price":"3,546.49"},
        {"page":25,"code":"9.11.6","description":"9mm thick Ceramic floor tile with cement sand mortar (Local)","unit":"m²","price":"3,444.49"},
        {"page":25,"code":"9.11.7","description":"8mm thick Ceramic floor tile with cement sand mortar (Local)","unit":"m²","price":"2,881.27"},
        {"page":25,"code":"9.11.8","description":"10mm thick Ceramic floor with cement sand mortar (1:3)","unit":"m²","price":"4,362.49"},
        {"page":25,"code":"9.11.9","description":"10 mm thick Ceramic floor tile with Adhesive powder","unit":"m²","price":"4,287.25"},
        {"page":25,"code":"9.11.10","description":"9mm thick Ceramic floor with cement sand mortar (1:3)","unit":"m²","price":"3,966.12"},
        {"page":25,"code":"9.11.11","description":"8mm thick Ceramic floor with cement sand mortar (1:3)","unit":"m²","price":"3,660.12"},
        {"page":25,"code":"9.11.12","description":"10mm thick Porcelain floor tile with cement sand mortar (1:3)","unit":"m²","price":"5,484.49"},
        {"page":26,"code":"9.11.13","description":"SPC floor with foam","unit":"m²","price":"1,983.91"},
        {"page":26,"code":"9.11.14","description":"SPC Skirting","unit":"ml","price":"375.00"},
        {"page":26,"code":"9.11.15","description":"Flamed Granite floor tile with cement sand mortar (1:3) (Local)","unit":"m²","price":"10,465.34"},
        {"page":26,"code":"9.11.16","description":"Flamed Granite floor tile with cement sand mortar (1:3) (imported)","unit":"m²","price":"11,184.09"},
        {"page":26,"code":"9.11.17","description":"Imported 1cm thick high quality Black Galaxy Granite (1:3) — wall cladding","unit":"m²","price":"14,710.83"},
        {"page":26,"code":"9.11.18","description":"Imported 2cm thick high quality Black Galaxy Granite (1:3) — flooring","unit":"m²","price":"20,745.29"},
        {"page":26,"code":"9.11.19","description":"Imported 3cm thick high quality Black Galaxy Granite (1:3) — flooring","unit":"m²","price":"23,136.29"},
        {"page":26,"code":"9.11.20","description":"Imported 1cm thick high quality Granite (grey) (1:3) — wall cladding","unit":"m²","price":"13,729.08"},
        {"page":26,"code":"9.11.21","description":"Imported 2cm thick high quality Granite (grey) (1:3) — flooring","unit":"m²","price":"13,078.78"},
        {"page":26,"code":"9.11.22","description":"Imported 3cm thick high quality Granite (grey) (1:3) — flooring","unit":"m²","price":"15,578.78"},
        {"page":26,"code":"9.11.23","description":"2cm thick high quality standard Black Galaxy Granite for kitchen cabinet","unit":"m²","price":"19,659.20"},
        {"page":26,"code":"9.11.24","description":"Porcelain floor tile with adhesive powder (120cmx60cmx1cm)","unit":"m²","price":"5,803.85"},
        {"page":26,"code":"9.11.25","description":"Porcelain floor tile with cement sand mortar (1:3) (120cmx60cmx1cm)","unit":"m²","price":"5,484.69"}
      ]
    },
    {
      "id": "10",
      "title": "PAINTING (WITHOUT SCAFFOLDING)",
      "items": [
        {"page":27,"code":"10.1.1","description":"3 coats plastic paint to wall — Internal","unit":"m²","price":"222.76"},
        {"page":27,"code":"10.1.2","description":"3 coats plastic paint to wall — External","unit":"m²","price":"226.12"},
        {"page":27,"code":"10.1.3","description":"3 coats plastic paint to tyrelean & rendered wall — External","unit":"m²","price":"252.45"},
        {"page":27,"code":"10.1.4","description":"3 coats plastic paint to Exposed column and beam","unit":"m²","price":"231.66"},
        {"page":27,"code":"10.1.5","description":"3 coats plastic paint to chipwood ceiling","unit":"m²","price":"237.32"},
        {"page":27,"code":"10.1.6","description":"3 coats plastic paint to Plastered ceiling","unit":"m²","price":"261.23"},
        {"page":27,"code":"10.1.7","description":"3 coats plastic paint to fyzit ceiling","unit":"m²","price":"231.66"},
        {"page":27,"code":"10.1.8","description":"3 coats plastic paint to abjudied ceiling","unit":"m²","price":"227.66"},
        {"page":27,"code":"10.2.1","description":"3 coats Oil (synthetic) paint to wall — Internal","unit":"m²","price":"321.32"},
        {"page":27,"code":"10.2.2","description":"3 coats Oil (synthetic) paint to wall — External","unit":"m²","price":"325.30"},
        {"page":27,"code":"10.2.3","description":"3 coats Oil (synthetic) paint to Exposed column and beam","unit":"m²","price":"325.30"},
        {"page":27,"code":"10.2.4","description":"3 coats synthetic paint to plastered soffit surface","unit":"m²","price":"360.40"},
        {"page":27,"code":"10.2.5","description":"1 coat antitrust + 2 coats synthetic enamel paint to ribbed sheet soffit","unit":"m²","price":"320.91"},
        {"page":27,"code":"10.2.6","description":"1 coat antitrust + 2 coats synthetic enamel paint to metal surface","unit":"m²","price":"285.81"},
        {"page":27,"code":"10.2.7","description":"3 coats varnish paint to wooden vertical surface","unit":"m²","price":"339.76"},
        {"page":27,"code":"10.2.8","description":"3 coats varnish paint to wooden soffit","unit":"m²","price":"374.86"},
        {"page":27,"code":"10.2.9","description":"2 coats Mica paint to internal plastered surface","unit":"m²","price":"319.36"},
        {"page":27,"code":"10.2.10","description":"2 coats Mica paint to external plastered surface","unit":"m²","price":"333.99"},
        {"page":27,"code":"10.2.11","description":"2 coats special aluminum paint to metal vertical surface","unit":"m²","price":"297.66"},
        {"page":27,"code":"10.2.12","description":"2 coats special antitrust paint to GCIS & EGA roof cover","unit":"m²","price":"238.00"},
        {"page":27,"code":"10.3.1","description":"Quartz paint to Plastered surface","unit":"m²","price":"857.39"},
        {"page":27,"code":"10.3.3","description":"Lime paint /'S' - 4'A' - 4'+'+'","unit":"m²","price":"347.82"},
        {"page":27,"code":"10.3.4","description":"GRANITE PAINTING On external plastered wall — gypsum final coat + primer + 3 coats varnish","unit":"m²","price":"969.19"},
        {"page":27,"code":"10.3.5","description":"Contextra (Texura Sparol) paint to plastered HCB wall — acrylic putty, 2 primer + 2 pertex emulsion + 2 clear weather guard (ISO certified)","unit":"m²","price":"979.11"},
        {"page":27,"code":"10.4.1","description":"JOTUN interior acrylic emulsion Matt finish — 1 PVA primer + 2 acrylic copolymer emulsion as per ISO 3233","unit":"m²","price":"235.00"},
        {"page":27,"code":"10.4.2","description":"JOTUN exterior concrete / plastered surfaces textile system","unit":"m²","price":"778.00"},
        {"page":28,"code":"10.5.1","description":"Supply & fix 3mm clear glass","unit":"m²","price":"1,927.65"},
        {"page":28,"code":"10.5.2","description":"Supply & fix 4mm clear glass","unit":"m²","price":"2,180.65"},
        {"page":28,"code":"10.5.3","description":"Supply & fix 5mm clear glass","unit":"m²","price":"2,992.57"},
        {"page":28,"code":"10.5.4","description":"Supply & fix 6mm clear glass","unit":"m²","price":"4,131.07"},
        {"page":28,"code":"10.5.5","description":"Supply & fix 4mm Figured glass","unit":"m²","price":"3,511.82"},
        {"page":28,"code":"10.5.6","description":"Supply & fix 5mm Figured glass","unit":"m²","price":"4,207.57"},
        {"page":28,"code":"10.5.7","description":"Supply & fix 6mm Figured glass","unit":"m²","price":"4,713.57"},
        {"page":28,"code":"10.5.8","description":"Supply & fix 3mm Frosted glass","unit":"m²","price":"3,448.57"},
        {"page":28,"code":"10.5.9","description":"Supply & fix 4mm Frosted glass","unit":"m²","price":"3,701.57"},
        {"page":28,"code":"10.5.10","description":"Supply & fix 5mm Frosted glass","unit":"m²","price":"4,207.57"},
        {"page":28,"code":"10.5.11","description":"Supply & fix 6mm Frosted glass","unit":"m²","price":"4,840.07"},
        {"page":28,"code":"10.5.12","description":"Supply & fix 4mm Tinted glass","unit":"m²","price":"3,448.57"},
        {"page":28,"code":"10.5.13","description":"Supply & fix 5mm Tinted glass","unit":"m²","price":"4,144.32"},
        {"page":28,"code":"10.5.14","description":"Supply & fix 6mm Tinted glass","unit":"m²","price":"4,334.07"},
        {"page":28,"code":"10.5.15","description":"Supply & fix 4mm Reflected glass","unit":"m²","price":"3,448.57"},
        {"page":28,"code":"10.5.16","description":"Supply & fix 5mm Reflected glass","unit":"m²","price":"4,207.57"},
        {"page":28,"code":"10.5.17","description":"Supply & fix 6mm Reflected glass","unit":"m²","price":"4,903.32"},
        {"page":28,"code":"10.5.18","description":"Supply & fix 6mm Laminated or security glass","unit":"m²","price":"6,611.07"},
        {"page":28,"code":"10.5.19","description":"Supply & fix 5mm Wired glass","unit":"m²","price":"4,840.07"},
        {"page":28,"code":"10.5.20","description":"Supply & fix 10mm thick Tempered Frameless partition wall with U-frame edging and adhesive silicon","unit":"m²","price":"14,850.00"},
        {"page":28,"code":"10.5.21","description":"Supply & fix 10mm thick Tempered Frameless clear Glass Door — Double Leaf","unit":"m²","price":"17,050.00"}
      ]
    },
    {
      "id": "12",
      "title": "SANITARY INSTALLATION / PLUMBING",
      "items": [
        {"page":29,"code":"12.1.1","description":"HWB size 45 * 55 cm with all Accessories heavy duty flexible (RAK)","unit":"PCS","price":"20,030.53"},
        {"page":29,"code":"12.1.2","description":"HWB size 45 * 55 cm with all Accessories (Golden dragon sealed)","unit":"PCS","price":"17,011.78"},
        {"page":29,"code":"12.1.3","description":"HWB size 40 * 50 cm with all Accessories (AQUA)","unit":"PCS","price":"14,596.78"},
        {"page":29,"code":"12.2.1","description":"Low flash WC with all accessories (RAK)","unit":"PCS","price":"28,483.03"},
        {"page":29,"code":"12.2.2","description":"Low flash WC with all accessories (Golden dragon sealed)","unit":"PCS","price":"26,671.78"},
        {"page":29,"code":"12.2.3","description":"Low flash WC with all accessories (AQUA)","unit":"PCS","price":"19,185.28"},
        {"page":29,"code":"12.2.4","description":"Low flash WC with all accessories (Tabor ceramic)","unit":"PCS","price":"9,404.53"},
        {"page":29,"code":"12.2.5","description":"Turkish type WC (RAK)","unit":"PCS","price":"7,714.03"},
        {"page":29,"code":"12.2.6","description":"Turkish type WC (Tabor ceramic)","unit":"PCS","price":"6,989.53"},
        {"page":29,"code":"12.3.1","description":"White glazed urinal with all accessories","unit":"PCS","price":"10,383.12"},
        {"page":29,"code":"12.3.2","description":"Urinal with all accessories","unit":"PCS","price":"10,383.12"},
        {"page":30,"code":"12.7.6","description":"Shower box 90x90cm","unit":"PCS","price":"40,000.00"},
        {"page":30,"code":"12.7.7","description":"Disabled Hand wash basin","unit":"PCS","price":"38,971.15"},
        {"page":30,"code":"12.7.8","description":"Disabled Water Closet","unit":"PCS","price":"33,847.90"},
        {"page":30,"code":"12.7.9","description":"Disabled Toilet (Disable HWB & Disable WC)","unit":"PCS","price":"76,460.01"},
        {"page":30,"code":"12.8.1","description":"70x170cm Bath Tab with all accessories","unit":"PCS","price":"51,170.22"},
        {"page":30,"code":"12.8.2","description":"70x170cm Bath Tab with all accessories medium quality","unit":"PCS","price":"43,779.22"},
        {"page":30,"code":"12.8.3","description":"70x170cm Bath Tab with all accessories (fiber glass)","unit":"PCS","price":"38,127.22"},
        {"page":30,"code":"12.9.1","description":"Kitchen sink (double bowel) Italy","unit":"PCS","price":"9,513.87"},
        {"page":30,"code":"12.9.2","description":"Kitchen sink (double bowel) AQUA","unit":"PCS","price":"9,513.87"},
        {"page":30,"code":"12.9.3","description":"Kitchen sink (double bowel) Milano","unit":"PCS","price":"8,427.12"},
        {"page":30,"code":"12.9.4","description":"Kitchen sink (Single bowel) AQUA","unit":"PCS","price":"7,581.87"},
        {"page":30,"code":"12.9.5","description":"Kitchen sink (Single bowel) Milano","unit":"PCS","price":"6,615.87"},
        {"page":30,"code":"12.10.1","description":"Instant Water heater","unit":"PCS","price":"25,860.22"},
        {"page":30,"code":"12.10.2","description":"50lt Water heater ordinary","unit":"PCS","price":"32,790.22"},
        {"page":30,"code":"12.10.3","description":"80lt Water heater ordinary","unit":"PCS","price":"43,185.22"},
        {"page":30,"code":"12.10.4","description":"100lt Water heater ordinary","unit":"PCS","price":"57,622.72"},
        {"page":30,"code":"12.10.5","description":"50lt Water heater (Ariston)","unit":"PCS","price":"39,469.13"},
        {"page":30,"code":"12.10.6","description":"80lt Water heater (Ariston)","unit":"PCS","price":"51,220.00"},
        {"page":30,"code":"12.10.7","description":"100lt Water heater (Ariston)","unit":"PCS","price":"66,887.83"},
        {"page":30,"code":"12.11.1","description":"Floor drain (100mm) (Chrome plated)","unit":"PCS","price":"2,100.54"},
        {"page":30,"code":"12.11.2","description":"Floor drain (80mm) (Chrome plated)","unit":"PCS","price":"2,033.88"},
        {"page":30,"code":"12.11.3","description":"Floor drain (50mm) (Chrome plated)","unit":"PCS","price":"1,542.89"},
        {"page":30,"code":"12.11.4","description":"Dia. 110mm clean out waste water","unit":"PCS","price":"1,261.64"},
        {"page":30,"code":"12.11.5","description":"Dia. 80mm clean out","unit":"PCS","price":"1,097.51"},
        {"page":30,"code":"12.11.6","description":"Dia. 50mm clean out","unit":"PCS","price":"926.16"},
        {"page":30,"code":"12.11.7","description":"Precast cloth washing basin","unit":"PCS","price":"5,582.16"},
        {"page":30,"code":"12.12.1","description":"1/2\" PPR Pipe","unit":"ml","price":"357.10"},
        {"page":30,"code":"12.12.2","description":"3/4\" PPR Pipe","unit":"ml","price":"450.36"},
        {"page":30,"code":"12.12.3","description":"1\" PPR Pipe","unit":"ml","price":"817.80"},
        {"page":30,"code":"12.12.4","description":"11/4\" PPR Pipe","unit":"ml","price":"1,167.53"},
        {"page":30,"code":"12.12.5","description":"11/2\" PPR Pipe","unit":"ml","price":"2,240.03"},
        {"page":30,"code":"12.12.6","description":"2\" PPR Pipe","unit":"ml","price":"2,939.49"},
        {"page":30,"code":"12.12.7","description":"21/2\" PPR Pipe","unit":"ml","price":"3,405.79"},
        {"page":30,"code":"12.12.8","description":"3\" PPR Pipe","unit":"ml","price":"5,737.31"},
        {"page":31,"code":"12.13.1","description":"1/2\" Galvanized Steel Pipe (GSP) 15mm","unit":"ml","price":"1,122.31"},
        {"page":31,"code":"12.13.2","description":"3/4\" GSP 20mm","unit":"ml","price":"1,375.88"},
        {"page":31,"code":"12.13.3","description":"1\" GSP 25mm","unit":"ml","price":"1,604.78"},
        {"page":31,"code":"12.13.4","description":"11/4\" GSP 32mm","unit":"ml","price":"1,719.07"},
        {"page":31,"code":"12.13.5","description":"11/2\" GSP 40mm","unit":"ml","price":"1,943.41"},
        {"page":31,"code":"12.13.6","description":"2\" GSP 50mm","unit":"ml","price":"2,946.01"},
        {"page":31,"code":"12.13.7","description":"21/2\" GSP 63mm","unit":"ml","price":"3,616.48"},
        {"page":31,"code":"12.13.8","description":"3\" GSP 75mm","unit":"ml","price":"4,736.57"},
        {"page":31,"code":"12.13.9","description":"31/2\" GSP","unit":"ml","price":"6,943.77"},
        {"page":31,"code":"12.13.10","description":"4\" GSP","unit":"ml","price":"8,369.55"},
        {"page":31,"code":"12.13.11","description":"5\" GSP","unit":"ml","price":"8,782.41"},
        {"page":31,"code":"12.13.12","description":"6\" GSP","unit":"ml","price":"10,216.89"},
        {"page":31,"code":"12.13.13","description":"8\" GSP","unit":"ml","price":"12,179.01"},
        {"page":31,"code":"12.13.14","description":"10\" GSP","unit":"ml","price":"14,056.72"},
        {"page":31,"code":"12.13.15","description":"12\" GSP","unit":"ml","price":"16,290.58"},
        {"page":31,"code":"12.14.1","description":"31/2\" Cast iron Pipe (CIP)","unit":"ml","price":"1,115.68"},
        {"page":31,"code":"12.14.2","description":"4\" CIP","unit":"ml","price":"1,860.98"},
        {"page":31,"code":"12.14.3","description":"5\" CIP","unit":"ml","price":"1,946.51"},
        {"page":31,"code":"12.14.4","description":"6\" CIP","unit":"ml","price":"2,043.08"},
        {"page":31,"code":"12.14.5","description":"8\" CIP","unit":"ml","price":"2,619.32"},
        {"page":31,"code":"12.14.6","description":"10\" CIP","unit":"ml","price":"3,118.83"},
        {"page":31,"code":"12.14.7","description":"12\" CIP","unit":"ml","price":"3,942.12"},
        {"page":31,"code":"12.15.1","description":"1/2\" HDPE Pipe","unit":"ml","price":"1,476.21"},
        {"page":31,"code":"12.15.2","description":"3/4\" HDPE Pipe","unit":"ml","price":"1,566.74"},
        {"page":31,"code":"12.15.3","description":"1\" HDPE Pipe","unit":"ml","price":"1,643.20"},
        {"page":31,"code":"12.15.4","description":"11/4\" HDPE Pipe","unit":"ml","price":"1,740.44"},
        {"page":31,"code":"12.15.5","description":"11/2\" HDPE Pipe","unit":"ml","price":"1,934.58"},
        {"page":31,"code":"12.15.6","description":"2\" HDPE Pipe","unit":"ml","price":"2,063.82"},
        {"page":31,"code":"12.15.7","description":"21/2\" HDPE Pipe","unit":"ml","price":"2,317.96"},
        {"page":31,"code":"12.15.8","description":"3\" HDPE Pipe","unit":"ml","price":"2,750.94"},
        {"page":31,"code":"12.15.9","description":"3.5\" HDPE Pipe","unit":"ml","price":"3,411.71"},
        {"page":31,"code":"12.15.10","description":"4\" HDPE Pipe","unit":"ml","price":"4,123.63"},
        {"page":31,"code":"12.15.11","description":"5\" HDPE Pipe","unit":"ml","price":"4,374.14"},
        {"page":32,"code":"12.19.1","description":"BRONZE Gate Valve PN 16 1/2\"X20","unit":"PCS","price":"1,483.19"},
        {"page":32,"code":"12.19.2","description":"BRONZE Gate Valve PN 16 3/4\"","unit":"PCS","price":"1,917.97"},
        {"page":32,"code":"12.19.3","description":"BRONZE Gate Valve PN 16 1\" (25)","unit":"PCS","price":"2,678.84"},
        {"page":32,"code":"12.19.4","description":"BRONZE Gate Valve PN 16 32MM","unit":"PCS","price":"3,983.19"},
        {"page":32,"code":"12.19.5","description":"BRONZE Gate Valve PN 16 40MM","unit":"PCS","price":"4,417.97"},
        {"page":32,"code":"12.19.6","description":"BRONZE Gate Valve PN 16 2\"","unit":"PCS","price":"6,265.80"},
        {"page":32,"code":"12.19.7","description":"BRONZE Gate Valve PN 16 21/2\"","unit":"PCS","price":"6,809.28"},
        {"page":32,"code":"12.19.8","description":"BRONZE Gate Valve PN 16 3\"","unit":"PCS","price":"7,896.24"},
        {"page":32,"code":"12.19.9","description":"BRONZE Gate Valve PN 16 3.5\"","unit":"PCS","price":"9,479.08"},
        {"page":32,"code":"12.19.10","description":"BRONZE Gate Valve PN 16 4\"","unit":"PCS","price":"9,964.72"},
        {"page":32,"code":"12.19.11","description":"BRASS Gate Valve PN 16 3\"","unit":"PCS","price":"6,027.25"},
        {"page":32,"code":"12.19.12","description":"BRASS Gate Valve PN 16 21/2\"","unit":"PCS","price":"4,592.47"},
        {"page":32,"code":"12.19.13","description":"BRASS Gate Valve PN 16 11/2\"","unit":"PCS","price":"2,159.08"},
        {"page":32,"code":"12.19.14","description":"BRASS Gate Valve PN 16 2\"","unit":"PCS","price":"3,017.08"},
        {"page":32,"code":"12.19.15","description":"BRASS Gate Valve PN 16 4\"","unit":"PCS","price":"12,595.84"},
        {"page":32,"code":"12.19.16","description":"BRASS Gate Valve PN 16 3\" two way","unit":"PCS","price":"8,635.48"},
        {"page":32,"code":"12.19.20","description":"BRASS Gate Valve PN 16 4\" two way","unit":"PCS","price":"14,589.29"},
        {"page":32,"code":"12.19.21","description":"BRASS Gate Valve PN 16 5\" two way","unit":"PCS","price":"18,523.53"},
        {"page":32,"code":"12.19.22","description":"BRASS Gate Valve PN 16 6\"","unit":"PCS","price":"11,836.72"},
        {"page":32,"code":"12.19.23","description":"BRASS Gate Valve PN 16 8\"","unit":"PCS","price":"17,306.05"},
        {"page":32,"code":"12.19.24","description":"BRASS Gate Valve PN 16 10\"","unit":"PCS","price":"22,200.81"},
        {"page":32,"code":"12.19.25","description":"BRASS Gate Valve PN 16 12\"","unit":"PCS","price":"29,183.50"},
        {"page":32,"code":"12.19.16b","description":"FLOAT VALVE PN 16 2\" (50)","unit":"PCS","price":"1,275.95"},
        {"page":33,"code":"12.20.1","description":"Cast iron Valve PN 16 90mm","unit":"PCS","price":"20,248.44"},
        {"page":33,"code":"12.20.2","description":"Cast iron Valve PN 16 100mm","unit":"PCS","price":"29,564.87"},
        {"page":33,"code":"12.20.3","description":"Cast iron Valve PN 16 150mm","unit":"PCS","price":"37,475.66"},
        {"page":33,"code":"12.20.4","description":"Cast iron Valve PN 16 200mm","unit":"PCS","price":"54,224.58"},
        {"page":33,"code":"12.20.5","description":"Cast iron Gate Valve PN 16 300mm","unit":"PCS","price":"69,226.28"},
        {"page":33,"code":"12.21.2","description":"25mm dia. Water Meter","unit":"PCS","price":"1,996.10"},
        {"page":33,"code":"12.21.3","description":"50mm dia. Water Meter","unit":"PCS","price":"4,763.38"},
        {"page":33,"code":"12.22.1","description":"50 mm dia. UPVC Pipe (without Civil works)","unit":"ml","price":"490.73"},
        {"page":33,"code":"12.22.2","description":"65 mm dia. UPVC Pipe","unit":"ml","price":"603.04"},
        {"page":33,"code":"12.22.3","description":"75 mm dia. UPVC Pipe","unit":"ml","price":"664.50"},
        {"page":33,"code":"12.22.4","description":"110 mm dia. UPVC Pipe","unit":"ml","price":"919.54"},
        {"page":33,"code":"12.22.5","description":"125 mm dia. UPVC Pipe","unit":"ml","price":"1,190.92"},
        {"page":33,"code":"12.22.6","description":"160 mm dia. UPVC Pipe","unit":"ml","price":"1,819.43"},
        {"page":33,"code":"12.22.7","description":"200 mm dia. UPVC Pipe","unit":"ml","price":"2,215.01"},
        {"page":33,"code":"12.22.8","description":"225 mm dia. UPVC Pipe","unit":"ml","price":"2,635.62"},
        {"page":33,"code":"12.22.9","description":"250 mm dia. UPVC Pipe","unit":"ml","price":"4,297.16"},
        {"page":33,"code":"12.22.10","description":"315 mm dia. UPVC Pipe","unit":"ml","price":"7,354.10"},
        {"page":33,"code":"12.22.11","description":"355 mm dia. UPVC Pipe","unit":"ml","price":"8,579.79"},
        {"page":33,"code":"12.22.12","description":"400 mm dia. UPVC Pipe","unit":"ml","price":"12,117.34"},
        {"page":33,"code":"12.22.13","description":"450 mm dia. UPVC Pipe","unit":"ml","price":"13,329.08"},
        {"page":33,"code":"12.22.14","description":"500 mm dia. UPVC Pipe","unit":"ml","price":"14,550.83"},
        {"page":33,"code":"12.22.15","description":"160 mm dia. PERFORATED PIPE — includes Geosynthetic, Damp proof, Gravel 40-50mm, Select material","unit":"ml","price":"4,978.02"},
        {"page":33,"code":"12.23.1","description":"Dia. 50mm Vent cap","unit":"PCS","price":"309.44"},
        {"page":33,"code":"12.23.2","description":"Dia. 80mm Vent cap","unit":"PCS","price":"331.54"},
        {"page":33,"code":"12.23.3","description":"Dia. 100mm Vent cap","unit":"PCS","price":"376.29"},
        {"page":33,"code":"12.24.1","description":"80 mm dia. UPVC Pipe down pipe","unit":"ml","price":"674.06"},
        {"page":33,"code":"12.24.2","description":"110 mm dia. UPVC Pipe down pipe","unit":"ml","price":"921.56"},
        {"page":33,"code":"12.24.3","description":"125 mm dia. UPVC Pipe down pipe","unit":"ml","price":"1,205.52"},
        {"page":33,"code":"12.24.4","description":"160 mm dia. UPVC Pipe down pipe","unit":"ml","price":"1,797.87"},
        {"page":33,"code":"12.26.1","description":"4mm thick approved quality water proofing","unit":"m²","price":"338.34"},
        {"page":33,"code":"12.26.2","description":"Xypex","unit":"m²","price":"399.00"},
        {"page":33,"code":"12.26.3","description":"PVC JOINT FILLER AND WATER STOPPER","unit":"m²","price":"520.00"},
        {"page":33,"code":"12.26.4","description":"CEMENTIOUS WATER PROOF","unit":"m²","price":"255.06"},
        {"page":33,"code":"12.26.5","description":"Soccer Field Irrigation System","unit":"PCS","price":"769.19"},
        {"page":33,"code":"12.26.7","description":"PVC WATERSTOPS","unit":"ml","price":"447.43"},
        {"page":33,"code":"12.26.8","description":"Polyurethane water proof coating","unit":"m²","price":"436.59"},
        {"page":33,"code":"12.32.1","description":"Curb stone in C-25 size 150x400mm","unit":"ml","price":"2,020.20"},
        {"page":33,"code":"12.34.1","description":"Polyethylene water tank 750 lt","unit":"No.","price":"13,193.80"},
        {"page":33,"code":"12.34.2","description":"Polyethylene water tank 1000 lt","unit":"No.","price":"14,572.56"},
        {"page":33,"code":"12.34.3","description":"Polyethylene water tank 2000 lt","unit":"No.","price":"13,270.84"},
        {"page":33,"code":"12.34.4","description":"Polyethylene water tank 5000 lt","unit":"No.","price":"26,600.16"},
        {"page":33,"code":"12.34.5","description":"Fiber glass water tank 500 lt","unit":"No.","price":"30,485.91"},
        {"page":33,"code":"12.34.6","description":"Fiber glass water tank 1000 lt","unit":"No.","price":"32,730.00"},
        {"page":33,"code":"12.34.7","description":"Fiber glass water tank 3000 lt","unit":"No.","price":"58,485.91"},
        {"page":33,"code":"12.34.8","description":"Fiber glass water tank 5000 lt","unit":"No.","price":"79,485.91"},
        {"page":33,"code":"12.34.9","description":"Fiber glass water tank 10000 lt","unit":"No.","price":"153,485.91"},
        {"page":33,"code":"12.34.10","description":"Fiber glass water tank 15000 lt","unit":"No.","price":"207,485.91"},
        {"page":33,"code":"12.34.11","description":"Fiber glass water tank 20000 lt","unit":"No.","price":"262,485.91"},
        {"page":33,"code":"12.34.12","description":"Fiber glass water tank 25000 lt","unit":"No.","price":"358,485.91"}
      ]
    },
    {
      "id": "DRAINAGE",
      "title": "DRAINAGE WORK",
      "items": [
        {"page":34,"code":"D1.1","description":"Half Dia. 30cm concrete pipe","unit":"ml","price":"1377.47"},
        {"page":34,"code":"D1.2","description":"Half Dia. 40cm concrete pipe","unit":"ml","price":"1554.86"},
        {"page":34,"code":"D2.1","description":"Closed ditch — Supply and lay Diameter 30 cm concrete pipe","unit":"ml","price":"1474.07"},
        {"page":34,"code":"D2.2","description":"Closed ditch — Diameter 40 cm concrete pipe","unit":"ml","price":"1576.07"},
        {"page":34,"code":"D2.3","description":"Closed ditch — Diameter 50 cm concrete pipe","unit":"ml","price":"3304.19"},
        {"page":34,"code":"D2.4","description":"Closed ditch — Diameter 60 cm concrete pipe","unit":"ml","price":"4324.19"},
        {"page":34,"code":"D2.5","description":"Closed ditch — Diameter 100 cm concrete pipe","unit":"ml","price":"8614.59"},
        {"page":34,"code":"D3.1","description":"Reinforced closed ditch — Diameter 50 cm concrete pipe","unit":"ml","price":"8436.59"},
        {"page":34,"code":"D3.2","description":"Reinforced closed ditch — Diameter 60 cm concrete pipe","unit":"ml","price":"9456.59"}
      ]
    },
    {
      "id": "ROAD",
      "title": "ROAD WORK / FOOT PATH & GENERAL PAVING",
      "items": [
        {"page":35,"code":"FP1","description":"Foot path brick (15*30*0.5) — coloured concrete block on cement stabilized sand base 50mm fine aggregate","unit":"m²","price":"1899.98"},
        {"page":35,"code":"FP2","description":"Foot path brick (15*30*0.5) — coloured concrete block on mortar bedding","unit":"m²","price":"2617.24"},
        {"page":35,"code":"FP3","description":"Foot path brick (I-section) — coloured concrete block on mortar bedding","unit":"m²","price":"2601.59"},
        {"page":35,"code":"FP4","description":"Foot path brick (I-section) W=15/9cm L=30cm T=5cm — coloured concrete block on sand bedding","unit":"m²","price":"1885.05"},
        {"page":35,"code":"FP5","description":"Foot path yellow tiles — coloured concrete block on cement stabilized sand base 50mm fine aggregate","unit":"m²","price":"2158.12"},
        {"page":35,"code":"FP6","description":"Foot path yellow tiles — coloured concrete block on mortar bedding","unit":"m²","price":"2562.91"},
        {"page":35,"code":"FP7","description":"Foot path zig zag compressed precoloured concrete block on cement stabilized sand base 50mm fine aggregate","unit":"m²","price":"2102.36"},
        {"page":36,"code":"RD1","description":"Capping layer under the sub base layer (Granular) 200mm — up to avg 15km","unit":"m³","price":"2,563.95"},
        {"page":36,"code":"RD2","description":"Gravel sub base 96% AACRA test S-11 — max 150mm layer, avg 15km","unit":"m³","price":"4,401.11"},
        {"page":36,"code":"RD3","description":"Base course 96% AACRA test S-11 — max 150mm layer, avg 15km","unit":"m³","price":"4,544.50"}
      ]
    },
    {
      "id": "ELEC",
      "title": "ELECTRICAL AND DATA SYSTEM WORK",
      "items": [
        {"page":37,"code":"E.a","description":"16A/1ph digital kilowatt meter","unit":"No.","price":"10,080.00"},
        {"page":37,"code":"E.b","description":"25A/3ph digital kilowatt meter","unit":"No.","price":"15,225.00"},
        {"page":37,"code":"E.c","description":"32A/3ph digital kilowatt meter","unit":"No.","price":"15,225.00"},
        {"page":37,"code":"E.d","description":"63A/3ph digital kilowatt meter","unit":"No.","price":"17,325.00"},
        {"page":37,"code":"1.1.1","description":"Floor standing MDB-EV distribution board 2500A/3ph — 1pc 2000A ACB, 1pc 300mA/4p RCD, 2pc 500A MCCB, 3pc 320A MCCB, 1pc 250A MCCB","unit":"set","price":"702,145.60"},
        {"page":37,"code":"1.1.2","description":"Floor standing Factory made indoor distribution board IP44 (CMDB) — 630A + 400A + 250A MCCB, 40A MCB, 100KA surge, ammeters, CTs","unit":"set","price":"205,182.60"},
        {"page":37,"code":"1.1.2B","description":"Surface mounted metal enclosure MDB-LP 320A/3ph — 250A MCCB, 100mA/4p RCD, 4x25A MCB, 32A MCB, 40A MCB, 2x80A MCB","unit":"set","price":"97,029.36"},
        {"page":37,"code":"1.1.3","description":"Surface mounted SDB-LP/GF/A 100A/3ph — 80A MCB, 100mA/4p RCD, 6x10A, 2x16A, 5x25A, 2x40A","unit":"set","price":"59,881.36"},
        {"page":37,"code":"1.1.4","description":"Surface mounted SDB-LP/GF/B 100A/3ph — 80A MCB, 100mA/4p RCD, 2x10A, 7x16A, 2x40A","unit":"set","price":"92,826.68"},
        {"page":37,"code":"1.1.5","description":"Flush mounted SDB-SH1/GF 32A/3ph — 25A MCB + digital kWh meter, 30mA/2p RCD, 10A MCB, 16A MCB","unit":"set","price":"29,963.68"},
        {"page":38,"code":"1.1.6","description":"Surface mounted SDB-LP/IBF/A 32A/3ph — 25A MCB, 30mA/4p RCD, 8x10A, 4x16A","unit":"set","price":"28,539.68"},
        {"page":38,"code":"1.1.7","description":"Surface mounted SDB-LP/1BF/B 40A/3ph — 32A MCB, 30mA/4p RCD, 9x10A, 4x16A, 3x25A","unit":"set","price":"31,419.68"},
        {"page":38,"code":"1.1.8","description":"Surface mounted SDB-LP/2BF/A 32A/3ph — 25A MCB, 30mA/4p RCD, 7x10A, 4x16A","unit":"set","price":"29,069.68"},
        {"page":38,"code":"1.1.9","description":"Surface mounted SDB-LP/3BF 32A/3ph — 25A MCB, 30mA/4p RCD, 4x10A + 13x10A, 4x16A","unit":"set","price":"31,389.68"},
        {"page":38,"code":"1.1.10","description":"Surface mounted SDB-KCH/3BF 50A/3ph — 40A MCB, 30mA/4p RCD, 4x10A, 7x16A, 20A, 25A, 20A/3p","unit":"set","price":"36,895.36"},
        {"page":38,"code":"1.1.11","description":"Surface mounted MDB-UPS 50A/3ph — 40A MCB, 30mA/4p RCD, 3x16A, 8x20A, 2x25A/3p","unit":"set","price":"35,895.68"},
        {"page":38,"code":"1.1.12","description":"Flush mounted SDB-UPS/GF 32A/1ph — 25A MCB, 30mA/2p RCD, 14x16A","unit":"set","price":"28,303.68"},
        {"page":38,"code":"1.1.13","description":"Surface mounted MDB-MP 500A/3ph — 400A MCB, 300mA/4p RCD, 250A MCB, 2x63A, 3x40A","unit":"set","price":"142,709.60"},
        {"page":39,"code":"1.1.14","description":"Surface mounted SDB-MP/1BF/A 80A/3ph — 63A MCB, 30mA/4p RCD, 7xRCBO 20A, 4xRCBO 32A","unit":"set","price":"60,302.38"},
        {"page":39,"code":"1.1.15","description":"Surface mounted SDB-MP/IBF/B 50A/3ph — 40A MCCB, 30mA/4p RCD, 6xRCBO 20A, 2xRCBO 32A","unit":"set","price":"—"},
        {"page":39,"code":"1.1.16","description":"Surface mounted SDB-MP/2BF/A 80A/3ph — 63A MCCB, 30mA/4p RCD, 6xRCBO 20A, 4xRCBO 32A","unit":"set","price":"57,754.88"},
        {"page":39,"code":"1.1.17","description":"Surface mounted SDB-PUMP 320A/3ph — 250A MCCB, 100mA/4p RCD, 2xRCBO 20A, 32A RCBO, 200A RCBO, 16A MCB, 10A MCB","unit":"set","price":"63,972.18"},
        {"page":39,"code":"1.1.18","description":"Surface mounted SDB-EV/GF 400A/3ph — 320A MCCB, 100mA/4p RCD, 8x50A MCB","unit":"set","price":"114,433.31"},
        {"page":39,"code":"1.1.19","description":"Surface mounted SDB-EV/IBF/A 630A/3ph — 500A MCCB, 100mA/4p RCD, 12x50A MCB","unit":"set","price":"108,563.36"},
        {"page":39,"code":"1.1.20","description":"Surface mounted SDB-EV/IBF/B 320A/3ph — 250A MCCB, 100mA/4p RCD, 6x50A MCB","unit":"set","price":"85,299.36"},
        {"page":39,"code":"1.1.21","description":"Surface mounted SDB-EV/2BF/B 400A/3ph — 320A MCCB, 100mA/4p RCD, 7x50A MCB","unit":"set","price":"109,931.36"},
        {"page":39,"code":"1.1.21A","description":"Floor standing indoor distribution board IP44 (CMDB) 800A — 630A + 500A + 160A MCCB, 50A MCB, 100KA surge, ammeters, CTs","unit":"set","price":"291,661.90"},
        {"page":40,"code":"1.1.22","description":"Floor standing MDB-EV/1BF 160A/3ph — 1250A MCCB, 500mA/4p RCD, 10x40A/1ph, 10x50A/3ph, 250A MCCB, 500A MCCB","unit":"set","price":"525,808.40"},
        {"page":40,"code":"1.1.23","description":"Semi-Flush Mounted Distribution Board (SDB-PM) — 80A/3ph main, 3x40A, 3x32A, 80A bus bar","unit":"set","price":"63,081.85"},
        {"page":40,"code":"2.1.1","description":"Light point — Conductor (2x2.5mm²) w/ 10m avg distance, PVC conduit 16mm, junction box, connector","unit":"PCS","price":"—"},
        {"page":40,"code":"2.1.2","description":"Light point — Conductor (3x2.5mm²) w/ 10m avg distance, PVC conduit 16mm","unit":"PCS","price":"3,752.54"},
        {"page":40,"code":"2.1.3","description":"Light point — Conductor (3x4mm²) w/ 10m avg distance, PVC conduit 25mm","unit":"PCS","price":"4,882.94"},
        {"page":40,"code":"2.1.4","description":"Light point — Conductor (3x4mm²) w/ 10m avg distance, PVC conduit 50mm","unit":"PCS","price":"6,287.34"},
        {"page":40,"code":"3.1.1","description":"Power cable (3x4mm²) w/ 10m avg distance, PVC conduit 25mm","unit":"PCS","price":"7,241.64"},
        {"page":40,"code":"3.1.2","description":"Power cable (3x6mm²) w/ 10m avg distance, PVC conduit 25mm","unit":"PCS","price":"6,453.94"},
        {"page":40,"code":"3.1.3","description":"Power cable (5x4mm²) w/ 10m avg point length, PVC conduit 25mm","unit":"PCS","price":"9,852.64"},
        {"page":40,"code":"3.1.4","description":"Power cable (2x2.5mm²) w/ 10m avg distance, PVC conduit 16mm","unit":"PCS","price":"9,156.94"},
        {"page":40,"code":"3.1.5","description":"Power cable (3x2.5mm²) w/ 10m avg distance, PVC conduit 25mm","unit":"PCS","price":"3,665.64"},
        {"page":40,"code":"3.1.6","description":"Power cable (5x2.5mm²) w/ 10m avg distance, PVC conduit 25mm","unit":"PCS","price":"4,852.64"},
        {"page":40,"code":"4.1.1","description":"Normal switch","unit":"pcs","price":"317.90"},
        {"page":40,"code":"4.1.2","description":"Flush mounted single switch 774001+774041","unit":"PCS","price":"517.14"},
        {"page":41,"code":"4.1.3","description":"Flush mounted 2 gang single switch 774005+774041","unit":"PCS","price":"641.01"},
        {"page":41,"code":"4.1.4","description":"Flush mounted 2 gang two way switch 774005+774041","unit":"PCS","price":"641.01"},
        {"page":41,"code":"4.1.5","description":"Flush mounted two way switch 774005+774041","unit":"PCS","price":"517.14"},
        {"page":41,"code":"4.1.6","description":"Triple switch","unit":"PCS","price":"736.93"},
        {"page":41,"code":"4.1.7","description":"Intermediate switch","unit":"PCS","price":"576.14"},
        {"page":41,"code":"5.1.2","description":"Socket outlet — Power cable (3x6mm²), PVC conduit 25mm, 10m avg","unit":"PCS","price":"6,443.94"},
        {"page":41,"code":"5.1.3","description":"Socket outlet — Power cable (3x2.5mm²), PVC conduit 16mm, 10m avg","unit":"PCS","price":"9,852.64"},
        {"page":41,"code":"5.1.4","description":"Socket outlet — Power cable (3x2.5mm²), PVC conduit 25mm, 10m avg","unit":"PCS","price":"4,672.64"},
        {"page":41,"code":"5.1.5","description":"Socket outlet — Power cable (3x2.5mm²), Conduit 32mm, 10m avg","unit":"PCS","price":"4,852.64"},
        {"page":41,"code":"6.1.1","description":"16A/1P or 25A/1P power outlet points — PVC sheathed 3x2.5mm², conduit 16mm (25m avg, incl. fan outlets)","unit":"PCS","price":"9,856.27"},
        {"page":41,"code":"6.1.3","description":"16A/1P or 25A/1P outlet points — PVC 3x4mm² inside PVC conduit 25mm with accessories (10m avg)","unit":"PCS","price":"5,995.22"},
        {"page":41,"code":"6.1.4","description":"16A/3P or 25A/3P power outlet points — PVC 3x6mm² inside PVC conduit 25mm (10m avg)","unit":"PCS","price":"9,676.61"},
        {"page":41,"code":"6.1.5","description":"32A/3P power outlet points (Conference AHU Chiller) — 5x6mm² conduit 32mm (10m avg)","unit":"PCS","price":"15,567.97"},
        {"page":41,"code":"6.1.6","description":"32A/3P power outlet points — PVC 3x10mm² in conduit 32mm (10m avg)","unit":"PCS","price":"15,564.90"},
        {"page":41,"code":"6.1.7","description":"50A/3P Power outlet point for Lift machine — 5x10mm² in conduit 50mm (10m avg)","unit":"PCS","price":"24,939.56"},
        {"page":41,"code":"7.1.1","description":"Single socket economic /h.3","unit":"PCS","price":"294.36"},
        {"page":41,"code":"7.1.2","description":"Flush mounting single socket of 10A/1P","unit":"PCS","price":"568.11"},
        {"page":41,"code":"7.1.3","description":"Flush mounted Socket outlet","unit":"PCS","price":"568.11"},
        {"page":41,"code":"7.1.4","description":"Flush mounted Socket outlet twin","unit":"PCS","price":"590.81"},
        {"page":41,"code":"7.1.5","description":"Flush mounted Socket outlet 20A/1P","unit":"PCS","price":"1,848.57"},
        {"page":41,"code":"7.1.6","description":"Flush mounted Socket outlet for water heater","unit":"PCS","price":"859.62"},
        {"page":42,"code":"7.1.7","description":"Industrial type Socket outlet 16A/1P — Legrand p17 tempa 55553","unit":"PCS","price":"3,159.05"},
        {"page":42,"code":"7.1.8","description":"Industrial type Socket outlet 32A/3P — Legrand p17 tempa 55558","unit":"PCS","price":"3,782.05"},
        {"page":42,"code":"8.1.1","description":"Panel LED 30×30 24W 2400lm 110 lm/W 3000K","unit":"PCS","price":"1,139.66"},
        {"page":42,"code":"8.1.2","description":"Panel LED 30×60 36W 3600lm 3000-4000K","unit":"PCS","price":"3,314.20"},
        {"page":42,"code":"8.1.3","description":"Panel LED 60×60 48W 4800lm 3500-4000K","unit":"PCS","price":"3,401.39"},
        {"page":42,"code":"8.1.4","description":"Panel LED 30×120 36W 3860lm 4000K","unit":"PCS","price":"3,867.05"},
        {"page":42,"code":"8.1.5","description":"Panel LED 60×120 60W 6000lm 4000-6000K","unit":"PCS","price":"4,932.73"},
        {"page":42,"code":"8.1.6.1","description":"Phillips Fluorescent with Luminaire / LED — 1x18W","unit":"PCS","price":"2,630.87"},
        {"page":42,"code":"8.1.6.2","description":"Phillips Fluorescent — 2x18W (Lower)","unit":"PCS","price":"3,955.87"},
        {"page":42,"code":"8.1.6.3","description":"Phillips Fluorescent — 3x18W","unit":"PCS","price":"5,655.87"},
        {"page":42,"code":"8.1.6.4","description":"Phillips Fluorescent — 4x18W (Lower)","unit":"PCS","price":"6,455.87"},
        {"page":42,"code":"8.1.6.5","description":"Phillips Fluorescent — 1x36W","unit":"PCS","price":"3,955.87"},
        {"page":42,"code":"8.1.6.6","description":"Phillips Fluorescent — 2x36W (Lower)","unit":"PCS","price":"5,155.87"},
        {"page":42,"code":"8.1.6.7","description":"TMW 065/1-36 with 1 x TLD 36W","unit":"PCS","price":"5,655.87"},
        {"page":42,"code":"8.1.6.8","description":"Emergency lamp with 3hr kit","unit":"PCS","price":"5,657.01"},
        {"page":42,"code":"8.1.6.9","description":"Directional led Sign light EXIT","unit":"PCS","price":"4,162.67"},
        {"page":42,"code":"8.2.1","description":"Gate column Light with lamp","unit":"PCS","price":"2,415.36"},
        {"page":42,"code":"8.2.2","description":"Gate column Light with lamp","unit":"PCS","price":"4,162.67"},
        {"page":42,"code":"8.2.3","description":"Gate column Light with lamp","unit":"PCS","price":"4,162.67"},
        {"page":42,"code":"8.2.4","description":"Gate column Light with lamp","unit":"PCS","price":"5,936.58"},
        {"page":42,"code":"8.2.4b","description":"JKF Water proof 6 way 3up+3down white oval led light","unit":"PCS","price":"1,235.71"},
        {"page":42,"code":"8.2.5","description":"JKF Water proof 8 way 4up + outdoor warm white oval led light","unit":"PCS","price":"1,617.16"},
        {"page":43,"code":"8.2.6","description":"JKF Water proof 10 way 5up+5down white oval led light","unit":"PCS","price":"2,007.36"},
        {"page":43,"code":"8.2.7","description":"Water proof 6 way 3up+3down Neon strip outdoor warm white led light front","unit":"PCS","price":"2,388.76"},
        {"page":43,"code":"8.2.8","description":"JKF Water proof 8 way 4up warm white oval led light door","unit":"PCS","price":"1,856.58"},
        {"page":43,"code":"8.2.9","description":"JKF Water proof 6 outdoor warm white way 3up+3down led light","unit":"PCS","price":"1,856.58"},
        {"page":43,"code":"8.3.1","description":"Panel LED 30×30 24W 2400lm 110 lm/W 3000K (High Quality)","unit":"PCS","price":"2,297.05"},
        {"page":43,"code":"8.3.2","description":"Panel LED 30×60 36W 3600lm 10000lm 3000-4000K","unit":"PCS","price":"3,467.05"},
        {"page":43,"code":"8.3.3","description":"Panel LED 60×60 48W 4800lm 10000lm 3500-4000K","unit":"PCS","price":"6,819.05"},
        {"page":43,"code":"8.3.4","description":"Panel LED 60×120 60W 6000lm 10000lm 3500-4000K","unit":"PCS","price":"7,057.05"},
        {"page":43,"code":"8.4.1","description":"Led Flood Light (Pawza) 50w","unit":"PCS","price":"3,250.00"},
        {"page":43,"code":"8.4.2","description":"Led Flood Light (Pawza) 100w","unit":"PCS","price":"4,250.00"},
        {"page":43,"code":"8.4.3","description":"Led Flood Light (Pawza) 150w","unit":"PCS","price":"6,850.00"},
        {"page":43,"code":"8.4.4","description":"Led Flood Light (Pawza) 200w","unit":"PCS","price":"8,150.00"},
        {"page":43,"code":"9.1.1","description":"Early Streamer Emission (ESE) Protector SI 40, 5m mast H=53m","unit":"PCS","price":"244,810.88"},
        {"page":43,"code":"9.1.2","description":"ESE Protector SI 60, 5m mast H=53m","unit":"PCS","price":"262,050.88"},
        {"page":43,"code":"9.1.3","description":"ESE Protector SI 70, 5m mast H=53m","unit":"PCS","price":"262,050.88"},
        {"page":43,"code":"9.1.4","description":"ESE Protector SI 125, 5m mast H=53m","unit":"PCS","price":"279,310.88"},
        {"page":43,"code":"9.1.5","description":"16mm Air Termination circular galvanized steel rod 1.0m","unit":"PCS","price":"1,954.09"},
        {"page":43,"code":"9.1.6","description":"25 x 3mm insulated copper tape with vertical support every 1m","unit":"ml","price":"5,482.76"},
        {"page":43,"code":"9.1.7","description":"1x70mm² galvanized Steel earth conductor ring","unit":"ml","price":"531.71"},
        {"page":43,"code":"9.1.8","description":"30x3.5mm galvanized steel ring earth termination net work","unit":"ml","price":"902.64"},
        {"page":43,"code":"9.1.9","description":"1500mm long 50x50x3mm X-head galvanized steel earth rod + accessories","unit":"PCS","price":"6,791.12"},
        {"page":43,"code":"9.1.10","description":"Bonding materials for down conductor with air termination","unit":"PCS","price":"135,975.46"},
        {"page":43,"code":"9.1.11","description":"Equipotential (Earthing) bonding copper bar 1500x50x10mm — 7 bolted terminal","unit":"PCS","price":"68,874.15"},
        {"page":44,"code":"9.2.1","description":"1x185mm² Bare copper bonding conductor","unit":"ml","price":"2,644.09"},
        {"page":44,"code":"9.2.2","description":"1x150mm² Bare copper bonding conductor","unit":"ml","price":"2,444.09"},
        {"page":44,"code":"9.2.3","description":"1x120mm² Bare copper bonding conductor","unit":"ml","price":"2,114.09"},
        {"page":44,"code":"9.2.4","description":"1x70mm² Bare copper bonding conductor","unit":"ml","price":"1,748.03"},
        {"page":44,"code":"9.2.5","description":"1x50mm² Bare copper bonding conductor","unit":"ml","price":"1,314.70"},
        {"page":44,"code":"9.2.6","description":"1x25mm² Bare copper bonding conductor","unit":"ml","price":"975.68"},
        {"page":44,"code":"9.2.7","description":"1x16mm² Bare copper bonding conductor","unit":"ml","price":"975.68"},
        {"page":44,"code":"9.2.8","description":"1x10mm² Bare copper bonding conductor","unit":"ml","price":"609.80"},
        {"page":44,"code":"9.2.9","description":"1x6mm² Bare copper bonding conductor","unit":"ml","price":"407.84"},
        {"page":44,"code":"9.3.1","description":"2400x16mm copper earth rod","unit":"PCS","price":"4,841.92"},
        {"page":44,"code":"9.3.2","description":"1500x16mm copper earth rod","unit":"PCS","price":"3,994.09"},
        {"page":44,"code":"9.3.3","description":"3000x20mm copper earth rod","unit":"PCS","price":"7,061.20"},
        {"page":44,"code":"10.1.1","description":"2x2.5 mm² Cable","unit":"ml","price":"275.46"},
        {"page":44,"code":"10.1.2","description":"3x2.5 mm² Cable","unit":"ml","price":"389.59"},
        {"page":44,"code":"10.1.3","description":"3x4 mm² Cable","unit":"ml","price":"556.68"},
        {"page":44,"code":"10.1.4","description":"3x6 mm² Cable","unit":"ml","price":"914.59"},
        {"page":44,"code":"10.1.5","description":"3x10 mm² Cable","unit":"ml","price":"1,489.80"},
        {"page":44,"code":"10.1.6","description":"5x4 mm² Cable","unit":"ml","price":"855.66"},
        {"page":44,"code":"10.1.7","description":"5x6 mm² Cable","unit":"ml","price":"1,455.60"},
        {"page":44,"code":"10.1.8","description":"5x10 mm² Cable","unit":"ml","price":"2,286.47"},
        {"page":44,"code":"10.1.9","description":"5x16 mm² Cable","unit":"ml","price":"3,872.50"},
        {"page":44,"code":"10.1.10","description":"2x2.5 mm² Cable with conduit 16mm","unit":"ml","price":"387.50"},
        {"page":44,"code":"10.1.11","description":"3x4 mm² Cable with conduit 20mm","unit":"ml","price":"668.72"},
        {"page":44,"code":"10.1.12","description":"3x6 mm² Cable with conduit 25mm","unit":"ml","price":"1,031.89"},
        {"page":44,"code":"10.1.13","description":"3x10 mm² Cable with conduit 32mm","unit":"ml","price":"1,633.35"},
        {"page":44,"code":"10.1.14","description":"5x4 mm² Cable with conduit 25mm","unit":"ml","price":"946.74"},
        {"page":44,"code":"10.1.15","description":"5x6 mm² Cable with conduit 32mm","unit":"ml","price":"1,528.35"},
        {"page":44,"code":"10.1.16","description":"5x10 mm² Cable with conduit 36mm","unit":"ml","price":"2,364.47"},
        {"page":44,"code":"10.1.17","description":"5x16 mm² Cable with conduit 50mm","unit":"ml","price":"4,009.45"},
        {"page":44,"code":"10.1.18","description":"3x25/16","unit":"ml","price":"4,237.72"},
        {"page":44,"code":"10.1.19","description":"3x35/16","unit":"ml","price":"5,607.29"},
        {"page":44,"code":"10.1.20","description":"3x95/50","unit":"ml","price":"13,915.98"},
        {"page":44,"code":"10.1.21","description":"3x240/120","unit":"ml","price":"35,783.38"},
        {"page":44,"code":"10.1.22","description":"3x70/35+35 mm²","unit":"ml","price":"12,582.94"},
        {"page":45,"code":"10.1.23","description":"3x50/25+1x25 mm²","unit":"ml","price":"8,090.76"},
        {"page":45,"code":"10.1.24","description":"3x25/16+1x16 mm²","unit":"ml","price":"4,963.59"},
        {"page":45,"code":"10.1.25","description":"3x35/16+1x16 mm²","unit":"ml","price":"6,333.15"},
        {"page":45,"code":"10.1.26","description":"3x120/70+1x70 mm²","unit":"ml","price":"21,265.98"},
        {"page":45,"code":"10.1.27","description":"3x150/70+1x70 mm²","unit":"ml","price":"24,918.15"},
        {"page":45,"code":"10.1.28","description":"3x185/95+1x95 mm²","unit":"ml","price":"33,226.85"},
        {"page":45,"code":"10.1.29","description":"3x240/120+1x120 mm²","unit":"ml","price":"40,764.68"},
        {"page":45,"code":"10.1.30","description":"3x300/150+1x150 mm²","unit":"ml","price":"47,247.29"},
        {"page":45,"code":"10.1.31","description":"1x150 mm²","unit":"ml","price":"6,214.46"},
        {"page":45,"code":"10.1.32","description":"1x70 mm²","unit":"ml","price":"2,873.44"},
        {"page":45,"code":"10.1.33","description":"1x25 mm²","unit":"ml","price":"1,076.16"},
        {"page":45,"code":"10.1.34","description":"1x16 mm²","unit":"ml","price":"804.53"},
        {"page":45,"code":"11.1.1","description":"Flexible pvc Pipe (Corrugated conduit) dia 16mm","unit":"ml","price":"56.34"},
        {"page":45,"code":"11.1.2","description":"Flexible pvc (Corrugated conduit) dia 25mm","unit":"ml","price":"76.31"},
        {"page":45,"code":"11.1.3","description":"Flexible pvc (Corrugated conduit) dia 32mm","unit":"ml","price":"107.09"},
        {"page":45,"code":"11.1.4","description":"Flexible pvc (Corrugated conduit) dia 50mm","unit":"ml","price":"145.50"},
        {"page":45,"code":"11.1.5","description":"PVC Pipe (Rigid conduit) 16mm","unit":"ml","price":"43.21"},
        {"page":45,"code":"11.1.6","description":"PVC Pipe (Rigid conduit) 25mm","unit":"ml","price":"43.21"},
        {"page":45,"code":"11.1.7","description":"PVC Pipe 32mm","unit":"ml","price":"93.09"},
        {"page":45,"code":"11.1.8","description":"PVC Pipe 36mm","unit":"ml","price":"98.34"},
        {"page":45,"code":"11.1.9","description":"PVC Pipe 50mm","unit":"ml","price":"173.65"},
        {"page":45,"code":"11.1.10","description":"PVC Pipe 75mm","unit":"ml","price":"204.08"},
        {"page":45,"code":"11.1.11","description":"PVC Pipe 80mm","unit":"ml","price":"325.31"},
        {"page":45,"code":"11.1.12","description":"PVC Pipe 110mm","unit":"ml","price":"375.02"},
        {"page":45,"code":"11.1.13","description":"PVC Pipe 160mm","unit":"ml","price":"938.07"},
        {"page":45,"code":"11.1.14","description":"PVC Pipe 200mm","unit":"ml","price":"1,135.89"},
        {"page":46,"code":"12.1.1","description":"High Quality Feeder Cable 2x2.5 mm²","unit":"ml","price":"456.70"},
        {"page":46,"code":"12.1.2","description":"High Quality Feeder Cable 3x2.5 mm²","unit":"ml","price":"566.95"},
        {"page":46,"code":"12.1.3","description":"High Quality Feeder Cable 3x4 mm²","unit":"ml","price":"847.30"},
        {"page":46,"code":"12.1.4","description":"High Quality Feeder Cable 3x6 mm²","unit":"ml","price":"1,170.70"},
        {"page":46,"code":"12.1.5","description":"High Quality Feeder Cable 3x10 mm²","unit":"ml","price":"1,774.45"},
        {"page":46,"code":"12.1.6","description":"High Quality Feeder Cable 5x4 mm²","unit":"ml","price":"841.54"},
        {"page":46,"code":"12.1.7","description":"High Quality Feeder Cable 5x6 mm²","unit":"ml","price":"1,685.20"},
        {"page":46,"code":"12.1.8","description":"High Quality Feeder Cable 5x10 mm²","unit":"ml","price":"3,026.49"},
        {"page":46,"code":"12.1.9","description":"High Quality Feeder Cable 5x16 mm²","unit":"ml","price":"4,658.13"},
        {"page":46,"code":"12.1.10","description":"Feeder Cable 2x2.5 mm² + conduit 16mm","unit":"ml","price":"517.74"},
        {"page":46,"code":"12.1.11","description":"Feeder Cable 3x4 mm² + conduit 20mm","unit":"ml","price":"908.34"},
        {"page":46,"code":"12.1.12","description":"Feeder Cable 3x6 mm² + conduit 25mm","unit":"ml","price":"1,236.99"},
        {"page":46,"code":"12.1.13","description":"Feeder Cable 3x10 mm² + conduit 32mm","unit":"ml","price":"1,866.99"},
        {"page":46,"code":"12.1.14","description":"Feeder Cable 5x4 mm² + conduit 25mm","unit":"ml","price":"913.09"},
        {"page":46,"code":"12.1.15","description":"Feeder Cable 5x6 mm² + conduit 32mm","unit":"ml","price":"1,777.74"},
        {"page":46,"code":"12.1.16","description":"Feeder Cable 5x10 mm² + conduit 36mm","unit":"ml","price":"3,094.49"},
        {"page":46,"code":"12.1.17","description":"Feeder Cable 5x16 mm² + conduit 50mm","unit":"ml","price":"4,795.08"},
        {"page":46,"code":"12.1.18","description":"Feeder Cable 3x25/16 mm²","unit":"ml","price":"5,134.98"},
        {"page":46,"code":"12.1.19","description":"Feeder Cable 3x35/16 mm²","unit":"ml","price":"6,373.98"},
        {"page":46,"code":"12.1.20","description":"Feeder Cable 3x95/50 mm²","unit":"ml","price":"15,071.13"},
        {"page":46,"code":"12.1.21","description":"Feeder Cable 3x240/120 mm²","unit":"ml","price":"40,554.67"},
        {"page":46,"code":"12.1.22","description":"Feeder Cable 3x70/35+35 mm²","unit":"ml","price":"14,432.51"},
        {"page":46,"code":"12.1.23","description":"Feeder Cable 3x50/25+1x25 mm²","unit":"ml","price":"9,669.93"},
        {"page":46,"code":"12.1.24","description":"Feeder Cable 3x25/16+1x16 mm²","unit":"ml","price":"5,833.72"},
        {"page":46,"code":"12.1.25","description":"Feeder Cable 3x35/16+1x16 mm²","unit":"ml","price":"7,072.72"},
        {"page":46,"code":"12.1.26","description":"Feeder Cable 3x120/70+1x70 mm²","unit":"ml","price":"25,882.36"},
        {"page":46,"code":"12.1.27","description":"Feeder Cable 3x150/70+1x70 mm²","unit":"ml","price":"29,718.68"},
        {"page":46,"code":"12.1.28","description":"Feeder Cable 3x185/95+1x95 mm²","unit":"ml","price":"33,811.05"},
        {"page":46,"code":"12.1.29","description":"Feeder Cable 3x240/120+1x120 mm²","unit":"ml","price":"50,451.93"},
        {"page":46,"code":"12.1.30","description":"Feeder Cable 3x300/150+1x150 mm²","unit":"ml","price":"63,919.46"},
        {"page":47,"code":"12.1.31","description":"Feeder Cable 1x150 mm²","unit":"ml","price":"6,308.60"},
        {"page":47,"code":"12.1.32","description":"Feeder Cable 1x70 mm²","unit":"ml","price":"3,399.35"},
        {"page":47,"code":"12.1.33","description":"Feeder Cable 1x25 mm²","unit":"ml","price":"1,208.87"},
        {"page":47,"code":"12.1.34","description":"Feeder Cable 1x16 mm²","unit":"ml","price":"1,044.98"},
        {"page":47,"code":"13.1.1","description":"Double strip light","unit":"ml","price":"246.26"},
        {"page":47,"code":"13.1.2","description":"Triple strip light","unit":"ml","price":"309.26"},
        {"page":47,"code":"13.1.3","description":"RGB strip light","unit":"ml","price":"297.10"},
        {"page":47,"code":"13.1.4","description":"Neon Strip light","unit":"ml","price":"300.20"},
        {"page":47,"code":"13.1.5","description":"Aluminium profile for strip light (in Gypsum board)","unit":"ml","price":"683.86"},
        {"page":47,"code":"14.1.1","description":"Galvanized steel Cable tray 50*50mm","unit":"ml","price":"2,073.29"},
        {"page":47,"code":"14.1.2","description":"Galvanized steel Cable tray 150*50mm","unit":"ml","price":"2,491.91"},
        {"page":47,"code":"14.1.3","description":"Galvanized steel Cable tray 100*100mm","unit":"ml","price":"2,901.47"},
        {"page":47,"code":"14.1.4","description":"Galvanized steel Cable tray 100*50mm","unit":"ml","price":"2,207.22"},
        {"page":47,"code":"14.1.5","description":"Galvanized steel Cable tray 200*50mm","unit":"ml","price":"2,901.47"},
        {"page":47,"code":"14.1.7","description":"Galvanized steel Cable tray 200*100mm","unit":"ml","price":"3,522.34"},
        {"page":47,"code":"14.1.8","description":"Galvanized steel Cable tray 500*200mm","unit":"ml","price":"7,113.69"},
        {"page":47,"code":"15.1.1","description":"Galvanized steel cable ladder 100*100mm","unit":"ml","price":"2,786.39"},
        {"page":47,"code":"15.1.2","description":"Galvanized steel cable ladder 100*50mm","unit":"ml","price":"2,628.19"},
        {"page":47,"code":"15.1.3","description":"Galvanized steel cable ladder 200*50mm","unit":"ml","price":"2,786.39"},
        {"page":47,"code":"15.1.4","description":"Galvanized steel cable ladder 200*100mm","unit":"ml","price":"3,434.78"},
        {"page":47,"code":"15.1.5","description":"Galvanized steel cable ladder 300*100mm","unit":"ml","price":"3,854.78"},
        {"page":47,"code":"16.1.1","description":"PVC trucking 60*40 MM","unit":"ml","price":"701.04"},
        {"page":47,"code":"16.1.2","description":"PVC trucking 40*25 MM","unit":"ml","price":"564.54"},
        {"page":47,"code":"16.1.3","description":"PVC trucking 25*25 MM","unit":"ml","price":"300.39"},
        {"page":47,"code":"16.1.4","description":"PVC trucking 16*16 MM","unit":"ml","price":"242.74"},
        {"page":47,"code":"17.1.1","description":"Cat6A UTP Cable 4-Pair, 23AWG, LSZH, 500MHz, 10Gbps","unit":"m","price":"249.43"},
        {"page":47,"code":"17.1.2","description":"Single Data Outlet 1 x RJ45 Cat6A","unit":"Pcs","price":"909.47"},
        {"page":47,"code":"17.1.3","description":"Double Data Outlet 2 x RJ45 Cat6A","unit":"Pcs","price":"1,411.67"},
        {"page":47,"code":"17.1.4","description":"Cat6A Patch Panel 24 Port","unit":"Pcs","price":"7,600.49"},
        {"page":47,"code":"17.1.5","description":"Cat6A Patch Panel 48 Port","unit":"Pcs","price":"11,135.20"},
        {"page":47,"code":"17.1.6","description":"Main Server Rack (MDF) 42U Floor Standing Rack","unit":"Pcs","price":"148,891.58"},
        {"page":47,"code":"17.1.7","description":"Network Cabinet 42U Rack Cabinet","unit":"Pcs","price":"148,891.58"},
        {"page":47,"code":"17.1.8","description":"IDF Cabinet 12U Wall Mounted Rack","unit":"Pcs","price":"36,185.49"},
        {"page":48,"code":"17.1.9","description":"Fiber Patch Panel 48 Port","unit":"Pcs","price":"40,025.72"},
        {"page":48,"code":"17.1.10","description":"Cat6A Patch Cord 1 Meter","unit":"Pcs","price":"410.93"},
        {"page":48,"code":"17.1.11","description":"Cat6A Patch Cord 3 Meter","unit":"Pcs","price":"926.02"},
        {"page":48,"code":"17.1.12","description":"Fiber Patch Panel (LIU) 24 Port LC Duplex","unit":"Pcs","price":"33,576.79"},
        {"page":48,"code":"17.1.13","description":"SFP Module 10G Single Mode SFP+","unit":"Pcs","price":"15,294.67"},
        {"page":48,"code":"17.1.14","description":"Media Converter Fiber to Copper","unit":"Pcs","price":"8,277.12"},
        {"page":48,"code":"17.2.1","description":"Active Device","unit":"Pcs","price":"325,162.67"},
        {"page":48,"code":"17.2.2","description":"Access Switch 24 Port Managed PoE+","unit":"Pcs","price":"98,454.43"},
        {"page":48,"code":"17.2.3","description":"Access Switch 48 Port Managed PoE+","unit":"Pcs","price":"142,424.44"},
        {"page":48,"code":"17.2.4","description":"Telephone Distribution Frame 100 Pair Krone Type","unit":"Pcs","price":"18,916.21"},
        {"page":48,"code":"17.2.5","description":"Network Video Recorder 64 Channel NVR","unit":"Pcs","price":"331,901.75"},
        {"page":48,"code":"17.2.6","description":"Wireless Access Point Wi-Fi 6 Dual Band","unit":"Pcs","price":"195,784.50"},
        {"page":48,"code":"17.2.7","description":"Dome Camera 4MP/12MP IP Camera","unit":"Pcs","price":"26,365.34"},
        {"page":48,"code":"17.2.8","description":"Bullet Camera 4MP/12MP IP Camera","unit":"Pcs","price":"26,626.21"},
        {"page":48,"code":"17.2.9","description":"PTZ Camera 4MP, 25X Zoom","unit":"Pcs","price":"156,565.92"},
        {"page":48,"code":"17.2.10","description":"Addressable Fire Alarm Panel FACP one loop","unit":"Pcs","price":"322,459.76"},
        {"page":48,"code":"17.2.11","description":"Smoke Detector Addressable TEND","unit":"Pcs","price":"11,894.94"},
        {"page":48,"code":"17.2.12","description":"Heat Detector Addressable TEND","unit":"Pcs","price":"11,894.94"}
      ]
    },
    {
      "id": "LABOUR",
      "title": "LABOUR COST — HOURLY RATES (2018 4th Q)",
      "items": [
        {"page":50,"code":"L1","description":"Bar bender Ass.","unit":"Hourly","price":"90.00"},
        {"page":50,"code":"L2","description":"Bar bender","unit":"Hourly","price":"134.93"},
        {"page":50,"code":"L3","description":"Carpenter Ass.","unit":"Hourly","price":"97.61"},
        {"page":50,"code":"L4","description":"Carpenter","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L5","description":"Chisler","unit":"Hourly","price":"93.56"},
        {"page":50,"code":"L6","description":"DL","unit":"Hourly","price":"80.00"},
        {"page":50,"code":"L7","description":"Electrician helper","unit":"Hourly","price":"117.90"},
        {"page":50,"code":"L8","description":"Electrician","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L9","description":"Forman","unit":"Hourly","price":"161.91"},
        {"page":50,"code":"L10","description":"Gang chief","unit":"Hourly","price":"129.01"},
        {"page":50,"code":"L11","description":"Glazer","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L12","description":"Mason Ass.","unit":"Hourly","price":"90.00"},
        {"page":50,"code":"L13","description":"Mason","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L14","description":"Mixer operator","unit":"Hourly","price":"63.10"},
        {"page":50,"code":"L15","description":"Painter Assistance","unit":"Hourly","price":"82.51"},
        {"page":50,"code":"L16","description":"Painter","unit":"Hourly","price":"120.00"},
        {"page":50,"code":"L17","description":"Plasterer Ass.","unit":"Hourly","price":"84.26"},
        {"page":50,"code":"L18","description":"Plasterer","unit":"Hourly","price":"126.19"},
        {"page":50,"code":"L19","description":"Plumber helper","unit":"Hourly","price":"92.41"},
        {"page":50,"code":"L20","description":"Plumber","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L21","description":"Tiller Ass.","unit":"Hourly","price":"107.46"},
        {"page":50,"code":"L22","description":"Tiller","unit":"Hourly","price":"180.00"},
        {"page":50,"code":"L23","description":"Time Keeper","unit":"Hourly","price":"93.07"},
        {"page":50,"code":"L24","description":"Truck Driver","unit":"Hourly","price":"119.90"},
        {"page":50,"code":"L25","description":"Equipment operator I","unit":"Hourly","price":"89.05"},
        {"page":50,"code":"L26","description":"Equipment operator II","unit":"Hourly","price":"83.25"},
        {"page":50,"code":"L27","description":"Equipment operator III","unit":"Hourly","price":"78.82"},
        {"page":50,"code":"L28","description":"Vibrator operator","unit":"Hourly","price":"124.87"},
        {"page":50,"code":"L29","description":"L. Vehicle Driver I","unit":"Hourly","price":"97.56"},
        {"page":50,"code":"L30","description":"Surveyor","unit":"Hourly","price":"125.00"},
        {"page":50,"code":"L31","description":"Welder","unit":"Hourly","price":"180.00"},
        {"page":51,"code":"L32","description":"Welder Ass.","unit":"Hourly","price":"80.65"},
        {"page":51,"code":"L33","description":"Aluminium worker","unit":"Hourly","price":"180.00"},
        {"page":51,"code":"L34","description":"Aluminium worker Ass.","unit":"Hourly","price":"81.89"},
        {"page":51,"code":"L35","description":"Mud worker","unit":"Hourly","price":"81.29"}
      ]
    },
    {
      "id": "EQUIPMENT",
      "title": "EQUIPMENT COST — HOURLY RENTAL RATES (2018 4th Q)",
      "items": [
        {"page":52,"code":"EQ1","description":"Truck 16m³","unit":"Hourly","price":"7,009.20"},
        {"page":52,"code":"EQ2","description":"Truck 9m³","unit":"Hourly","price":"2,560.36"},
        {"page":52,"code":"EQ3","description":"Truck 13m³","unit":"Hourly","price":"3,251.20"},
        {"page":52,"code":"EQ4","description":"Compactor","unit":"Hourly","price":"678.05"},
        {"page":52,"code":"EQ5","description":"Wheel Loader 200HP (1.5-2.5m³)","unit":"Hourly","price":"6,297.13"},
        {"page":52,"code":"EQ6","description":"Dozer 300 Hp (D7R)","unit":"Hourly","price":"9,610.35"},
        {"page":52,"code":"EQ7","description":"Dozer D7R W. Ripper","unit":"Hourly","price":"10,060.35"},
        {"page":52,"code":"EQ8","description":"Dozer (200-250HP)","unit":"Hourly","price":"8,867.34"},
        {"page":52,"code":"EQ9","description":"Excavater (200HP)","unit":"Hourly","price":"8,560.35"},
        {"page":52,"code":"EQ10","description":"Excavater (200HP) WITH RIPPER","unit":"Hourly","price":"9,131.04"},
        {"page":52,"code":"EQ11","description":"BACKHOE Excavater (120HP)","unit":"Hourly","price":"6,560.35"},
        {"page":52,"code":"EQ12","description":"Grader (120-150hp)","unit":"Hourly","price":"7,560.35"},
        {"page":52,"code":"EQ13","description":"Roller (8-10ton)","unit":"Hourly","price":"4,304.60"},
        {"page":52,"code":"EQ14","description":"Water Truck 13,000lt","unit":"Hourly","price":"4,195.20"},
        {"page":52,"code":"EQ15","description":"Air Compressor","unit":"Hourly","price":"3,657.34"},
        {"page":52,"code":"EQ16","description":"Hand Jack Hammer (electrical)","unit":"Hourly","price":"264.00"},
        {"page":52,"code":"EQ17","description":"Wagon Driller","unit":"Hourly","price":"9,465.22"},
        {"page":52,"code":"EQ18","description":"Small Vehicle (pick up 4WD)","unit":"Hourly","price":"1,251.54"},
        {"page":52,"code":"EQ19","description":"Asphalt Distributor","unit":"Hourly","price":"5,166.50"},
        {"page":52,"code":"EQ20","description":"Stationary Heater","unit":"Hourly","price":"3,451.86"},
        {"page":52,"code":"EQ21","description":"Power Broom","unit":"Hourly","price":"2,380.24"},
        {"page":52,"code":"EQ22","description":"Asphalt Plant","unit":"Hourly","price":"51,858.19"},
        {"page":52,"code":"EQ23","description":"Asphalt Paver","unit":"Hourly","price":"11,433.22"},
        {"page":52,"code":"EQ24","description":"Pneumatic Roller","unit":"Hourly","price":"4,133.65"},
        {"page":52,"code":"EQ25","description":"Water Tanker","unit":"Hourly","price":"38.05"},
        {"page":52,"code":"EQ26","description":"Dump Truck 16m³","unit":"Hourly","price":"2,784.53"},
        {"page":52,"code":"EQ27","description":"Crushing plant 75ton","unit":"Hourly","price":"19,952.80"},
        {"page":52,"code":"EQ28","description":"Centrifugal W/Pump","unit":"Hourly","price":"499.85"},
        {"page":52,"code":"EQ29","description":"Genrator (45kw)","unit":"Hourly","price":"935.89"},
        {"page":52,"code":"EQ30","description":"Mobile crane","unit":"Hourly","price":"7,609.20"},
        {"page":52,"code":"EQ31","description":"Concrete mixer (300lt)","unit":"Hourly","price":"519.22"},
        {"page":52,"code":"EQ32","description":"Concrete Mixer Truck","unit":"Hourly","price":"3,098.82"},
        {"page":53,"code":"EQ33","description":"Concrete Vibrator","unit":"Hourly","price":"266.09"},
        {"page":53,"code":"EQ34","description":"Hand tamper","unit":"Hourly","price":"110.47"},
        {"page":53,"code":"EQ35","description":"Pipe moulder","unit":"Hourly","price":"24.85"},
        {"page":53,"code":"EQ36","description":"Painting machine","unit":"Hourly","price":"1,253.57"},
        {"page":53,"code":"EQ37","description":"Hand Drill","unit":"Hourly","price":"20.71"},
        {"page":53,"code":"EQ38","description":"Gear machine","unit":"Hourly","price":"34.52"},
        {"page":53,"code":"EQ39","description":"Grinder","unit":"Hourly","price":"34.52"},
        {"page":53,"code":"EQ40","description":"Cutting disc (dia. 180)","unit":"Hourly","price":"162.00"},
        {"page":53,"code":"EQ41","description":"scafolding","unit":"Hourly","price":"117.60"},
        {"page":53,"code":"EQ42","description":"sledge hammer","unit":"Hourly","price":"6.28"},
        {"page":53,"code":"EQ43","description":"Tools","unit":"Hourly","price":"14.40"},
        {"page":53,"code":"EQ44","description":"Set of tools","unit":"Hourly","price":"22.80"},
        {"page":53,"code":"EQ45","description":"Surveying instrument","unit":"Hourly","price":"129.24"},
        {"page":53,"code":"EQ46","description":"Welding Machine","unit":"Hourly","price":"101.20"},
        {"page":53,"code":"EQ47","description":"Truck Crane Hydraulic, 20-25ton","unit":"Hourly","price":"5,383.58"},
        {"page":53,"code":"EQ48","description":"winch 3-phase","unit":"Hourly","price":"251.04"},
        {"page":53,"code":"EQ49","description":"winch single phase","unit":"Hourly","price":"188.28"},
        {"page":53,"code":"EQ50","description":"Genrator 3-phase","unit":"Hourly","price":"502.08"},
        {"page":53,"code":"EQ51","description":"Genrator single phase","unit":"Hourly","price":"313.80"},
        {"page":53,"code":"EQ52","description":"Genrator for winch 3-phase","unit":"Hourly","price":"403.92"}
      ]
    }
  ]
};
END
cat > src/data/ratebook.js << 'END'
import { putAll, getAll, clearStore, put, getAllBy } from './db.js';
import { RATEBOOK } from './ratebook-data.js';

function normalizeItem(catId, item, idx) {
  const rawPrice = String(item.price || '').replace(/,/g, '').trim();
  const price = rawPrice === '' || rawPrice === '—' ? null : parseFloat(rawPrice);
  return {
    id: catId + ':' + (item.code || idx) + ':' + idx,
    categoryId: catId,
    code: item.code || '',
    description: item.description || '',
    unit: item.unit || '',
    basePrice: price,
    contractorPrice: price,
    page: item.page || 0
  };
}

export async function importRateBook(json) {
  const src = json || RATEBOOK;
  if (!src || !Array.isArray(src.categories)) throw new Error('Invalid rate book data — missing "categories"');
  const categories = [];
  const items = [];
  src.categories.forEach(cat => {
    const catId = String(cat.id);
    categories.push({ id: catId, title: cat.title || 'Untitled', itemCount: (cat.items || []).length });
    (cat.items || []).forEach((item, idx) => items.push(normalizeItem(catId, item, idx)));
  });
  await clearStore('ratebook_categories');
  await clearStore('ratebook_items');
  await putAll('ratebook_categories', categories);
  await putAll('ratebook_items', items);
  await put('meta', {
    key: 'ratebook_source',
    source: src.source || '',
    document: src.document || '',
    quarter: src.quarter || '',
    currency: src.currency || 'ETB',
    importedAt: new Date().toISOString(),
    categoryCount: categories.length,
    itemCount: items.length
  });
  return { categoryCount: categories.length, itemCount: items.length };
}

export async function seedFromModule() { return importRateBook(RATEBOOK); }

export async function getRateBookMeta() {
  const rows = await getAll('meta');
  return rows.find(r => r.key === 'ratebook_source') || null;
}
export async function getRateCategories() { return getAll('ratebook_categories'); }
export async function getRateItemsByCategory(catId) { return getAllBy('ratebook_items', 'by-category', catId); }
export async function getRateItems() { return getAll('ratebook_items'); }
export async function updateRateItem(id, patch) {
  const rows = await getAll('ratebook_items');
  const item = rows.find(r => r.id === id);
  if (!item) return null;
  const next = Object.assign({}, item, patch);
  await put('ratebook_items', next);
  return next;
}
export async function applyInflation(factor, alsoContractor = false) {
  const rows = await getAll('ratebook_items');
  const updated = rows.map(r => {
    if (r.basePrice == null) return r;
    const next = Object.assign({}, r, { basePrice: Math.round(r.basePrice * factor * 100) / 100 });
    if (alsoContractor) next.contractorPrice = next.basePrice;
    return next;
  });
  await putAll('ratebook_items', updated);
  return updated.length;
}
export async function resetContractorPrices() {
  const rows = await getAll('ratebook_items');
  const updated = rows.map(r => Object.assign({}, r, { contractorPrice: r.basePrice }));
  await putAll('ratebook_items', updated);
  return updated.length;
}
export async function clearRateBook() {
  await clearStore('ratebook_categories');
  await clearStore('ratebook_items');
  await clearStore('meta');
}
END
cat > src/data/requests.js << 'END'
import { put, getAll, del } from './db.js';
export async function saveRequest(req) { return put('quote_requests', req); }
export async function getRequests() { return getAll('quote_requests'); }
export async function deleteRequest(id) { return del('quote_requests', id); }
export async function updateRequestStatus(id, status) {
  const all = await getAll('quote_requests');
  const r = all.find(x => x.id === id);
  if (!r) return null;
  const next = Object.assign({}, r, { status });
  await put('quote_requests', next);
  return next;
}
export function newRequestId() { return 'req_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 6); }
END
cat > src/data/store.js << 'END'
import { useState, useEffect } from 'preact/hooks';
const KEY = 'mesay_data_v1';

export const DEFAULT_DATA = {
  business: {
    nameEn: 'Mesay Abebe General Contractor',
    nameAm: 'መሳይ አበበ አጠቃላይ ተቋራጭ',
    taglineEn: 'General Contractor (511114) · Building, Road & Renovation',
    taglineAm: 'አጠቃላይ ተቋራጭ (511114) · ህንፃ፣ መንገድ እና ማሻሻያ',
    subtitleEn: 'Licensed general contractor based in Gulele, Addis Ababa. Building construction, road works, renovation — plus construction materials delivered to your site.',
    subtitleAm: 'በአዲስ አበባ ጉለሌ ክፍለ ከተማ የተመዘገበ አጠቃላይ ተቋራጭ።',
    ownerName: 'Mr. MESAY ABEBE BAHIRE',
    fieldOfBusiness: '(511114) General Contractor Except water work',
    businessLicenseNo: 'GU/AA/14/668/717216/2010',
    principalRegNo: 'GU/AA/1/0006440/2009',
    previousLicenseNo: '980/2016',
    tin: '0054073141',
    capital: 'ETB 500,000.00',
    dateOfIssuance: '18/4/2010',
    renewalDate: '3/10/2018',
    businessLicenseIssued: '6/10/2026',
    bureau: 'Addis Ababa City Administration Trade Bureau',
    cell1: '+251 911 891 851',
    cell2: '+251 912 175 984',
    cell3: '+251 911 891 888',
    phone: '+251 911 891 851',
    tel: '0926803092',
    email: 'info@mesayabebe.et',
    region: 'Addis Ababa',
    zoneSubCity: 'Gulele',
    woreda: '08',
    houseNo: '185',
    addressEn: 'Gulele Sub-city, Woreda 08, House No. 185, Addis Ababa',
    addressAm: 'ጉለሌ ክፍለ ከተማ ወረዳ 08 ቤት ቁጥር 185 አዲስ አበባ',
    currency: 'ETB', vatRate: 0.15, validDays: 30,
    markupPct: 15, contingencyPct: 5, inflationFactor: 1.0,
    staffPassword: 'mesay2024',
    disclaimer: 'Rates based on Addis Ababa Design and Construction Works Bureau, 2018 4th Quarter, Direct Cost Only. Actual rates subject to site conditions and current market.',
    defaultTerms: '50% advance with order, balance on delivery. Prices valid 30 days. Subject to stock and site availability.'
  },
  services: [
    { id: 'sv1', icon: '🏢', titleEn: 'Building Construction', titleAm: 'የህንፃ ግንባታ', descEn: 'Residential, commercial and institutional buildings.' },
    { id: 'sv2', icon: '🛣️', titleEn: 'Road Works', titleAm: 'የመንገድ ስራ', descEn: 'Urban and rural roads, drainage, culverts, and asphalt.' },
    { id: 'sv3', icon: '🏗️', titleEn: 'Renovation & Fit-out', titleAm: 'ማሻሻያ እና ማስተካከያ', descEn: 'Interior fit-outs, structural retrofits, and finishing.' },
    { id: 'sv4', icon: '📦', titleEn: 'General Supply', titleAm: 'አጠቃላይ አቅርቦት', descEn: 'Construction materials, fixtures, and equipment supply.' }
  ],
  projects: [
    { id: 'p1', title: 'Bole Residential Building', type: 'building', icon: '🏢', desc: 'Multi-storey residential building.', budget: 'ETB 85,000,000', duration: '24 months', year: 2024, client: 'Private developer' },
    { id: 'p2', title: 'Gulele Access Road', type: 'road', icon: '🛣️', desc: '2.8 km asphalt access road with drainage.', budget: 'ETB 42,000,000', duration: '14 months', year: 2023, client: 'Sub-city administration' },
    { id: 'p3', title: 'Commercial Office Fit-out', type: 'building', icon: '🏢', desc: '1,800 m² office interior fit-out.', budget: 'ETB 28,000,000', duration: '8 months', year: 2023, client: 'Private client' }
  ],
  reviews: [
    { id: 'r1', name: 'Ato Bekele T.', loc: 'Addis Ababa', stars: 5, text: 'Delivered our residential building on schedule. Professional site management.' },
    { id: 'r2', name: 'Ato Dawit M.', loc: 'Gulele', stars: 5, text: 'Road quality met every spec. Good communication with our engineers.' },
    { id: 'r3', name: 'W/ro Hana G.', loc: 'Addis Ababa', stars: 5, text: 'Office fit-out finished on time and on budget.' }
  ],
  categories: [
    { id: 'cement',    name: 'Cement & Binders', nameAm: 'ሲሚንቶ', icon: '🧱' },
    { id: 'steel',     name: 'Steel & Rebar',    nameAm: 'ብረት', icon: '🔩' },
    { id: 'lumber',    name: 'Lumber & Timber',  nameAm: 'እንጨት', icon: '🪵' },
    { id: 'aggregate', name: 'Aggregates',       nameAm: 'ጠጠር እና አሸዋ', icon: '⛰️' },
    { id: 'fixtures',  name: 'Fixtures & Pipes', nameAm: 'ቧንቧ እና መለዋወጫ', icon: '🚰' }
  ],
  products: [
    { id: 'sku_cem_425', category: 'cement', name: 'Dangote / Mugher OPC 42.5N', unit: 'quintal (100 kg)', basePrice: 1050, contractorPrice: 1050, stock: 24000, leadTimeDays: 2, taxable: true, tiers: [ { min: 1, price: 1050 }, { min: 20, price: 1020 }, { min: 100, price: 990 } ] },
    { id: 'sku_cem_325', category: 'cement', name: 'PPC 32.5N Cement', unit: 'quintal (100 kg)', basePrice: 940, contractorPrice: 940, stock: 32000, leadTimeDays: 2, taxable: true, tiers: [ { min: 1, price: 940 }, { min: 20, price: 910 }, { min: 100, price: 880 } ] },
    { id: 'sku_reb_8',  category: 'steel', name: 'Rebar Ø8 mm — Deformed', unit: 'ton', basePrice: 132000, contractorPrice: 132000, stock: 180, leadTimeDays: 4, taxable: true, tiers: [ { min: 1, price: 132000 }, { min: 5, price: 129500 }, { min: 20, price: 126000 } ] },
    { id: 'sku_reb_12', category: 'steel', name: 'Rebar Ø12 mm — Deformed', unit: 'ton', basePrice: 130500, contractorPrice: 130500, stock: 240, leadTimeDays: 4, taxable: true, tiers: [ { min: 1, price: 130500 }, { min: 5, price: 128000 }, { min: 20, price: 124500 } ] },
    { id: 'sku_reb_16', category: 'steel', name: 'Rebar Ø16 mm — Deformed', unit: 'ton', basePrice: 129000, contractorPrice: 129000, stock: 160, leadTimeDays: 4, taxable: true, tiers: [ { min: 1, price: 129000 }, { min: 5, price: 126500 }, { min: 20, price: 123000 } ] },
    { id: 'sku_lum_pine', category: 'lumber', name: 'Pine Timber 2x4x4m', unit: 'piece', basePrice: 380, contractorPrice: 380, stock: 3200, leadTimeDays: 3, taxable: true, tiers: [ { min: 1, price: 380 }, { min: 50, price: 360 }, { min: 200, price: 340 } ] },
    { id: 'sku_agg_crushed', category: 'aggregate', name: 'Crushed Stone 20 mm', unit: 'm³', basePrice: 950, contractorPrice: 950, stock: 1800, leadTimeDays: 3, taxable: true, tiers: [ { min: 1, price: 950 }, { min: 10, price: 900 }, { min: 50, price: 850 } ] },
    { id: 'sku_agg_sand', category: 'aggregate', name: 'Washed River Sand', unit: 'm³', basePrice: 850, contractorPrice: 850, stock: 2200, leadTimeDays: 3, taxable: true, tiers: [ { min: 1, price: 850 }, { min: 10, price: 800 }, { min: 50, price: 750 } ] },
    { id: 'sku_fix_pvc110', category: 'fixtures', name: 'PVC Pipe Ø110 mm x 6 m', unit: 'piece', basePrice: 1650, contractorPrice: 1650, stock: 900, leadTimeDays: 2, taxable: true, tiers: [ { min: 1, price: 1650 }, { min: 20, price: 1580 }, { min: 100, price: 1500 } ] },
    { id: 'sku_fix_pvc63', category: 'fixtures', name: 'PVC Pipe Ø63 mm x 6 m', unit: 'piece', basePrice: 780, contractorPrice: 780, stock: 1400, leadTimeDays: 2, taxable: true, tiers: [ { min: 1, price: 780 }, { min: 20, price: 740 }, { min: 100, price: 700 } ] }
  ],
  freight: {
    zones: [
      { id: 'addis',    name: 'Addis Ababa',        flat: 800,  perTon: 40 },
      { id: 'nearby',   name: 'Within 100 km',      flat: 1800, perTon: 75 },
      { id: 'regional', name: 'Regional (100-400)', flat: 4500, perTon: 140 },
      { id: 'far',      name: 'Remote (> 400 km)',  flat: 9000, perTon: 220 }
    ]
  },
  hero: {
    badge1En: 'General Contractor 511114', badge1Am: 'አጠቃላይ ተቋራጭ 511114',
    badge2En: 'Trade Bureau Licensed', badge2Am: 'በንግድ ቢሮ ፈቃድ',
    badge3En: '18+ Years', badge3Am: '18+ ዓመታት'
  },
  stats: [
    { id: 's1', num: '120+', lblEn: 'Projects Delivered', lblAm: 'የተጠናቀቁ ፕሮጀክቶች' },
    { id: 's2', num: '18+',  lblEn: 'Years in Business',  lblAm: 'የንግድ ዓመታት' },
    { id: 's3', num: '511114', lblEn: 'License Code',     lblAm: 'የፈቃድ ኮድ' },
    { id: 's4', num: '100%', lblEn: 'VAT Registered',     lblAm: 'ተ.እ.ታ ተመዝጋቢ' }
  ]
};

function load() {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return DEFAULT_DATA;
    return Object.assign({}, DEFAULT_DATA, JSON.parse(raw));
  } catch (e) { return DEFAULT_DATA; }
}

let _state = load();
const subs = new Set();
export function getData() { return _state; }
export function subscribe(fn) { subs.add(fn); return () => subs.delete(fn); }
export function setData(next) {
  _state = next;
  try { localStorage.setItem(KEY, JSON.stringify(next)); } catch (e) {}
  subs.forEach(fn => fn(next));
}
export function resetData() { setData(DEFAULT_DATA); }
export function useStore() {
  const [d, setD] = useState(_state);
  useEffect(() => subscribe(setD), []);
  return [d, setData];
}
export function uid() { return 'id_' + Math.random().toString(36).slice(2, 9); }
END
npm install
echo 'Done! Run npm start'
