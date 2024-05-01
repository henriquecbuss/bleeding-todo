import { replicacheStore, type ReplicacheStore } from './replicache.store';
import type { List, ListWithId } from '$lib/replicache/mutators/lists';
import { type ReadTransaction } from 'replicache';
import { derived } from 'svelte/store';

const listLists = async (tx: ReadTransaction) => {
	const lists = (await tx.scan<List>({ prefix: 'list/' }).entries().toArray()).map(
		([id, value]) => ({ id: id.slice('list/'.length), ...value })
	);

	return lists;
};

export const listsStore = derived<ReplicacheStore, ListWithId[]>(
	replicacheStore,
	(replicache, set) => {
		replicache?.subscribe(listLists, (lists) => {
			set(lists);
		});
	}
);
