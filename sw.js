/* Tombstone service worker.
 *
 * The previous Chirpy theme registered a cache-first worker at this path that
 * returned cached responses without ever revalidating, so returning visitors
 * stayed pinned to a stale copy of the site. Browsers re-fetch /sw.js on their
 * own schedule; when a client picks this file up it supersedes the old worker,
 * drops every cache, unregisters itself, and reloads open tabs.
 *
 * Deliberately has no fetch handler, so all requests go straight to the network.
 *
 * Safe to delete once traffic has cycled through (target: mid-2027).
 */

self.addEventListener('install', function () {
  self.skipWaiting();
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys.map(function (key) { return caches.delete(key); }));
      })
      .then(function () { return self.registration.unregister(); })
      .then(function () { return self.clients.matchAll({ type: 'window' }); })
      .then(function (clients) {
        clients.forEach(function (client) { client.navigate(client.url); });
      })
      .catch(function () {})
  );
});
