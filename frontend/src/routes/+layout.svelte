<script>
	import '../app.css';
	import { Toaster } from 'svelte-french-toast';
</script>

<slot />

<Toaster />

<style>
	:global(html, body) {
		height: 100%;
	}
</style>
