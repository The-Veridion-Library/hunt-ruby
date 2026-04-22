<script>
  /**
   * TVBH Plastic Button Component
   *
   * Props:
   *   variant  - 'primary' | 'secondary' | 'danger' | 'success' | 'warning' | 'info' | 'ghost' | 'outline' | 'plain'
   *   size     - 'xs' | 'sm' | 'md' | 'lg' | 'xl'
   *   plastic  - boolean (default true for primary/danger/success/warning/info, false for ghost/outline/plain)
   *   href     - if set, renders an <a> tag instead of <button>
   *   type     - button type (default 'button')
   *   disabled - boolean
   *   full     - boolean, makes button width: 100%
   *   class    - extra classes to append
   */
  let {
    variant = 'primary',
    size = 'md',
    plastic = null,
    href = null,
    type = 'button',
    disabled = false,
    full = false,
    class: extraClass = '',
    children,
    onclick,
    ...rest
  } = $props()

  // Determine whether to apply plastic effect
  const plasticVariants = ['primary', 'secondary', 'danger', 'success', 'warning', 'info']

  const sizeMap = {
    xs: 'btn-xs',
    sm: 'btn-sm',
    md: 'btn-md',
    lg: 'btn-lg',
    xl: 'btn-xl',
  }

  const variantMap = {
    primary:   'btn-v-primary',
    secondary: 'btn-v-secondary',
    danger:    'btn-v-danger',
    success:   'btn-v-success',
    warning:   'btn-v-warning',
    info:      'btn-v-info',
    ghost:     'btn-v-ghost',
    outline:   'btn-v-outline',
    plain:     'btn-v-plain',
  }

  const isPlastic = $derived.by(() =>
    plastic !== null ? plastic : plasticVariants.includes(variant)
  )

  const classes = $derived.by(() =>
    [
      'btn-base',
      sizeMap[size] ?? 'btn-md',
      variantMap[variant] ?? 'btn-v-primary',
      isPlastic ? 'btn-plastic' : '',
      full ? 'w-full' : '',
      disabled ? 'btn-disabled' : '',
      extraClass,
    ].filter(Boolean).join(' ')
  )
</script>

