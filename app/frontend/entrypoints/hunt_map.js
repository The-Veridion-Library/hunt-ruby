import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

document.addEventListener('DOMContentLoaded', () => {
  const mapEl = document.getElementById('hunt-map')
  if (!mapEl) return

  const points = JSON.parse(mapEl.dataset.points || '[]')

  const map = L.map(mapEl).setView([39.5, -98.35], 4)

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors'
  }).addTo(map)

  if (points.length === 0) return

  const latLngs = []

  points.forEach(point => {
    const latLng = [point.latitude, point.longitude]
    latLngs.push(latLng)

    L.marker(latLng)
      .addTo(map)
      .bindPopup(`
        <strong>${point.title}</strong><br>
        by ${point.author}<br>
        📍 ${point.location_name}<br>
        <a href="${point.book_url}">View Book →</a>
      `)
  })

  map.fitBounds(latLngs, { padding: [40, 40] })
})
