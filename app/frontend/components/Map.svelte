<script>
  import { onMount } from 'svelte'
  import L from 'leaflet'
  import 'leaflet/dist/leaflet.css'

  let mapEl
  let labels = []
  let loading = true
  let error = null

  onMount(async () => {
    const map = L.map(mapEl).setView([39.5, -98.35], 4)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map)

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(({ coords }) => {
        map.setView([coords.latitude, coords.longitude], 13)
      })
    }

    try {
      const res = await fetch('/api/labels')
      labels = await res.json()

      labels.forEach(label => {
        if (label.lat && label.lng) {
          L.marker([label.lat, label.lng])
            .addTo(map)
            .bindPopup(`
              <strong>${label.book_title}</strong><br>
              by ${label.book_author}<br>
              📍 ${label.location_name}<br>
              <a href="${label.book_url}">View Book →</a>
            `)
        }
      })
    } catch (e) {
      error = 'Failed to load book locations.'
    } finally {
      loading = false
    }
  })
</script>

{#if error}
  <p style="color:red">{error}</p>
{/if}

<div bind:this={mapEl} style="height: 600px; width: 100%;"></div>