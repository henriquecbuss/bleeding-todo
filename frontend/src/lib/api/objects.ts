import { z } from 'zod';

export type User = z.infer<typeof user>;

export type Workspace = z.infer<typeof workspace>;

export const user = z.object({
	id: z.string(),
	email: z.string(),
	username: z.string()
});

const workspaceIcon = z.enum([
	'academic-cap',
	'archive-box',
	'banknotes',
	'beaker',
	'bolt',
	'book-open',
	'bookmark',
	'briefcase',
	'building-storefront',
	'chart-bar',
	'clock',
	'command_line',
	'cpu-chip',
	'cube',
	'currency-dollar',
	'exclamation-circle',
	'fire',
	'light-bulb',
	'map',
	'paint-brush',
	'puzzle-piece',
	'rocket-launch',
	'sparkles',
	'swatch'
]);

export const workspace = z.object({
	id: z.string(),
	name: z.string(),
	icon: workspaceIcon
});
