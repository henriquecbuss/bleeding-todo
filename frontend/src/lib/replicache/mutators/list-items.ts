import type { WriteTransaction } from 'replicache';

export type ListItem = {
	title: string;
	descriptionMarkdown?: string;
	dueDate?: Date;
	completedAt?: Date;
	assigneeId?: string;
	sortingOrder: number;
	listId: string;
};

export type SerializableListItem<T extends ListItem = ListItem> = T & {
	dueDate?: string;
	completedAt?: string;
};

export type ListItemWithId = ListItem & { id: string };

export const createListItem = async (tx: WriteTransaction, { id, ...item }: ListItemWithId) => {
	await tx.set(`listItem/${id}`, serialize(item));
};

export const deleteListItem = async (tx: WriteTransaction, { id }: { id: string }) => {
	await tx.del(`listItem/${id}`);
};

export const completeListItem = async (tx: WriteTransaction, { id }: { id: string }) => {
	const item = await tx.get<SerializableListItem<ListItem>>(`listItem/${id}`);

	if (!item) {
		return;
	}

	await tx.set(`listItem/${id}`, serialize({ ...item, completedAt: new Date() }));
};

const serialize = <T extends ListItem>(item: T): SerializableListItem<T> => {
	const serializeMaybeDate = (date?: Date | string) => {
		if (!date) {
			return undefined;
		}

		if (typeof date === 'string') {
			return date;
		}

		return date.toISOString();
	};
	return {
		...item,
		dueDate: serializeMaybeDate(item.dueDate),
		completedAt: serializeMaybeDate(item.completedAt)
	};
};

export const deserializeListItem = <T extends ListItem>(item: SerializableListItem<T>): T => {
	return {
		...item,
		dueDate: item.dueDate ? new Date(item.dueDate) : undefined,
		completedAt: item.completedAt ? new Date(item.completedAt) : undefined
	};
};
