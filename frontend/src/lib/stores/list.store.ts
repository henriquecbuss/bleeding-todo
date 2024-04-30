import { replicache, type Replicache } from '$lib/replicache';
import type { List, ListWithId } from '$lib/replicache/mutators/lists';
import { type ReadTransaction } from 'replicache';
import { readable } from 'svelte/store';

const listLists = async (tx: ReadTransaction) => {
	const lists = (await tx.scan<List>({ prefix: 'list/' }).entries().toArray()).map(
		([id, value]) => ({ id: id.slice('list/'.length), ...value })
	);

	return lists;
};

const createListsStore = (replicache: Replicache) => {
	const { subscribe } = readable<ListWithId[]>([], (set) => {
		return replicache.subscribe(listLists, (lists) => {
			set(lists);
		});
	});

	return {
		subscribe,
		createList: replicache.mutate.createList,
		deleteList: replicache.mutate.deleteList,
		editList: replicache.mutate.editList
	};
};

export const listsStore = replicache ? createListsStore(replicache) : null;
