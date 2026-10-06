import { useState, useEffect } from 'preact/hooks';
import {
  seedFromModule, getRateBookMeta, getRateCategories,
  getRateItemsByCategory, updateRateItem, applyInflation, resetContractorPrices, clearRateBook
} from '../data/ratebook.js';

export function RateBookTab() {
  const [meta, setMeta] = useState(null);
  const [cats, setCats] = useState([]);
  const [openCat, setOpenCat] = useState(null);
  const [items, setItems] = useState([]);
  const [search, setSearch] = useState('');
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState('');

  const refresh = async () => {
    setMeta(await getRateBookMeta());
    setCats(await getRateCategories());
  };
  useEffect(() => { refresh(); }, []);

  const loadItems = async (catId) => {
    setOpenCat(catId);
    setItems(await getRateItemsByCategory(catId));
  };

  const reseed = async () => {
    if (!confirm('Re-seed rate book from bundled ratebook-data.js? Existing edits will be lost.')) return;
    setBusy(true); setMsg('Seeding from module...');
    try {
      const res = await seedFromModule();
      setMsg(`Seeded ${res.itemCount} items across ${res.categoryCount} categories.`);
      await refresh();
    } catch (e) { setMsg('Error: ' + e.message); }
    setBusy(false);
  };

  const doInflation = async () => {
    const f = prompt('Apply inflation factor. Example: 1.4 for +40%', '1.0');
    if (!f) return;
    const n = parseFloat(f);
    if (!n || n <= 0) { alert('Invalid factor'); return; }
    setBusy(true);
    const count = await applyInflation(n);
    setMsg(`Applied ×${n} to ${count} items.`);
    if (openCat) loadItems(openCat);
    setBusy(false);
  };

  const doResetContractor = async () => {
    if (!confirm('Reset all contractor prices to base?')) return;
    setBusy(true);
    const n = await resetContractorPrices();
    setMsg(`Reset ${n} contractor prices.`);
    if (openCat) loadItems(openCat);
    setBusy(false);
  };

  const doClear = async () => {
    if (!confirm('Delete the entire rate book?')) return;
    await clearRateBook();
    setMeta(null); setCats([]); setItems([]); setOpenCat(null);
    setMsg('Rate book cleared.');
  };

  const updateItem = async (id, patch) => {
    const next = await updateRateItem(id, patch);
    setItems(items.map(i => i.id === id ? next : i));
  };

  const filteredItems = search
    ? items.filter(i =>
        (i.description || '').toLowerCase().includes(search.toLowerCase()) ||
        (i.code || '').toLowerCase().includes(search.toLowerCase()))
    : items;

  return (
    <div class="admin-panel">
      <div class="admin-panel-head">
        <h2>Rate Book</h2>
        <div style="display:flex;gap:8px;flex-wrap:wrap;">
          <button class="btn-add" onClick={reseed}>🌱 Re-seed from Module</button>
          <button class="btn-back" onClick={doInflation}>📈 Apply Inflation</button>
          <button class="btn-back" onClick={doResetContractor}>↺ Reset Contractor Prices</button>
          <button class="btn-danger" onClick={doClear}>🗑 Clear</button>
        </div>
      </div>
      {msg && <div class="admin-msg">{msg}</div>}
      {meta ? (
        <div class="admin-card">
          <div style="font-size:0.85rem;">
            <strong>{meta.source || 'Rate Book'}</strong> · {meta.quarter} · {meta.currency}<br/>
            {meta.itemCount} items across {meta.categoryCount} categories<br/>
            Seeded: {new Date(meta.importedAt).toLocaleString()}
          </div>
        </div>
      ) : (
        <div class="admin-card"><p style="color:var(--gray);">Rate book is empty. Click <strong>🌱 Re-seed from Module</strong> to load it.</p></div>
      )}
      {cats.length > 0 && (
        <>
          <h3 style="margin-top:20px;">Categories</h3>
          {cats.map(c => (
            <div class="admin-card" key={c.id}>
              <div class="admin-card-head">
                <strong style="flex:1;">{c.title}</strong>
                <span style="color:var(--gray);font-size:0.8rem;">{c.itemCount} items</span>
                <button class="btn-back" onClick={() => openCat === c.id ? setOpenCat(null) : loadItems(c.id)}>{openCat === c.id ? '▲ Close' : '▼ Open'}</button>
              </div>
              {openCat === c.id && (
                <div style="margin-top:12px;">
                  <input placeholder="Search..." value={search} onInput={e => setSearch(e.target.value)} style="width:100%;padding:8px;border:1px solid var(--border);border-radius:6px;margin-bottom:8px;font-family:inherit;" />
                  <div style="max-height:500px;overflow-y:auto;">
                    {filteredItems.slice(0, 500).map(it => (
                      <div class="admin-subcard" key={it.id}>
                        <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                          <span style="font-family:monospace;font-size:0.75rem;color:var(--gray);min-width:60px;">{it.code}</span>
                          <span style="flex:1;font-size:0.85rem;">{it.description}</span>
                          <span style="font-size:0.75rem;color:var(--gray);">{it.unit}</span>
                        </div>
                        <div class="admin-grid3" style="margin-top:8px;">
                          <div class="admin-field"><label>Base price</label><input type="number" value={it.basePrice == null ? '' : it.basePrice} onInput={e => updateItem(it.id, { basePrice: e.target.value === '' ? null : +e.target.value })} /></div>
                          <div class="admin-field"><label>Quote price</label><input type="number" value={it.contractorPrice == null ? '' : it.contractorPrice} onInput={e => updateItem(it.id, { contractorPrice: e.target.value === '' ? null : +e.target.value })} /></div>
                          <div class="admin-field"><label>Unit</label><input value={it.unit} onInput={e => updateItem(it.id, { unit: e.target.value })} /></div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ))}
        </>
      )}
    </div>
  );
}
