<script lang="ts">
	import { cssVariables } from '$lib/actions/css-variables';
	import type { ListWithId } from '$lib/replicache/mutators/lists';
	import { listItemsStore } from '$lib/stores/list-item.store';
	import { mutationStore } from '$lib/stores/replicache.store';
	import { cn } from '$lib/utils';
	import { nanoid } from 'nanoid';
	import { Check, Icon, PlusCircle, XMark } from 'svelte-hero-icons';
	import { derived } from 'svelte/store';

	export let list: ListWithId;

	let title = '';
	let dueDate: string | undefined = undefined;

	const listItems = derived(listItemsStore, ($listItemsStore) => {
		if (!$listItemsStore) {
			return [];
		}

		return $listItemsStore.filter((listItem) => listItem.listId === list.id);
	});

	const createItem = () => {
		$mutationStore?.createListItem({
			id: nanoid(),
			title,
			listId: list.id,
			sortingOrder: $listItems.length + 1,
			dueDate: dueDate ? new Date(dueDate) : undefined
		});

		title = '';
		dueDate = undefined;
	};
</script>

<li class="bg-slate-50 rounded p-2">
	<div class="flex items-center gap-2 hover:bg-slate-100 rounded-sm py-1 px-2 group">
		<label>
			<div class="h-3 w-3 rounded-sm bg-[var(--color)]" use:cssVariables={{ color: list.color }} />

			<input
				type="color"
				class="sr-only"
				on:change={(e) => {
					const newColor = e.currentTarget.value;

					$mutationStore?.editList({
						id: list.id,
						color: newColor
					});
				}}
			/>
		</label>

		<input
			value={list.name}
			class="bg-transparent"
			on:change={(e) => {
				const newName = e.currentTarget.value;

				$mutationStore?.editList({
					id: list.id,
					name: newName
				});
			}}
		/>

		<button
			class="hidden group-hover:block ml-auto hover:bg-red-100 p-1 rounded"
			on:click={() => $mutationStore?.deleteList({ id: list.id })}
		>
			<Icon src={XMark} size="16" /></button
		>
	</div>

	<form on:submit|preventDefault={createItem} class="flex items-center gap-2 mt-2">
		<input type="text" bind:value={title} class="border rounded" />

		<input type="date" bind:value={dueDate} class="border rounded px-2" />

		<button class="bg-slate-200 rounded py-1 px-2 text-sm">
			<Icon src={PlusCircle} size="24" />
		</button>
	</form>

	<ul class="mt-2">
		{#each $listItems as listItem (listItem.id)}
			<li class="flex items-center group py-0.5 px-2 hover:bg-slate-200">
				<span class={cn({ 'line-through': listItem.completedAt !== undefined })}>
					{listItem.title}
				</span>

				<button
					class="hidden group-hover:block ml-auto hover:bg-green-100 p-1 rounded"
					on:click={() => $mutationStore?.completeListItem({ id: listItem.id })}
				>
					<Icon src={Check} size="16" /></button
				>

				<button
					class="hidden group-hover:block ml-2 hover:bg-red-100 p-1 rounded"
					on:click={() => $mutationStore?.deleteListItem({ id: listItem.id })}
				>
					<Icon src={XMark} size="16" /></button
				>
			</li>
		{/each}
	</ul>
</li>
