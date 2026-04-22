import { mount } from 'svelte'
import Stats from '../components/Stats.svelte'
import Button from '../components/Button.svelte'

// Mount the stats widget on the logged-out landing page (if the target exists)
const statsTarget = document.getElementById('svelte-stats')
if (statsTarget) {
  mount(Stats, { target: statsTarget })
}

/**
 * Auto-mount Svelte Button components from HTML.
 *
 * Usage in ERB:
 *   <div data-svelte-button
 *        data-label="Submit for Review"
 *        data-variant="primary"
 *        data-size="md"
 *        data-type="submit"
 *        data-full="true">
 *   </div>
 *
 *   Or as a link:
 *   <div data-svelte-button
 *        data-label="← Back"
 *        data-variant="secondary"
 *        data-href="/books">
 *   </div>
 */
function mountButtons() {
  document.querySelectorAll('[data-svelte-button]').forEach((el) => {
    if (el._svelteButtonMounted) return
    el._svelteButtonMounted = true

    const label    = el.dataset.label    ?? ''
    const variant  = el.dataset.variant  ?? 'primary'
    const size     = el.dataset.size     ?? 'md'
    const href     = el.dataset.href     ?? null
    const type     = el.dataset.type     ?? 'button'
    const disabled = el.dataset.disabled === 'true'
    const full     = el.dataset.full     === 'true'
    const plastic  = el.dataset.plastic !== undefined ? el.dataset.plastic === 'true' : null

    mount(Button, {
      target: el,
      props: {
        variant,
        size,
        href: href || null,
        type,
        disabled,
        full,
        plastic,
        children: () => label,
      }
    })
  })
}

document.addEventListener('DOMContentLoaded', mountButtons)