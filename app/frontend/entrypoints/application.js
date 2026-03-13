import { mount } from 'svelte'
import Stats from '../components/Stats.svelte'

// Mount the stats widget on the logged-out landing page (if the target exists)
const statsTarget = document.getElementById('svelte-stats')
if (statsTarget) {
  mount(Stats, { target: statsTarget })
}
