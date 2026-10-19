// Service Worker for offline support
const CACHE_NAME = 'tailoring_system_v2';
const urlsToCache = [
  '/',
  '/index.html',
  '/flutter_bootstrap.js',
  '/main.dart.js',
  '/flutter.js',
  '/sqlite3.wasm',
  '/canvaskit/canvaskit.js',
  '/canvaskit/canvaskit.wasm',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
];

// Install event - cache essential files
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(urlsToCache).catch(() => {
          // If some URLs fail to cache, continue
          console.log('Some files could not be cached');
        });
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached response if available
        if (response) {
          return response;
        }

        return fetch(event.request)
          .then((response) => {
            // Don't cache non-successful responses
            if (!response || response.status !== 200) {
              return response;
            }

            // Only cache same-origin responses (skip cross-origin like gstatic)
            const requestUrl = new URL(event.request.url);
            if (requestUrl.origin === self.location.origin) {
              const responseToCache = response.clone();
              caches.open(CACHE_NAME)
                .then((cache) => {
                  cache.put(event.request, responseToCache);
                });
            }

            return response;
          })
          .catch(() => {
            // Return a simple offline page or cached response
            return caches.match('/index.html');
          });
      })
  );
});
