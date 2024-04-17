<script lang="ts">
	import { Icon, type IconSource } from 'svelte-hero-icons';

	import { cn } from '$lib/utils';
	import { tooltip } from '$lib/actions/tooltip';

	export let className = '';
	export let as: 'a' | 'button';
	export let href: string | undefined = undefined;
	export let current: boolean = false;
	export let title: string;
	export let icon: IconSource;
</script>

<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
<svelte:element
	this={as}
	{href}
	role="navigation"
	class={cn(
		'text-sm flex flex-row items-center gap-2 p-2 rounded-lg hover:bg-gray-700',
		{
			'bg-gray-700 font-medium text-white': current
		},
		className
	)}
	on:click
	use:tooltip={{ content: title, requireOverflow: true, innerQuerySelector: 'span' }}
>
	<Icon src={icon} class="w-4 h-4 shrink-0" />

	<span class="line-clamp-1">
		{title}
	</span>
</svelte:element>
