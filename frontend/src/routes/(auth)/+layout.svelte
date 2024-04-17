<script>
	import LoggedOutNavbar from '$lib/components/logged-out-navbar.svelte';
	import RedirectGate from '$lib/components/redirect-gate.svelte';
	import { authStore } from '$lib/stores/auth.store';
</script>

<RedirectGate condition={!$authStore} redirect="/dashboard">
	<div class="h-full flex flex-col bg-gray-50">
		<LoggedOutNavbar />

		<slot />
	</div>
</RedirectGate>
