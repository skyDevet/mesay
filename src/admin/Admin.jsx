import { useState, useEffect } from 'preact/hooks';
import { useStore, resetData, uid } from '../data/store.js';
import { getRequests, updateRequestStatus, deleteRequest } from '../data/requests.js';
import { getProformas, deleteProforma, updateProformaStatus, duplicateProforma } from '../data/proformas.js';
import { ProFormaBuilder } from './ProFormaBuilder.jsx';
import { RateBookTab } from './RateBookTab.jsx';
import { BuildFromRateBook } from './BuildFromRateBook.jsx';

export function Admin({ onExit }) {
  const [data, setData] = useStore();
  const [tab, setTab] = useState('requests');
  const [builderSeed, setBuilderSeed] = useState(null);
  const [editPf, setEditPf] = useState(null);
  const update = (patch) => setData(Object.assign({}, data, patch));

  if (builderSeed !== null) return <ProFormaBuilder seed={builderSeed} editId={editPf} onDone={() => { setBuilderSeed(null); setEditPf(null); setTab('proformas'); }} onCancel={() => { setBuilderSeed(null); setEditPf(null); }} />;

  const tabs = [
    ['requests', '📥 Requests'], ['build', '🛠 Build'], ['proformas', '📄 Pro Formas'], ['ratebook', '📚 Rate Book'],
    ['business', '🏢 Business'], ['hero', '🎯 Hero'], ['stats', '📊 Stats'],
    ['services', '🛠 Services'], ['projects', '🏗 Projects'], ['catalog', '📦 Materials'],
    ['freight', '🚚 Freight'], ['reviews', '⭐ Reviews'], ['settings', '⚙️ Settings']
  ];
  return (
    <div class="admin">
      <header class="admin-header">
        <div><strong>Staff Portal</strong><span> · Mesay Abebe</span></div>
        <div class="admin-header-actions">
          <button class="btn-view" onClick={onExit}>👁 View Site</button>
          <button class="btn-danger" onClick={() => { if (confirm('Reset all business data to defaults? Rate book will not be cleared.')) resetData(); }}>↺ Reset Business</button>
        </div>
      </header>
      <div class="admin-tabs">{tabs.map(([k, l]) => (<button class={'admin-tab ' + (tab === k ? 'active' : '')} onClick={() => setTab(k)}>{l}</button>))}</div>
      <main class="admin-body">
        {tab === 'requests' && <RequestsTab onBuild={(r, pfId) => { setBuilderSeed(r); setEditPf(pfId || null); }} />}
        {tab === 'build' && <BuildFromRateBook onDone={() => setTab('proformas')} />}
        {tab === 'proformas' && <ProformasTab onEdit={(pf) => { setBuilderSeed(pf); setEditPf(pf.id); }} data={data} />}
        {tab === 'ratebook' && <RateBookTab />}
        {tab === 'business' && <BusinessTab data={data} update={update} />}
        {tab === 'hero' && <HeroTab data={data} update={update} />}
        {tab === 'stats' && <StatsTab data={data} update={update} />}
        {tab === 'services' && <ServicesTab data={data} update={update} />}
        {tab === 'projects' && <ProjectsTab data={data} update={update} />}
        {tab === 'catalog' && <CatalogTab data={data} update={update} />}
        {tab === 'freight' && <FreightTab data={data} update={update} />}
        {tab === 'reviews' && <ReviewsTab data={data} update={update} />}
        {tab === 'settings' && <SettingsTab data={data} update={update} />}
      </main>
    </div>
  );
}

function Field({ label, value, onChange, type = 'text' }) {
  return (<div class="admin-field"><label>{label}</label><input type={type} value={value} onInput={e => onChange(e.target.value)} /></div>);
}

