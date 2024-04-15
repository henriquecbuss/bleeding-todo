<script lang="ts">
	import { cn } from '$lib/utils';
	import type { HTMLInputAttributes } from 'svelte/elements';

	export let className: string = '';
	export let label: string;
	export let inputProps: Omit<HTMLInputAttributes, 'value'> = {};

	export let value: string;
</script>

<label class={cn('flex flex-col', className)}>
	<span class="text-sm">
		{label}
	</span>

	<input
		{...inputProps}
		class={cn('mt-2 border rounded-md py-2 px-3 text-gray-800', inputProps.class)}
		bind:value
	/>
</label>