{#if href}
  <a {href} class={classes} {...rest}>
    {@render children?.()}
  </a>
{:else}
  <button {type} {disabled} class={classes} {onclick} {...rest}>
    {@render children?.()}
  </button>
{/if}

<style>
  /* Base structure */
  :global(.btn-base) {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.375rem;
    font-family: 'Figtree', sans-serif;
    font-weight: 600;
    border-radius: 0.75rem;
    cursor: pointer;
    text-decoration: none;
    transition: filter 0.15s ease, transform 0.1s ease, box-shadow 0.15s ease;
    position: relative;
    overflow: hidden;
    white-space: nowrap;
    border: none;
    line-height: 1;
  }

  /* Sizes */
  :global(.btn-xs)  { font-size: 0.7rem;    padding: 0.3rem  0.65rem; border-radius: 0.5rem; }
  :global(.btn-sm)  { font-size: 0.8rem;    padding: 0.4rem  0.85rem; border-radius: 0.625rem; }
  :global(.btn-md)  { font-size: 0.875rem;  padding: 0.55rem 1.1rem;  border-radius: 0.75rem; }
  :global(.btn-lg)  { font-size: 1rem;      padding: 0.7rem  1.4rem;  border-radius: 0.875rem; }
  :global(.btn-xl)  { font-size: 1.125rem;  padding: 0.85rem 1.75rem; border-radius: 1rem; }

  /* Plastic highlight shine overlay */
  :global(.btn-plastic::before) {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(255,255,255,0.30) 0%, rgba(255,255,255,0.0) 55%);
    pointer-events: none;
    border-radius: inherit;
  }
  :global(.btn-plastic:not(.btn-disabled):hover) {
    filter: brightness(1.07);
  }
  :global(.btn-plastic:not(.btn-disabled):active) {
    transform: scale(0.972);
    filter: brightness(0.95);
  }

  /* ── Variants ── */

  /* Primary — amber/gold plastic */
  :global(.btn-v-primary) {
    background: linear-gradient(180deg, #f59e0b 0%, #d97706 100%);
    color: #1c0f00;
    box-shadow:
      0 1px 3px rgba(180,90,0,0.28),
      0 4px 12px rgba(180,90,0,0.16),
      inset 0 1px 0 rgba(255,255,255,0.32);
    border: 1px solid rgba(180,90,0,0.22);
  }

  /* Secondary — warm cream plastic */
  :global(.btn-v-secondary) {
    background: linear-gradient(180deg, #ffffff 0%, #f0e8da 100%);
    color: #4a3828;
    box-shadow:
      0 1px 3px rgba(0,0,0,0.11),
      0 2px 8px rgba(0,0,0,0.07),
      inset 0 1px 0 rgba(255,255,255,0.95);
    border: 1px solid #cfc0a8;
  }

  /* Danger — red plastic */
  :global(.btn-v-danger) {
    background: linear-gradient(180deg, #f87171 0%, #dc2626 100%);
    color: #fff;
    box-shadow:
      0 1px 3px rgba(180,30,30,0.28),
      0 4px 12px rgba(180,30,30,0.16),
      inset 0 1px 0 rgba(255,255,255,0.28);
    border: 1px solid rgba(180,30,30,0.22);
  }

  /* Success — green plastic */
  :global(.btn-v-success) {
    background: linear-gradient(180deg, #4ade80 0%, #16a34a 100%);
    color: #052e16;
    box-shadow:
      0 1px 3px rgba(22,100,74,0.22),
      0 4px 12px rgba(22,100,74,0.14),
      inset 0 1px 0 rgba(255,255,255,0.28);
    border: 1px solid rgba(22,100,74,0.18);
  }

  /* Warning — orange plastic */
  :global(.btn-v-warning) {
    background: linear-gradient(180deg, #fb923c 0%, #ea580c 100%);
    color: #fff;
    box-shadow:
      0 1px 3px rgba(180,60,0,0.25),
      0 4px 12px rgba(180,60,0,0.14),
      inset 0 1px 0 rgba(255,255,255,0.28);
    border: 1px solid rgba(180,60,0,0.2);
  }

  /* Info — sky-blue plastic */
  :global(.btn-v-info) {
    background: linear-gradient(180deg, #38bdf8 0%, #0284c7 100%);
    color: #fff;
    box-shadow:
      0 1px 3px rgba(2,100,180,0.25),
      0 4px 12px rgba(2,100,180,0.14),
      inset 0 1px 0 rgba(255,255,255,0.28);
    border: 1px solid rgba(2,100,180,0.2);
  }

  /* Ghost — transparent, warm tinted hover */
  :global(.btn-v-ghost) {
    background: transparent;
    color: #7a5c3a;
    border: 1px solid transparent;
    box-shadow: none;
  }
  :global(.btn-v-ghost:not(.btn-disabled):hover) {
    background: rgba(217, 119, 6, 0.10);
    color: #92400e;
  }
  :global(.btn-v-ghost:not(.btn-disabled):active) {
    background: rgba(217, 119, 6, 0.18);
    transform: scale(0.975);
  }

  /* Outline — bordered, no fill */
  :global(.btn-v-outline) {
    background: transparent;
    color: #7a5c3a;
    border: 1.5px solid #c4a882;
    box-shadow: none;
  }
  :global(.btn-v-outline:not(.btn-disabled):hover) {
    background: rgba(217, 119, 6, 0.07);
    border-color: #d97706;
    color: #92400e;
  }
  :global(.btn-v-outline:not(.btn-disabled):active) {
    transform: scale(0.975);
    background: rgba(217, 119, 6, 0.14);
  }

  /* Plain — looks like a link */
  :global(.btn-v-plain) {
    background: transparent;
    color: #b45309;
    border: 1px solid transparent;
    box-shadow: none;
    font-weight: 500;
    text-decoration: underline;
    text-underline-offset: 2px;
  }
  :global(.btn-v-plain:not(.btn-disabled):hover) {
    color: #92400e;
  }
  :global(.btn-v-plain:not(.btn-disabled):active) {
    transform: scale(0.975);
  }

  /* Disabled state */
  :global(.btn-disabled) {
    opacity: 0.45;
    cursor: not-allowed;
    pointer-events: none;
  }
</style>