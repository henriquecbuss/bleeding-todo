<script>
	import Navbar from '$lib/components/navbar.svelte';
</script>

<div class="h-full flex flex-col bg-gray-50">
	<Navbar />

	<slot />
</div>
