import type { WriteTransaction } from 'replicache';

export type List = {
	name: string;
	color: string;
	workspaceId: string;
};

export type ListWithId = List & { id: string };

export const createList = async (
	tx: WriteTransaction,
	{ id, name, color, workspaceId }: ListWithId
) => {
	await tx.set(`list/${id}`, {
		name,
		color,
		workspaceId
	});
};

export const deleteList = async (tx: WriteTransaction, { id }: { id: string }) => {
	await tx.del(`list/${id}`);
};

export const editList = async (
	tx: WriteTransaction,
	{ id, name, color }: { id: string; name?: string; color?: string }
) => {
	const existingList = await tx.get<List>(`list/${id}`);

	if (!existingList) {
		throw new Error(`List with id ${id} not found`);
	}

	await tx.set(`list/${id}`, {
		name: name ?? existingList.name,
		color: color ?? existingList.color,
		workspaceId: existingList.workspaceId
	});
};
