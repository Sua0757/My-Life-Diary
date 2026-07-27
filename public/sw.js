/* My Life手帳 サービスワーカー
   目的：オフラインでもアプリを起動・閲覧・追記できるようにする。
   方針：
   - HTML（アプリ本体）は「ネット優先・失敗したらキャッシュ」= オンライン時は常に最新、オフライン時は前回の内容で起動。
   - Supabase SDK（外部スクリプト）は「キャッシュ優先」= オフラインでも読み込める。
   - Supabaseへのデータ通信(POST等)やGET以外は素通り（キャッシュしない）。 */
const CACHE = 'mylife-cache-v29';
const SDK = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';

self.addEventListener('install', (e) => {
  self.skipWaiting();
  /* アプリ本体(HTML)のキャッシュだけをinstallの完了条件にする（同一オリジンで速い）。
     これで新版の有効化＝自動更新が遅れない。 */
  e.waitUntil(
    caches.open(CACHE).then((c) => Promise.all([
      c.add('./').catch(() => {}),
      c.add('./index.html').catch(() => {})
    ]))
  );
  /* Supabase SDKは待たずに裏でキャッシュ（遅い/失敗しても起動や更新を妨げない） */
  caches.open(CACHE).then((c) => c.add(SDK).catch(() => {}));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    Promise.all([
      self.clients.claim(),
      caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
    ])
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return; /* 保存・同期などの通信は素通り */
  const url = new URL(req.url);

  /* アプリ本体（HTML）：ネット優先、ダメならキャッシュ */
  if (req.mode === 'navigate' || req.destination === 'document') {
    e.respondWith(
      fetch(req)
        .then((r) => { const cp = r.clone(); caches.open(CACHE).then((c) => c.put('./index.html', cp)); return r; })
        .catch(() => caches.match(req).then((m) => m || caches.match('./index.html')))
    );
    return;
  }

  /* Supabase SDK：キャッシュ優先 */
  if (url.href.indexOf('cdn.jsdelivr.net') !== -1) {
    e.respondWith(
      caches.match(req).then((m) => m || fetch(req).then((r) => { const cp = r.clone(); caches.open(CACHE).then((c) => c.put(req, cp)); return r; }))
    );
    return;
  }

  /* それ以外のGET：ネット→ダメならキャッシュ */
  e.respondWith(fetch(req).catch(() => caches.match(req)));
});
