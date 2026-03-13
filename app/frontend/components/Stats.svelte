<script>
  import { onMount } from 'svelte'

  let stats = { total_books: null, total_finds: null, total_locations: null, total_users: null }
  let loaded = false

  onMount(async () => {
    try {
      const res = await fetch('/api/stats')
      if (res.ok) {
        stats = await res.json()
        loaded = true
      }
    } catch (e) {
      // silently fail — static page still works
    }
  })

  function fmt(n) {
    if (n === null) return '—'
    if (n >= 1000) return (n / 1000).toFixed(1) + 'k'
    return n.toString()
  }
</script>

<div class="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto my-10">
  {#each [
    { icon: '📚', label: 'Books in the Wild', value: fmt(stats.total_books) },
    { icon: '🎯', label: 'Total Finds',       value: fmt(stats.total_finds) },
    { icon: '📍', label: 'Partner Locations', value: fmt(stats.total_locations) },
    { icon: '👥', label: 'Hunters',           value: fmt(stats.total_users) },
  ] as stat}
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 text-center">
      <p class="text-3xl mb-1">{stat.icon}</p>
      <p class="text-2xl font-bold text-slate-900 {loaded ? '' : 'animate-pulse text-slate-300'}">
        {stat.value}
      </p>
      <p class="text-slate-500 text-xs mt-1">{stat.label}</p>
    </div>
  {/each}
</div>
