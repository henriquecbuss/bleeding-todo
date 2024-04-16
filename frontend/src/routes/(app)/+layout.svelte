<script lang="ts">
	import Navbar from '$lib/components/navbar.svelte';
	import RedirectGate from '$lib/components/redirect-gate.svelte';
	import { authStore } from '$lib/stores/auth.store';
</script>

<Navbar />

<RedirectGate condition={!!$authStore} redirect="/login">
	<h1>App Layout</h1>
	<slot />
</RedirectGate>
