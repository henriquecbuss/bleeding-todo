<script>
	import { cssVariables } from '$lib/actions/css-variables';
	import { listsStore } from '$lib/stores/list.store';
	import { nanoid } from 'nanoid';

	let name = '';
	let color = '';

	const handleSubmit = () => {
		const newList = {
			id: nanoid(),
			name,
			color,
			workspaceId: 'bb22b656-7ec4-4825-9b42-756e08ddfc6c'
		};

		listsStore?.createList(newList);
	};
</script>

<div>
	<h2>Dashboard</h2>

	{#if $listsStore}
		<ul>
			{#each $listsStore as list (list.id)}
				<li class="flex items-center gap-2 hover:bg-slate-100 rounded-sm py-1 px-2 group">
					<label>
						<div
							class="h-3 w-3 rounded-sm bg-[var(--color)]"
							use:cssVariables={{ color: list.color }}
						/>

						<input
							type="color"
							class="sr-only"
							on:change={(e) => {
								const newColor = e.currentTarget.value;

								listsStore?.editList({
									id: list.id,
									color: newColor
								});
							}}
						/>
					</label>

					<input
						value={list.name}
						on:change={(e) => {
							const newName = e.currentTarget.value;

							listsStore?.editList({
								id: list.id,
								name: newName
							});
						}}
					/>

					<button
						class="hidden group-hover:block ml-auto"
						on:click={() => listsStore?.deleteList({ id: list.id })}>X</button
					>
				</li>
			{/each}
		</ul>
	{/if}

	<form on:submit|preventDefault={handleSubmit} class="mt-4">
		<input type="text" bind:value={name} class="border rounded" />
		<input type="text" bind:value={color} class="border rounded" />

		<button>Send</button>
	</form>
</div>
