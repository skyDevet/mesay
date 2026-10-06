import { useStore } from '../data/store.js';
export function Reviews() {
  const [data, lang] = useStore();
  return (
    <section class="section alt"><div class="container">
      <div class="section-header"><h2>{lang === 'am' ? 'የደንበኞች አስተያየት' : 'What Clients Say'}</h2></div>
      <div class="reviews-grid">
        {data.reviews.map(r => (<div class="review-card">
          <div class="review-stars">{'★'.repeat(r.stars)}</div>
          <p>"{r.text}"</p>
          <div class="review-author">{r.name}</div>
          <div class="review-loc">{r.loc}</div>
        </div>))}
      </div>
    </div></section>
  );
}
