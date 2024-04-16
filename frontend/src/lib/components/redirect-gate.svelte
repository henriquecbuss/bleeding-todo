<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';

	export let condition: boolean;
	export let redirect: string;

	onMount(() => {
		if (browser && !condition) {
			goto(redirect);
		}
	});
</script>

{#if condition} <slot /> {/if}