function RequestsTab({ onBuild }) {
  const [list, setList] = useState([]); const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(true); const [selected, setSelected] = useState(null);
  const [quotedPf, setQuotedPf] = useState({});
  const refresh = async () => {
    setLoading(true);
    const r = await getRequests();
    r.sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''));
    setList(r);
    const pfs = await getProformas();
    const map = {};
    pfs.forEach(p => { if (p.requestId) map[p.requestId] = p; });
    setQuotedPf(map);
    setLoading(false);
  };
  useEffect(() => { refresh(); }, []);
  const filtered = filter === 'all' ? list : list.filter(r => r.status === filter);
  const setStatus = async (id, status) => { await updateRequestStatus(id, status); refresh(); };
  const remove = async (id) => { if (confirm('Delete request?')) { await deleteRequest(id); refresh(); } };
  return (
    <div class="admin-panel">
      <div class="admin-panel-head"><h2>Quote Requests ({list.length})</h2><button class="btn-back" onClick={refresh}>↻ Refresh</button></div>
      <div class="filters">{['all', 'new', 'in_progress', 'quoted', 'closed'].map(f => (<button class={'filter-btn ' + (filter === f ? 'active' : '')} onClick={() => setFilter(f)}>{f}</button>))}</div>
      {loading && <p>Loading...</p>}
      {!loading && filtered.length === 0 && <p style="color:var(--gray);">No requests.</p>}
      {filtered.map(r => {
        const linkedPf = quotedPf[r.id];
        return (
          <div class="admin-card">
            <div class="admin-card-head">
              <strong>{r.kind === 'materials' ? '📦 Materials' : '🛠 Services'} · {r.client.name}</strong>
              <span class={'pf-status ' + (r.status === 'new' ? 'draft' : r.status === 'quoted' ? 'accepted' : 'sent')}>{r.status}</span>
              <button class="btn-back" onClick={() => setSelected(selected && selected.id === r.id ? null : r)}>View</button>
              {linkedPf ? (
                <>
                  <button class="btn-back" onClick={() => onBuild(r, linkedPf.id)}>✎ Edit Pro Forma</button>
                  <span style="font-size:0.75rem;color:var(--success);font-weight:700;">✓ {linkedPf.number}</span>
                </>
              ) : (
                <button class="btn-add" onClick={() => onBuild(r, null)}>Build Pro Forma</button>
              )}
              <button class="btn-del" onClick={() => remove(r.id)}>✕</button>
            </div>
            <div style="font-size:0.85rem;color:var(--gray);">{new Date(r.createdAt).toLocaleString()} · {r.client.phone}{r.client.email ? ' · ' + r.client.email : ''}</div>
            {selected && selected.id === r.id && (
              <div style="margin-top:12px;padding-top:12px;border-top:1px solid var(--border);">
                <pre style="font-size:0.78rem;white-space:pre-wrap;word-break:break-word;">{JSON.stringify(r, null, 2)}</pre>
                <div class="pf-actions">
                  <button class="btn-back" onClick={() => setStatus(r.id, 'in_progress')}>Mark In Progress</button>
                  <button class="btn-back" onClick={() => setStatus(r.id, 'closed')}>Close</button>
                </div>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

function ProformasTab({ onEdit, data }) {
  const [list, setList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [open, setOpen] = useState(null);

  const refresh = async () => {
    setLoading(true);
    const r = await getProformas();
    r.sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''));
    setList(r);
    setLoading(false);
  };
  useEffect(() => { refresh(); }, []);

  const filtered = filter === 'all' ? list : list.filter(p => (p.status || 'draft') === filter);

  const remove = async (id) => {
    if (!confirm('Delete this pro forma?')) return;
    await deleteProforma(id);
    if (open && open.id === id) setOpen(null);
    refresh();
  };

  const setStatus = async (id, status) => {
    const next = await updateProformaStatus(id, status);
    setList(list.map(p => p.id === id ? next : p));
    if (open && open.id === id) setOpen(next);
  };

  const duplicate = async (id) => {
    const copy = await duplicateProforma(id);
    if (copy) { setOpen(copy); refresh(); }
  };

  if (open) {
    return (
      <div class="admin-panel">
        <div class="admin-panel-head">
          <h2>{open.number} · {open.client && open.client.name}</h2>
          <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <button class="btn-back" onClick={() => setOpen(null)}>← Back to list</button>
            <button class="btn-back" onClick={() => onEdit(open)}>✎ Edit</button>
            <button class="btn-back" onClick={() => duplicate(open.id)}>⧉ Duplicate</button>
            <button class="btn-del" onClick={() => remove(open.id)}>✕ Delete</button>
          </div>
        </div>

        <div class="admin-card">
          <div class="admin-panel-head">
            <strong>Status</strong>
            <div style="display:flex;gap:6px;flex-wrap:wrap;">
              {['draft', 'sent', 'accepted', 'rejected', 'expired'].map(s => (
                <button class={'filter-btn ' + ((open.status || 'draft') === s ? 'active' : '')} onClick={() => setStatus(open.id, s)}>{s}</button>
              ))}
            </div>
          </div>
          <div class="pf-actions" style="margin-top:10px;">
            <button class="btn btn-primary" onClick={() => window.print()}>🖨 Print / Save PDF</button>
          </div>
        </div>

        <div class="pf-doc">
          <div class="pf-doc-header">
            <div>
              <h1>{data.business.nameEn}</h1>
              <p style="font-weight:600;">{data.business.nameAm}</p>
              <p>{data.business.addressEn}</p>
              <p>{data.business.cell1} · {data.business.cell2}</p>
              <p style="margin-top:6px;font-size:0.78rem;">
                {data.business.fieldOfBusiness} · License {data.business.businessLicenseNo}<br/>
                TIN {data.business.tin} · Capital {data.business.capital}
              </p>
            </div>
            <div class="pf-doc-meta">
              <h2>PRO FORMA</h2>
              <p><strong>{open.number}</strong></p>
              <p>Issued: {open.createdAt}</p>
              <p>Valid until: {open.validUntil}</p>
            </div>
          </div>

          <div class="pf-doc-client">
            <div>
              <strong>Bill to</strong>
              <p>{open.client && open.client.name}</p>
              {open.client && open.client.company && <p>{open.client.company}</p>}
              <p>{open.client && open.client.phone}</p>
              {open.client && open.client.email && <p>{open.client.email}</p>}
            </div>
            <div>
              <strong>Project / Site</strong>
              <p>{(open.client && open.client.projectName) || '—'}</p>
              <p>{(open.client && open.client.siteAddress) || '—'}</p>
              {open.client && open.client.poNumber && <p>PO: {open.client.poNumber}</p>}
            </div>
          </div>

          <table class="pf-table pf-doc-table">
            <thead>
              <tr><th>#</th><th>Item</th><th>Qty</th><th>Unit</th><th>Unit price</th><th>Total</th></tr>
            </thead>
            <tbody>
              {open.lines.map((l, i) => (
                <tr key={i}>
                  <td>{i + 1}</td>
                  <td>{l.name}{l.code ? ' (' + l.code + ')' : ''}</td>
                  <td>{l.qty}</td>
                  <td>{l.unit}</td>
                  <td>Br {(l.contractorPrice || 0).toLocaleString()}</td>
                  <td>Br {(l.lineTotal || 0).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>

          <div class="pf-doc-totals">
            <div><span>Subtotal</span><span>Br {(open.totals.subtotal || 0).toLocaleString()}</span></div>
            {open.markupPct > 0 && <div><span>Overhead &amp; Profit ({open.markupPct}%)</span><span>+ Br {(open.totals.markup || 0).toLocaleString()}</span></div>}
            {open.contingencyPct > 0 && <div><span>Contingency ({open.contingencyPct}%)</span><span>+ Br {(open.totals.contingency || 0).toLocaleString()}</span></div>}
            {open.totals.discount > 0 && <div><span>Discount</span><span>− Br {(open.totals.discount || 0).toLocaleString()}</span></div>}
            {open.useFreight && <div><span>Freight</span><span>Br {(open.totals.freight || 0).toLocaleString()}</span></div>}
            <div><span>VAT 15%</span><span>Br {(open.totals.vat || 0).toLocaleString()}</span></div>
            <div class="pf-grand"><span>Grand total</span><span>Br {(open.totals.grandTotal || 0).toLocaleString()}</span></div>
          </div>

          <div class="pf-doc-terms">
            <strong>Terms</strong>
            <p>{data.business.defaultTerms}</p>
            {open.notes && <p style="margin-top:8px;"><strong>Notes:</strong> {open.notes}</p>}
          </div>

          <div class="pf-doc-sign">
            <div>___________________________<br/>For {data.business.nameEn}</div>
            <div>___________________________<br/>Client acceptance</div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div class="admin-panel">
      <div class="admin-panel-head">
        <h2>Pro Formas ({list.length})</h2>
        <button class="btn-back" onClick={refresh}>↻ Refresh</button>
      </div>

      <div class="filters">
        {['all', 'draft', 'sent', 'accepted', 'rejected', 'expired'].map(f => (
          <button class={'filter-btn ' + (filter === f ? 'active' : '')} onClick={() => setFilter(f)}>{f}</button>
        ))}
      </div>

      {loading && <p>Loading...</p>}
      {!loading && filtered.length === 0 && <p style="color:var(--gray);">No pro formas.</p>}

      {filtered.map(p => (
        <div class="admin-card">
          <div class="admin-card-head">
            <strong>{p.number}</strong>
            <span class={'pf-status ' + (p.status || 'draft')}>{p.status || 'draft'}</span>
            <button class="btn-back" onClick={() => setOpen(p)}>Open</button>
            <button class="btn-back" onClick={() => onEdit(p)}>✎</button>
            <button class="btn-back" onClick={() => duplicate(p.id)}>⧉</button>
            <button class="btn-del" onClick={() => remove(p.id)}>✕</button>
          </div>
          <div style="font-size:0.85rem;color:var(--gray);">
            {p.client && p.client.name} · {p.createdAt} ·
            total Br {((p.totals && p.totals.grandTotal) || 0).toLocaleString()}
            {p.totals && p.totals.totalMargin ? ' · margin Br ' + p.totals.totalMargin.toLocaleString() : ''}
          </div>
        </div>
      ))}
    </div>
  );
}

function BusinessTab({ data, update }) {
  const b = data.business;
  const set = (k, v) => update({ business: Object.assign({}, b, { [k]: v }) });
  return (
    <div class="admin-panel"><h2>Business Information</h2>
      <div class="admin-grid2"><Field label="Name (EN)" value={b.nameEn} onChange={v => set('nameEn', v)} /><Field label="Name (AM)" value={b.nameAm} onChange={v => set('nameAm', v)} /></div>
      <Field label="Tagline (EN)" value={b.taglineEn} onChange={v => set('taglineEn', v)} />
      <Field label="Tagline (AM)" value={b.taglineAm} onChange={v => set('taglineAm', v)} />
      <Field label="Subtitle (EN)" value={b.subtitleEn} onChange={v => set('subtitleEn', v)} />
      <Field label="Subtitle (AM)" value={b.subtitleAm} onChange={v => set('subtitleAm', v)} />
      <div class="admin-grid2"><Field label="Owner Name" value={b.ownerName} onChange={v => set('ownerName', v)} /><Field label="Field of Business" value={b.fieldOfBusiness} onChange={v => set('fieldOfBusiness', v)} /></div>
      <div class="admin-grid2"><Field label="Business License No" value={b.businessLicenseNo} onChange={v => set('businessLicenseNo', v)} /><Field label="Principal Reg No" value={b.principalRegNo} onChange={v => set('principalRegNo', v)} /></div>
      <div class="admin-grid2"><Field label="Previous License No" value={b.previousLicenseNo} onChange={v => set('previousLicenseNo', v)} /><Field label="TIN" value={b.tin} onChange={v => set('tin', v)} /></div>
      <div class="admin-grid2"><Field label="Capital" value={b.capital} onChange={v => set('capital', v)} /><Field label="Date of Issuance" value={b.dateOfIssuance} onChange={v => set('dateOfIssuance', v)} /></div>
      <div class="admin-grid2"><Field label="Renewal Date" value={b.renewalDate} onChange={v => set('renewalDate', v)} /><Field label="Business License Issued" value={b.businessLicenseIssued} onChange={v => set('businessLicenseIssued', v)} /></div>
      <Field label="Bureau" value={b.bureau} onChange={v => set('bureau', v)} />
      <div class="admin-grid2"><Field label="Cell 1" value={b.cell1} onChange={v => set('cell1', v)} /><Field label="Cell 2" value={b.cell2} onChange={v => set('cell2', v)} /></div>
      <div class="admin-grid2"><Field label="Cell 3" value={b.cell3} onChange={v => set('cell3', v)} /><Field label="Tel" value={b.tel} onChange={v => set('tel', v)} /></div>
      <div class="admin-grid2"><Field label="Email" value={b.email} onChange={v => set('email', v)} /><Field label="Region" value={b.region} onChange={v => set('region', v)} /></div>
      <div class="admin-grid2"><Field label="Zone / Sub-city" value={b.zoneSubCity} onChange={v => set('zoneSubCity', v)} /><Field label="Woreda" value={b.woreda} onChange={v => set('woreda', v)} /></div>
      <div class="admin-grid2"><Field label="House No" value={b.houseNo} onChange={v => set('houseNo', v)} /><Field label="Currency" value={b.currency} onChange={v => set('currency', v)} /></div>
      <Field label="Address (EN)" value={b.addressEn} onChange={v => set('addressEn', v)} />
      <Field label="Address (AM)" value={b.addressAm} onChange={v => set('addressAm', v)} />
      <div class="admin-field"><label>Default Terms</label><textarea rows="3" value={b.defaultTerms} onInput={e => set('defaultTerms', e.target.value)} /></div>
      <div class="admin-field"><label>Disclaimer</label><textarea rows="3" value={b.disclaimer || ''} onInput={e => set('disclaimer', e.target.value)} /></div>
    </div>
  );
}

function HeroTab({ data, update }) {
  const h = data.hero; const set = (k, v) => update({ hero: Object.assign({}, h, { [k]: v }) });
  return (
    <div class="admin-panel"><h2>Hero Badges</h2>
      <div class="admin-grid2">
        <Field label="Badge 1 (EN)" value={h.badge1En} onChange={v => set('badge1En', v)} /><Field label="Badge 1 (AM)" value={h.badge1Am} onChange={v => set('badge1Am', v)} />
        <Field label="Badge 2 (EN)" value={h.badge2En} onChange={v => set('badge2En', v)} /><Field label="Badge 2 (AM)" value={h.badge2Am} onChange={v => set('badge2Am', v)} />
        <Field label="Badge 3 (EN)" value={h.badge3En} onChange={v => set('badge3En', v)} /><Field label="Badge 3 (AM)" value={h.badge3Am} onChange={v => set('badge3Am', v)} />
      </div>
    </div>
  );
}

function StatsTab({ data, update }) {
  const list = data.stats; const setList = (n) => update({ stats: n });
  const edit = (id, k, v) => setList(list.map(s => s.id === id ? Object.assign({}, s, { [k]: v }) : s));
  const add = () => setList([...list, { id: uid(), num: '0', lblEn: 'Label', lblAm: 'መለያ' }]);
  const del = (id) => setList(list.filter(s => s.id !== id));
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Stats</h2><button class="btn-add" onClick={add}>+ Add</button></div>
      {list.map(s => (<div class="admin-row3" key={s.id}>
        <input value={s.num} onInput={e => edit(s.id, 'num', e.target.value)} />
        <input value={s.lblEn} onInput={e => edit(s.id, 'lblEn', e.target.value)} />
        <input value={s.lblAm} onInput={e => edit(s.id, 'lblAm', e.target.value)} />
        <button class="btn-del" onClick={() => del(s.id)}>✕</button>
      </div>))}
    </div>
  );
}

function ServicesTab({ data, update }) {
  const list = data.services; const setList = (n) => update({ services: n });
  const edit = (id, k, v) => setList(list.map(s => s.id === id ? Object.assign({}, s, { [k]: v }) : s));
  const add = () => setList([...list, { id: uid(), icon: '🏗️', titleEn: 'New Service', titleAm: 'አዲስ አገልግሎት', descEn: 'Description' }]);
  const del = (id) => { if (confirm('Delete?')) setList(list.filter(s => s.id !== id)); };
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Services</h2><button class="btn-add" onClick={add}>+ Add</button></div>
      {list.map(s => (
        <div class="admin-card" key={s.id}>
          <div class="admin-card-head">
            <input class="admin-card-icon" value={s.icon} onInput={e => edit(s.id, 'icon', e.target.value)} />
            <input class="admin-card-title" value={s.titleEn} onInput={e => edit(s.id, 'titleEn', e.target.value)} />
            <button class="btn-del" onClick={() => del(s.id)}>✕</button>
          </div>
          <Field label="Title (AM)" value={s.titleAm} onChange={v => edit(s.id, 'titleAm', v)} />
          <div class="admin-field"><label>Description</label><textarea rows="2" value={s.descEn} onInput={e => edit(s.id, 'descEn', e.target.value)} /></div>
        </div>
      ))}
    </div>
  );
}

function ProjectsTab({ data, update }) {
  const list = data.projects; const setList = (n) => update({ projects: n });
  const edit = (id, k, v) => setList(list.map(p => p.id === id ? Object.assign({}, p, { [k]: v }) : p));
  const add = () => setList([...list, { id: uid(), title: 'New Project', type: 'building', icon: '🏢', desc: '', budget: 'ETB 0', duration: '', year: new Date().getFullYear(), client: '' }]);
  const del = (id) => { if (confirm('Delete?')) setList(list.filter(p => p.id !== id)); };
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Projects</h2><button class="btn-add" onClick={add}>+ Add</button></div>
      {list.map(p => (
        <div class="admin-card" key={p.id}>
          <div class="admin-card-head">
            <input class="admin-card-icon" value={p.icon} onInput={e => edit(p.id, 'icon', e.target.value)} />
            <input class="admin-card-title" value={p.title} onInput={e => edit(p.id, 'title', e.target.value)} />
            <button class="btn-del" onClick={() => del(p.id)}>✕</button>
          </div>
          <div class="admin-grid2">
            <Field label="Type" value={p.type} onChange={v => edit(p.id, 'type', v)} />
            <Field label="Client" value={p.client} onChange={v => edit(p.id, 'client', v)} />
            <Field label="Budget" value={p.budget} onChange={v => edit(p.id, 'budget', v)} />
            <Field label="Duration" value={p.duration} onChange={v => edit(p.id, 'duration', v)} />
            <Field label="Year" value={p.year} onChange={v => edit(p.id, 'year', +v || 0)} />
          </div>
          <div class="admin-field"><label>Description</label><textarea rows="2" value={p.desc} onInput={e => edit(p.id, 'desc', e.target.value)} /></div>
        </div>
      ))}
    </div>
  );
}

function CatalogTab({ data, update }) {
  const [openCat, setOpenCat] = useState(data.categories[0] ? data.categories[0].id : null);
  const cats = data.categories, prods = data.products;
  const setCats = (n) => update({ categories: n }), setProds = (n) => update({ products: n });
  const editCat = (id, k, v) => setCats(cats.map(c => c.id === id ? Object.assign({}, c, { [k]: v }) : c));
  const addCat = () => setCats([...cats, { id: uid(), name: 'New Category', nameAm: 'አዲስ', icon: '📦' }]);
  const delCat = (id) => { if (!confirm('Delete category AND its products?')) return; setCats(cats.filter(c => c.id !== id)); setProds(prods.filter(p => p.category !== id)); };
  const addProd = (catId) => setProds([...prods, { id: uid(), category: catId, name: 'New Product', unit: 'piece', basePrice: 100, contractorPrice: 100, stock: 0, leadTimeDays: 2, taxable: true, tiers: [{ min: 1, price: 100 }] }]);
  const editProd = (id, k, v) => setProds(prods.map(p => p.id === id ? Object.assign({}, p, { [k]: v }) : p));
  const delProd = (id) => { if (confirm('Delete product?')) setProds(prods.filter(p => p.id !== id)); };
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Materials Catalog</h2><button class="btn-add" onClick={addCat}>+ Category</button></div>
      {cats.map(cat => (
        <div class="admin-card" key={cat.id}>
          <div class="admin-card-head">
            <input class="admin-card-icon" value={cat.icon} onInput={e => editCat(cat.id, 'icon', e.target.value)} />
            <input class="admin-card-title" value={cat.name} onInput={e => editCat(cat.id, 'name', e.target.value)} />
            <button class="btn-back" onClick={() => setOpenCat(openCat === cat.id ? null : cat.id)}>{openCat === cat.id ? '▲' : '▼'} {prods.filter(p => p.category === cat.id).length}</button>
            <button class="btn-del" onClick={() => delCat(cat.id)}>✕</button>
          </div>
          <Field label="Name (AM)" value={cat.nameAm} onChange={v => editCat(cat.id, 'nameAm', v)} />
          {openCat === cat.id && (
            <div style="margin-top:12px;">
              {prods.filter(p => p.category === cat.id).map(p => (
                <div class="admin-subcard" key={p.id}>
                  <div class="admin-card-head">
                    <input class="admin-card-title" value={p.name} onInput={e => editProd(p.id, 'name', e.target.value)} />
                    <button class="btn-del" onClick={() => delProd(p.id)}>✕</button>
                  </div>
                  <div class="admin-grid3">
                    <Field label="Unit" value={p.unit} onChange={v => editProd(p.id, 'unit', v)} />
                    <Field label="Base price" type="number" value={p.basePrice} onChange={v => editProd(p.id, 'basePrice', +v || 0)} />
                    <Field label="Quote price" type="number" value={p.contractorPrice} onChange={v => editProd(p.id, 'contractorPrice', +v || 0)} />
                    <Field label="Stock" type="number" value={p.stock} onChange={v => editProd(p.id, 'stock', +v || 0)} />
                    <Field label="Lead days" type="number" value={p.leadTimeDays} onChange={v => editProd(p.id, 'leadTimeDays', +v || 0)} />
                  </div>
                </div>
              ))}
              <button class="btn-add" onClick={() => addProd(cat.id)}>+ Add Product</button>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

function FreightTab({ data, update }) {
  const zones = data.freight.zones; const setZones = (n) => update({ freight: { zones: n } });
  const edit = (id, k, v) => setZones(zones.map(z => z.id === id ? Object.assign({}, z, { [k]: v }) : z));
  const add = () => setZones([...zones, { id: uid(), name: 'New Zone', flat: 0, perTon: 0 }]);
  const del = (id) => { if (confirm('Delete zone?')) setZones(zones.filter(z => z.id !== id)); };
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Freight Zones</h2><button class="btn-add" onClick={add}>+ Zone</button></div>
      {zones.map(z => (
        <div class="admin-card" key={z.id}>
          <div class="admin-card-head">
            <input class="admin-card-title" value={z.name} onInput={e => edit(z.id, 'name', e.target.value)} />
            <button class="btn-del" onClick={() => del(z.id)}>✕</button>
          </div>
          <div class="admin-grid2">
            <Field label="Flat fee (ETB)" type="number" value={z.flat} onChange={v => edit(z.id, 'flat', +v || 0)} />
            <Field label="Per ton (ETB)" type="number" value={z.perTon} onChange={v => edit(z.id, 'perTon', +v || 0)} />
          </div>
        </div>
      ))}
    </div>
  );
}

function ReviewsTab({ data, update }) {
  const list = data.reviews; const setList = (n) => update({ reviews: n });
  const edit = (id, k, v) => setList(list.map(r => r.id === id ? Object.assign({}, r, { [k]: v }) : r));
  const add = () => setList([...list, { id: uid(), name: 'New Client', loc: 'Addis Ababa', stars: 5, text: 'Excellent work.' }]);
  const del = (id) => setList(list.filter(r => r.id !== id));
  return (
    <div class="admin-panel"><div class="admin-panel-head"><h2>Reviews</h2><button class="btn-add" onClick={add}>+ Add</button></div>
      {list.map(r => (
        <div class="admin-card" key={r.id}>
          <div class="admin-card-head">
            <input class="admin-card-title" value={r.name} onInput={e => edit(r.id, 'name', e.target.value)} />
            <button class="btn-del" onClick={() => del(r.id)}>✕</button>
          </div>
          <div class="admin-grid2">
            <Field label="Location" value={r.loc} onChange={v => edit(r.id, 'loc', v)} />
            <Field label="Stars 1-5" type="number" value={r.stars} onChange={v => edit(r.id, 'stars', Math.max(1, Math.min(5, +v || 5)))} />
          </div>
          <div class="admin-field"><label>Review</label><textarea rows="2" value={r.text} onInput={e => edit(r.id, 'text', e.target.value)} /></div>
        </div>
      ))}
    </div>
  );
}

function SettingsTab({ data, update }) {
  const b = data.business; const set = (k, v) => update({ business: Object.assign({}, b, { [k]: v }) });
  return (
    <div class="admin-panel"><h2>Settings</h2>
      <div class="admin-grid2">
        <Field label="Staff password" value={b.staffPassword} onChange={v => set('staffPassword', v)} />
        <Field label="Quote validity (days)" type="number" value={b.validDays} onChange={v => set('validDays', +v || 30)} />
        <Field label="Default markup %" type="number" value={b.markupPct} onChange={v => set('markupPct', +v || 0)} />
        <Field label="Default contingency %" type="number" value={b.contingencyPct} onChange={v => set('contingencyPct', +v || 0)} />
        <Field label="Default inflation factor" type="number" value={b.inflationFactor} onChange={v => set('inflationFactor', +v || 1)} />
        <div class="admin-field"><label>VAT rate</label><input type="number" step="0.01" value={b.vatRate} onInput={e => set('vatRate', +e.target.value || 0)} /></div>
      </div>
    </div>
  );
}
