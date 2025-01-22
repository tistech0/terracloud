import http from 'k6/http';
import { sleep, check } from 'k6';

// Variable globale pour l'URL de base
const BASE_URL = 'http://13.93.41.203';

export const options = {
  stages: [
    { duration: '30s', target: 10 },  // montée à 10 users en 30s
    { duration: '1m', target: 10 },   // maintien 10 users pendant 1m
    { duration: '20s', target: 0 }    // descente à 0 en 20s
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% des requêtes doivent être sous 500ms
    checks: ['rate>0.9'],             // 90% des checks doivent réussir
  },
};

export default function () {
  // Test de la page d'accueil
  let home = http.get(`${BASE_URL}/`);
  check(home, {
    'home status is 200': (r) => r.status === 200,
    'home load time OK': (r) => r.timings.duration < 500
  });
  sleep(1);

  // Test de l'incrémentation
  let increment = http.get(`${BASE_URL}/api/counter/add`);
  check(increment, {
    'increment status is 200': (r) => r.status === 200,
    'increment response time OK': (r) => r.timings.duration < 500
  });
  sleep(1);

  // Test de la lecture du compteur
  let count = http.get(`${BASE_URL}/api/counter/count`);
  check(count, {
    'count status is 200': (r) => r.status === 200,
    'count response time OK': (r) => r.timings.duration < 500
  });
  sleep(1);
}