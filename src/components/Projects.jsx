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
