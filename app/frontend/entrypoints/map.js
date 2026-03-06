import { mount } from 'svelte'
import Map from '../components/Map.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('map-app')
  if (el) {
    mount(Map, { target: el })
  }
})