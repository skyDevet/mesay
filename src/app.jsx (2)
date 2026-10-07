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
