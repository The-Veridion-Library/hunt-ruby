import { mount } from 'svelte'
import Hello from '../components/Hello.svelte'

mount(Hello, {
  target: document.getElementById('svelte-app'),
  props: { name: 'Book Hunter' }
})