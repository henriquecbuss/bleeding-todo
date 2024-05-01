<script>
	import { listsStore } from '$lib/stores/list.store';
	import { nanoid } from 'nanoid';
	import { page } from '$app/stores';
	import { mutationStore } from '$lib/stores/replicache.store';
	import List from './list.svelte';

	let name = '';
	let color = '';

	const handleSubmit = () => {
		const newList = {
			id: nanoid(),
			name,
			color,
			workspaceId: $page.params.workspaceId
		};

		name = '';
		color = '';

		$mutationStore?.createList(newList);
	};
</script>

<div>
	<h2>{$page.params.workspaceId}</h2>

	{#if $listsStore}
		<ul class="space-y-4">
			{#each $listsStore as list (list.id)}
				<List {list} />
			{/each}
		</ul>
	{/if}

	<form on:submit|preventDefault={handleSubmit} class="mt-4">
		<input type="text" bind:value={name} class="border rounded" />
		<input type="text" bind:value={color} class="border rounded" />

		<button>Send</button>
	</form>
</div>
