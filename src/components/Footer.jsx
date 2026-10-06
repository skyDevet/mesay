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
