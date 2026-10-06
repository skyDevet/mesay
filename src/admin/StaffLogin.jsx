import { useState } from 'preact/hooks';
import { useStore } from '../data/store.js';
export function StaffLogin({ onSuccess, onExit }) {
  const [data] = useStore();
  const [pw, setPw] = useState('');
  const [err, setErr] = useState('');
  const tryLogin = () => {
    if (pw === data.business.staffPassword) { sessionStorage.setItem('mesay_staff', '1'); onSuccess(); }
    else setErr('Wrong password');
  };
  return (
    <div class="staff-login"><div class="staff-login-card">
      <h2>🔒 Staff Portal</h2>
      <p>Internal access only — quote requests, pro forma builder, rate book.</p>
      <input type="password" placeholder="Staff password" value={pw} onInput={e => { setPw(e.target.value); setErr(''); }} onKeyDown={e => e.key === 'Enter' && tryLogin()} />
      {err && <div class="staff-err">{err}</div>}
      <div class="staff-login-actions">
        <button class="btn btn-primary" onClick={tryLogin}>Sign in</button>
        <button class="btn-back" onClick={onExit}>Cancel</button>
      </div>
    </div></div>
  );
}
