import { useState, useEffect } from 'preact/hooks';
import { useStore } from '../data/store.js';
import { getRateCategories, getRateItemsByCategory } from '../data/ratebook.js';
import { saveProforma, getProformas } from '../data/proformas.js';
import { calcProforma, nextProformaNumber, addDays, formatMoney } from '../data/pricing.js';

export function BuildFromRateBook({ onDone }) {
  const [data] = useStore();
  const [cats, setCats] = useState([]);
  const [cat, setCat] = useState('');
  const [items, setItems] = useState([]);
  const [search, setSearch] = useState('');
  const [lines, setLines] = useState([]);
  const [client, setClient] = useState({ name: '', phone: '', email: '', company: '', projectName: '', siteAddress: '' });
  const [markupPct, setMarkupPct] = useState(data.business.markupPct || 15);
  const [contingencyPct, setContingencyPct] = useState(data.business.contingencyPct || 5);
  const [vatPct, setVatPct] = useState(Math.round((data.business.vatRate || 0.15) * 100));
  const [saved, setSaved] = useState(null);

  useEffect(() => {
    getRateCategories().then(c => {
      setCats(c);
      if (c.length) setCat(c[0].id);
    });
  }, []);

  useEffect(() => {
    if (cat) getRateItemsByCategory(cat).then(setItems);
  }, [cat]);

  const filtered = search
    ? items.filter(i =>
        (i.description || '').toLowerCase().includes(search.toLowerCase()) ||
        (i.code || '').toLowerCase().includes(search.toLowerCase()))
    : items;

  const addLine = (it) => {
    const q = prompt('Quantity for:\n' + it.description + '\nUnit: ' + it.unit, '1');
    if (q === null) return;
    const qty = parseFloat(q) || 0;
    if (qty <= 0) return;
    const basePrice = it.basePrice == null ? 0 : it.basePrice;
    const p = prompt('Your price per ' + it.unit + ' (base: ' + basePrice + ')', String(basePrice));
    if (p === null) return;
    const price = parseFloat(p) || 0;
    setLines([...lines, {
      code: it.code,
      name: it.description,
      unit: it.unit,
      qty,
      basePrice,
      contractorPrice: price,
      lineTotal: Math.round(qty * price * 100) / 100,
      margin: Math.round((price - basePrice) * qty * 100) / 100,
      taxable: true,
      leadTimeDays: 0
    }]);
  };

  const editLine = (i, k, v) => {
    const n = lines.slice();
    const l = n[i];
    if (k === 'qty') {
      const q = Math.max(0, +v || 0);
      n[i] = Object.assign({}, l, { qty: q, lineTotal: Math.round(q * l.contractorPrice * 100) / 100, margin: Math.round((l.contractorPrice - l.basePrice) * q * 100) / 100 });
    } else if (k === 'contractorPrice') {
      const p = +v || 0;
      n[i] = Object.assign({}, l, { contractorPrice: p, lineTotal: Math.round(l.qty * p * 100) / 100, margin: Math.round((p - l.basePrice) * l.qty * 100) / 100 });
    } else if (k === 'name' || k === 'unit' || k === 'code') {
      n[i] = Object.assign({}, l, { [k]: v });
    }
    setLines(n);
  };

  const removeLine = (i) => setLines(lines.filter((_, x) => x !== i));

  const totals = calcProforma({
    lines,
    freightZone: null,
    zones: [],
    discountPct: 0,
    vatRate: vatPct / 100,
    markupPct,
    contingencyPct
  });

  const save = async () => {
    if (!client.name || !client.phone || lines.length === 0) return;
    const all = await getProformas();
    const today = new Date().toISOString().slice(0, 10);
    const pf = {
      id: 'pf_' + Math.random().toString(36).slice(2, 9),
      number: nextProformaNumber(all),
      kind: 'services',
      requestId: null,
      createdAt: today,
      validUntil: addDays(today, data.business.validDays || 30),
      client: Object.assign({}, client),
      lines: lines.slice(),
      discountPct: 0,
      markupPct,
      contingencyPct,
      useFreight: false,
      notes: '',
      totals,
      status: 'draft'
    };
    await saveProforma(pf);
    setSaved(pf);
  };

  if (saved) {
    return (
      <section class="section alt"><div class="container">
        <div class="pf-actions no-print">
          <button class="btn btn-primary" onClick={() => window.print()}>🖨 Print / Save PDF</button>
          <button class="btn-back" onClick={() => { setSaved(null); setLines([]); }}>+ New Pro Forma</button>
          <button class="btn-back" onClick={onDone}>← Back to admin</button>
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
              <p><strong>{saved.number}</strong></p>
              <p>Issued: {saved.createdAt}</p>
              <p>Valid until: {saved.validUntil}</p>
            </div>
          </div>
          <div class="pf-doc-client">
            <div><strong>Bill to</strong><p>{client.name}</p>{client.company && <p>{client.company}</p>}<p>{client.phone}</p>{client.email && <p>{client.email}</p>}</div>
            <div><strong>Project / Site</strong><p>{client.projectName || '—'}</p><p>{client.siteAddress || '—'}</p></div>
          </div>
          <table class="pf-table pf-doc-table">
            <thead><tr><th>#</th><th>Item</th><th>Qty</th><th>Unit</th><th>Unit price</th><th>Total</th></tr></thead>
            <tbody>
              {saved.lines.map((l, i) => (
                <tr key={i}>
                  <td>{i + 1}</td>
                  <td>{l.name}{l.code ? ' (' + l.code + ')' : ''}</td>
                  <td>{l.qty}</td>
                  <td>{l.unit}</td>
                  <td>{formatMoney(l.contractorPrice, data.business.currency)}</td>
                  <td>{formatMoney(l.lineTotal, data.business.currency)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div class="pf-doc-totals">
            <div><span>Subtotal</span><span>{formatMoney(totals.subtotal, data.business.currency)}</span></div>
            {markupPct > 0 && <div><span>Overhead &amp; Profit ({markupPct}%)</span><span>+ {formatMoney(totals.markup, data.business.currency)}</span></div>}
            {contingencyPct > 0 && <div><span>Contingency ({contingencyPct}%)</span><span>+ {formatMoney(totals.contingency, data.business.currency)}</span></div>}
            <div><span>VAT ({vatPct}%)</span><span>{formatMoney(totals.vat, data.business.currency)}</span></div>
            <div class="pf-grand"><span>Grand total</span><span>{formatMoney(totals.grandTotal, data.business.currency)}</span></div>
          </div>
          <div class="pf-doc-terms">
            <strong>Terms · ውል</strong>
            <p>{data.business.defaultTerms}</p>
          </div>
          <div class="pf-doc-sign">
            <div>___________________________<br/>For {data.business.nameEn}</div>
            <div>___________________________<br/>Client acceptance</div>
          </div>
        </div>
      </div></section>
    );
  }

  return (
    <section class="section alt"><div class="container">
      <div class="admin-panel-head">
        <h2>Build Pro Forma from Rate Book</h2>
        <button class="btn-back" onClick={onDone}>← Back</button>
      </div>

      <div class="pf-builder">
        <h3>Client</h3>
        <div class="pf-grid">
          <input placeholder="Client name *" value={client.name} onInput={e => setClient({ ...client, name: e.target.value })} />
          <input placeholder="Phone *" value={client.phone} onInput={e => setClient({ ...client, phone: e.target.value })} />
          <input placeholder="Email" value={client.email} onInput={e => setClient({ ...client, email: e.target.value })} />
          <input placeholder="Company" value={client.company} onInput={e => setClient({ ...client, company: e.target.value })} />
          <input placeholder="Project" value={client.projectName} onInput={e => setClient({ ...client, projectName: e.target.value })} />
          <input placeholder="Site address" value={client.siteAddress} onInput={e => setClient({ ...client, siteAddress: e.target.value })} />
        </div>

        <h3>Pick from rate book</h3>
        {cats.length === 0 ? (
          <p style="color:var(--gray);">
            Rate book is empty. Open <strong>📚 Rate Book</strong> tab and click <strong>🌱 Re-seed from Module</strong> first.
          </p>
        ) : (
          <>
            <div class="pf-add-row" style="grid-template-columns: 1fr 1fr;">
              <select value={cat} onChange={e => setCat(e.target.value)}>
                {cats.map(c => <option value={c.id}>{c.title} ({c.itemCount})</option>)}
              </select>
              <input placeholder="Search code or description" value={search} onInput={e => setSearch(e.target.value)} />
            </div>
            <div style="max-height:340px;overflow-y:auto;margin-top:8px;border:1px solid var(--border);border-radius:8px;">
              {filtered.slice(0, 400).map(it => (
                <div class="ratebook-row" key={it.id}>
                  <span class="rb-code">{it.code}</span>
                  <span class="rb-desc">{it.description}</span>
                  <span class="rb-unit">{it.unit}</span>
                  <span class="rb-price">{it.basePrice == null ? 'POA' : 'Br ' + it.basePrice.toLocaleString()}</span>
                  <button class="btn-add" onClick={() => addLine(it)}>+ Add</button>
                </div>
              ))}
              {filtered.length === 0 && <p style="color:var(--gray);text-align:center;padding:12px;">No matches.</p>}
            </div>
          </>
        )}

        {lines.length > 0 && (
          <>
            <h3>Line items ({lines.length})</h3>
            <table class="pf-table">
              <thead><tr><th>Code</th><th>Item</th><th>Unit</th><th>Qty</th><th>Your price</th><th>Total</th><th></th></tr></thead>
              <tbody>
                {lines.map((l, i) => (
                  <tr key={i}>
                    <td><input value={l.code} onInput={e => editLine(i, 'code', e.target.value)} style="width:70px;" /></td>
                    <td><input value={l.name} onInput={e => editLine(i, 'name', e.target.value)} style="width:100%;" /></td>
                    <td><input value={l.unit} onInput={e => editLine(i, 'unit', e.target.value)} style="width:60px;" /></td>
                    <td><input type="number" value={l.qty} onInput={e => editLine(i, 'qty', e.target.value)} style="width:70px;" /></td>
                    <td><input type="number" value={l.contractorPrice} onInput={e => editLine(i, 'contractorPrice', e.target.value)} style="width:100px;" /></td>
                    <td><strong>Br {l.lineTotal.toLocaleString()}</strong></td>
                    <td><button class="btn-del" onClick={() => removeLine(i)}>✕</button></td>
                  </tr>
                ))}
              </tbody>
            </table>

            <h3>Options</h3>
            <div class="pf-grid">
              <div class="admin-field"><label>Markup %</label><input type="number" value={markupPct} onInput={e => setMarkupPct(+e.target.value || 0)} /></div>
              <div class="admin-field"><label>Contingency %</label><input type="number" value={contingencyPct} onInput={e => setContingencyPct(+e.target.value || 0)} /></div>
              <div class="admin-field"><label>VAT %</label><input type="number" value={vatPct} onInput={e => setVatPct(+e.target.value || 0)} /></div>
            </div>

            <div class="pf-totals">
              <div><span>Subtotal</span><span>{formatMoney(totals.subtotal, data.business.currency)}</span></div>
              <div><span>Markup ({markupPct}%)</span><span>+ {formatMoney(totals.markup, data.business.currency)}</span></div>
              <div><span>Contingency ({contingencyPct}%)</span><span>+ {formatMoney(totals.contingency, data.business.currency)}</span></div>
              <div><span>VAT ({vatPct}%)</span><span>{formatMoney(totals.vat, data.business.currency)}</span></div>
              <div class="pf-grand"><span>Grand total</span><span>{formatMoney(totals.grandTotal, data.business.currency)}</span></div>
            </div>

            <div class="pf-actions">
              <button class="btn btn-primary" disabled={!client.name || !client.phone} onClick={save}>
                Generate Pro Forma
              </button>
            </div>
          </>
        )}
      </div>
    </div></section>
  );
}
