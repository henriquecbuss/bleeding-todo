import { derived } from 'svelte/store';
import { type ReplicacheStore, replicacheStore } from './replicache.store';
import {
	deserializeListItem,
	type ListItemWithId,
	type SerializableListItem
} from '$lib/replicache/mutators/list-items';
import type { ReadTransaction } from 'replicache';

const listListItems = async (tx: ReadTransaction): Promise<ListItemWithId[]> => {
	const listItems = (
		await tx.scan<SerializableListItem>({ prefix: 'listItem/' }).entries().toArray()
	).map(([id, value]) =>
		deserializeListItem({
			id: id.slice('listItem/'.length),
			...value
		})
	);

	return listItems.sort((a, b) => a.sortingOrder - b.sortingOrder);
};

export const listItemsStore = derived<ReplicacheStore, ListItemWithId[]>(
	replicacheStore,
	(replicache, set) => {
		replicache?.subscribe(listListItems, (listItems) => {
			set(listItems);
		});
	}
);
